vl_scheduler = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local DEBUG = false
local BUDGET = 5e4 --  50,000 microseconds = 1/20 second

local amt_queue = dofile(modpath.."/queue.lua")
local globalsteps
local run_queue = {} -- 4 priority levels: now-async, now-main, background-async, background-main
local every_globalstep
local free_task_count = 0 -- freelist to reduce memory allocation/garbage collection pressure
local free_tasks = nil
local MAX_FREE_TASKS = 200
-- Tasks scheduled in the future that will run in the next 32 timesteps
local task_ring = {}
local task_pos = 1
local long_queue = amt_queue.new()

-- Initialize task ring to avoid memory allocations while running
for i = 1,32 do
	task_ring[i] = {}
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

local function new_task()
	if free_task_count == 0 then return {} end
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
		minetest.log("warning", "Long timestep of "..dtime.." seconds. This may be a sign of an overloaded server or performance issues.")
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
		next_async_task:func()
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
		next_background_async_task:func()
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
	local now = core.get_us_time()
	while next_background_task and (now - start) < BUDGET do
		next_background_task:func()
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

local function vl_scheduler_after(time, priority, func, ...)
	local task = new_task()
	task.args = {...}
	task.next = nil
	task.real_func = func
	setmetatable(task, task_metatable)
	local timesteps = math.round(time / 0.05)
	queue_task(timesteps, priority, task)

	-- Return a job handle that can cancel
	return task
end
vl_scheduler.after = vl_scheduler_after

-- Hijack core.after and redirect to this scheduler
function core.after(time, func, ...)
	return vl_scheduler_after(time, 2, func, ...)
end

return vl_scheduler
