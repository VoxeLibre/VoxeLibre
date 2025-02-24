vl_scheduler = {}

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local amt_queue = dofile(modpath.."/queue.lua")

local DEBUG = false
local BUDGET = 5e4 --  50,000 microseconds = 1/20 second

---@class vl_scheduler.Task
---@field next vl_scheduler.Task?
---@field last vl_scheduler.Task?
---@field func fun(task : vl_scheduler.Task, dtime : number)

local every_globalstep

local globalsteps

---@type vl_scheduler.Task[]
local run_queue = {} -- 4 priority levels: now-async, now-main, background-async, background-main

--@type vl_scheduler.Task?
local free_tasks = nil
local free_task_count = 0 -- freelist to reduce memory allocation/garbage collection pressure
local MAX_FREE_TASKS = 200

-- Tasks scheduled in the future that will run in the next 32 timesteps
---@type table<number, vl_scheduler.Task[]>
local task_ring = {}
local task_pos = 1
local long_queue = amt_queue.new()

-- Initialize task ring to avoid memory allocations while running
for i = 1,32 do
	task_ring[i] = {}
end
local task_metatable = {
	__index = {
		cancel = function(self)
			self.real_func = function() end
		end,
		func = function(self)
			self.real_func(unpack(self.args))
		end,
	}
}

local function new_task()
	if not free_tasks then
		local task = {}
		setmetatable(task, task_metatable)
		return task
	end

	local res = free_tasks
	free_tasks = free_tasks.next
	free_task_count = free_task_count - 1
	res.next = nil
	return res
end
vl_scheduler.new_task = new_task
local function free_task(task)
	if free_task_count >= MAX_FREE_TASKS then return end

	task.last = nil
	task.next = free_tasks
	free_tasks = task
	free_task_count = free_task_count + 1
end

function vl_scheduler.print_debug_dump()
	print(dump{
		globalsteps = globalsteps,
		run_queue = run_queue,
		free_task_count = free_task_count,
	--	free_tasks = free_tasks,
		MAX_FREE_TASKS = MAX_FREE_TASKS,
		task_ring = task_ring,
		task_pos = task_pos,
		long_queue = long_queue,
	})
end
function vl_scheduler.set_debug(value)
	DEBUG = value
end
local storage = core.get_mod_storage()
local registered_serializable = {}
local registered_serializable_from_name = {}
local function serialize_task(task, time)
	return core.serialize{
		name = task.name,
		args = task.args,
		time = 0,
		priority = task.priority,
	}
end
function vl_scheduler.save()
	vl_scheduler.print_debug_dump()

	local sequence = storage:get_int("sequence") + 1
	local task_count = 0

	-- Serialize run queue
	for i = 1,4 do
		local iter = run_queue[i]
		while iter do
			if iter.name then
				storage:set_string("task_"..sequence.."_"..task_count, serialize_task(iter, 0))
				task_count = task_count + 1
			end
			iter = iter.next
		end
	end

	-- Serialize task ring
	for i = 0,31 do
		local iter = task_ring[(task_pos + i)%32]
		while iter do
			if iter.name then
				storage:set_string("task_"..sequence.."_"..task_count, serialize_task(iter, 1 + i))
				task_count = task_count + 1
			end
			iter = iter.next
		end
	end

	--TODO: Serialize long duration task queue

	storage:set_int("task_count_"..tostring(sequence), task_count)
	storage:set_int("sequence", sequence)
end
function vl_scheduler.load()
	-- Delete all but the latest sequence
	local sequence = storage:get_int("sequence")
	local keys = storage:get_keys()
	for _,key in ipairs(keys) do
		if key:sub(0,11) == "task_count_" and key ~= "task_count_"..sequence then
			local task_count = storage:get_int(key)

			-- Delete all the old task data
			for i = 0,task_count do
				storage:set_string("task_"..sequence.."_"..i, "")
			end

			-- Delete this sequence
			storage:set_string(key, "")
		end
	end

	local task_count = storage:get_int("task_count_"..sequence) - 1
	for i = 0,task_count do
		local data = core.deserialize(storage:get_string("task_"..sequence.."_"..i))
		local real_func = registered_serializable_from_name[data.name]
		if real_func then
			local task = new_task()
			task.args = data.args
			task.next = nil
			task.real_func = real_func
			task.name = data.name
			vl_scheduler.queue_task(data.time, data.priority, task)
		end
	end
end
function vl_scheduler.register_serializable(name, func)
	registered_serializable[func] = name
	registered_serializable_from_name[name] = func
end

local function build_every_globalstep()
	-- Build function to allow JIT compilation and optimization
	local code = [[
		local args = ...
		local globalsteps = args.globalsteps
	]]
	for i = 1,#globalsteps do
		code = code .. "local f"..i.." = globalsteps["..i.."]\n"
	end
	code = code .. [[
		local function every_globalstep(dtime)
	]]
	for i = 1,#globalsteps do
		code = code .. "f"..i.."(dtime)\n"
	end
	code = code .. [[
		end
		return every_globalstep
	]]
	every_globalstep = loadstring(code)({globalsteps = globalsteps})
end
local function globalstep(dtime)
	if dtime > 0.1 then
		core.log("warning", "Long timestep of "..dtime.." seconds. This may be a sign of an overloaded server or performance issues.")
	end
	local start = core.get_us_time()

	-- Update run queues from tasks from ring buffer
	local tasks = task_ring[task_pos]
	if tasks then
		for i=1,4 do
			if tasks[i] then
				if run_queue[i] then
					run_queue[i].last.next = tasks[i]
					run_queue[i].last = tasks[i].last
				else
					run_queue[i] = tasks[i]
				end
				tasks[i] = nil
			end
		end
	end

	-- Update ring buffer with tasks from amt-queue
	local queue_tasks = long_queue:pop()
	while queue_tasks do
		local task = queue_tasks
		queue_tasks = task.next
		task.next = nil

		if tasks[task.priority] then
			tasks[task.priority].last.next = task
			tasks[task.priority].last = task
		else
			task.last = task
			tasks[task.priority] = task
		end
	end

	task_pos = task_pos + 1
	if task_pos == 33 then task_pos = 1 end

	-- Launch asynchronous tasks that must be issued now (now-async)
	local next_async_task = run_queue[1]
	while next_async_task do
		next_async_task:func(0)
		local task = next_async_task
		next_async_task = next_async_task.next
		free_task(task)
	end
	run_queue[1] = nil

	-- Run tasks that must be run this timestep (now-main)
	every_globalstep(dtime)
	local next_main_task = run_queue[2]
	run_queue[2] = nil
	while next_main_task do
		local task = next_main_task
		next_main_task = task.next
		task.next = nil
		task:func(dtime)
		free_task(task)
	end

	-- Launch asynchronous tasks that may be issued any time (background-async)
	local next_background_async_task = run_queue[3]
	local last_background_async_task = next_background_async_task and next_background_async_task.last
	local now = core.get_us_time()
	while next_background_async_task and (now - start) < BUDGET do
		next_background_async_task:func(0)
		local task = next_background_async_task
		next_background_async_task = next_background_async_task.next
		free_task(task)
		now = core.get_us_time()
	end
	if next_background_async_task then
		next_background_async_task.last = last_background_async_task
	end
	run_queue[3] = next_background_async_task

	-- Run tasks that may be run on any timestep (background-main)
	local next_background_task = run_queue[4]
	local last_background_task = next_background_task and next_background_task.last
	now = core.get_us_time()
	while next_background_task and (now - start) < BUDGET do
		next_background_task:func(0)
		local task = next_background_task
		next_background_task = next_background_task.next
		free_task(task)
		now = core.get_us_time()
	end
	if next_background_task then
		next_background_task.last = last_background_task
	end
	run_queue[4] = next_background_task

	if DEBUG then
		print("Total timestep: "..(core.get_us_time() - start).." microseconds")
	end
end

-- Override all globalstep handlers and redirect to this scheduler
core.register_on_mods_loaded(function()
	globalsteps = core.registered_globalsteps
	core.registered_globalsteps = {globalstep}
	build_every_globalstep()
end)

local function queue_task(when, priority, task)
	assert(priority >= 1 and priority <= 4, "Invalid task priority: expected 1-4, got "..tostring(priority))
	assert(type(task.func) == "function", "Task must provide function in .func field")

	if when == 0 then
		-- Add to next timestep run queue
		local queue = run_queue[priority]
		task.next = nil
		if queue then
			queue.last.next = task
			queue.last = task
		else
			task.last = task
			run_queue[priority] = task
		end
	elseif when < 32 then
		-- Add task to correct priority inside ring buffer position
		local idx = (task_pos + when - 1) % 32 + 1
		local tasks = task_ring[idx]
		if tasks[priority] then
			tasks[priority].last.next = task
			tasks[priority].last = task
		else
			task.last = task
			tasks[priority] = task
		end
	else
		-- Insert into Array-Mapped Trie/Finger Tree queue
		local when_offset = when - 32
		task.priority = priority
		long_queue:insert(task, when_offset)
	end
end
vl_scheduler.queue_task = queue_task

local function vl_scheduler_after(time, priority, func, ...)
	local task = new_task()
	task.args = {...}
	task.real_func = func
	task.name = registered_serializable[func]
	local timesteps = math.round(time / 0.05)
	queue_task(timesteps, priority, task)

	-- Return a job handle that can cancel
	return task
end
vl_scheduler.after = vl_scheduler_after

-- Hijack core.after and redirect to this scheduler
---@diagnostic disable-next-line:duplicate-set-field
function core.after(time, func, ...)
	return vl_scheduler_after(time, 2, func, ...)
end

core.register_on_shutdown(vl_scheduler.save)
core.register_on_mods_loaded(vl_scheduler.load)

return vl_scheduler
