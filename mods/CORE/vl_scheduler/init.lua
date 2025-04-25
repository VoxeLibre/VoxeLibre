vl_scheduler = {}

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local amt_queue = dofile(modpath.."/queue.lua")

local DEBUG = false
local BUDGET = 5e4 --  50,000 microseconds = 1/20 second
local FIXED_TIMESLICE_BUDGET = 15e3

-- Constants
vl_scheduler.PRIORITY_NOW_ASYCN = 1
vl_scheduler.PRIORITY_NOW_MAIN = 2
vl_scheduler.PRIORITY_BACKGROUND_ASYNC = 3
vl_scheduler.PRIORITY_BACKGROUND_MAIN = 4

---@class vl_scheduler.Task
---@field next vl_scheduler.Task?
---@field last vl_scheduler.Task?
---@field name string
---@field func fun(task : vl_scheduler.Task, dtime : number)

local start_time = core.get_us_time()

local function noop(_) end

local prioritized_globalsteps = {
	[1] = noop,
	[2] = noop,
	[3] = noop,
	[4] = noop,
}

local used_fixed_timeslice_us = 0

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
local long_queue = amt_queue.new(function(old_item, new_item)
	new_item.next = old_item
	new_item.last = old_item and old_item.last or new_item
	return new_item
end)

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
		time = time,
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
		local slot = task_ring[1+(task_pos + i)%32]
		if slot then
			for j=1,4 do
				local iter = slot[j]
				while iter do
					if iter.name then
						storage:set_string("task_"..sequence.."_"..task_count, serialize_task(iter, 1 + i))
						task_count = task_count + 1
					end
					iter = iter.next
				end
			end
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
		if data and data.name then
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
end
function vl_scheduler.register_serializable(name, func)
	registered_serializable[func] = name
	registered_serializable_from_name[name] = func
end

---@return fun(dtime : number)
local function codegen_run_callbacks(list)
	-- Build function to allow JIT compilation and optimization
	local code = [[
		local args = ...
		local list = args.list
	]]
	for i = 1,#list do
		code = code .. "local f"..i.." = list["..i.."]\n"
	end
	code = code .. [[
		local function run_callbacks(...)
	]]
	for i = 1,#list do
		code = code .. "f"..i.."(...)\n"
	end
	code = code .. [[
		end
		return run_callbacks
	]]
	return loadstring(code)({list = list})
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
	prioritized_globalsteps[1](dtime)
	local next_async_task = run_queue[1]
	while next_async_task do
		next_async_task:func(0)
		local task = next_async_task
		next_async_task = next_async_task.next
		free_task(task)
	end
	run_queue[1] = nil

	-- Run tasks that must be run this timestep (now-main)
	prioritized_globalsteps[2](dtime)
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
	prioritized_globalsteps[3](dtime)
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
	prioritized_globalsteps[4](dtime)
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
	local globalsteps = core.registered_globalsteps
	core.registered_globalsteps = {globalstep}

	prioritized_globalsteps[2] = codegen_run_callbacks(globalsteps)

	core.log("Fixed timeslice "..tostring(used_fixed_timeslice_us)
	       .." of "..tostring(FIXED_TIMESLICE_BUDGET).." used.")
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

function vl_scheduler.register_globalstep(priority, callback)
	if priority == 2 then
		core.register_globalstep(callback)
	else
		local list = prioritized_globalsteps[priority]
		list[#list + 1] = callback
	end
end

function vl_scheduler.register_fixed_globalstep(priority, timeslice_us, callback, profile)
	-- Make sure we don't exceed the allocated time budget for fixed timeslices
	used_fixed_timeslice_us = used_fixed_timeslice_us + timeslice_us
	assert(used_fixed_timeslice_us <= FIXED_TIMESLICE_BUDGET,
		"Fixed timeslice budget exceeded. Rebalancing timeslice allocations required. "..dump{
			used = used_fixed_timeslice_us,
			budget = FIXED_TIMESLICE_BUDGET,
		})

	-- Register the fixed timeslice callback
	local timer = 0
	local total_time = 0
	local dtime_multiplier = timeslice_us * 1e-6

	local label = mcl_util.caller_from_traceback(debug.traceback())

	vl_scheduler.register_globalstep(priority, function(dtime)
		timer = timer + dtime * dtime_multiplier
		if timer <= 0 then return end

		local start_time_us = core.get_us_time()
		callback(dtime)
		local took = core.get_us_time() - start_time_us + 1
		timer = timer - took * 1e-6

		if profile then
			total_time = total_time + took
			local time_per_second = total_time / (core.get_us_time() - start_time) * 1e6
			core.log("info", label.." took "..tostring(took).." us, time per second is "
			       ..tostring(time_per_second).." us per second")
		end
	end)
end

-- Hijack core.after and redirect to this scheduler
---@diagnostic disable-next-line:duplicate-set-field
function core.after(time, func, ...)
	return vl_scheduler_after(time, 2, func, ...)
end

core.register_on_shutdown(vl_scheduler.save)
core.register_on_mods_loaded(vl_scheduler.load)

-- Update start time on first globalstep
vl_scheduler.after(0, 1, function()
	start_time = core.get_us_time()
end)

return vl_scheduler
