package.path = package.path .. ";../../../tests/lib/?.lua"
local mock = require("mock").luanti(_G)
mock.current_modname = "vl_scheduler"
mock.modpaths["vl_scheduler"] = "./"

local fastforward = mock.fastforward
local call_globalstep = mock.call_globalsteps

describe('vl_scheduler',function()
	it('loads',function()
		local vl_scheduler = dofile("./init.lua")
	end)
	it('intercepts the globalstep handlers',function()
		mock.on_mods_loaded()
		call_globalstep(0.0532432)
		assert.is_same(mock.last_fake_globalstep_dtime, 0.0532432)
	end)
	it('schedules tasks',function()
		local called = false
		_G.core.after(0,function()
			called = true
		end)
		call_globalstep(0.05)
		assert.is_same(true, called)
	end)
	it('schedules 44 correctly',function()
		local after = _G.core.after
		local failed = false

		for i=40,50 do
			after((i-1)*0.05, function(expected_timestep)
				if expected_timestep ~= mock.globalsteps then
					failed = true
					print("expected="..expected_timestep..",actual="..mock.globalsteps)
				end
			end, i)
		end
		--_G.vl_scheduler.print_debug_dump()
		mock.globalsteps = 0
		for i=1,3005 do
			call_globalstep(0.05)
		end
		assert.is_same(false, failed)
	end)
	it('schedules tasks correctly',function()
		local after = _G.core.after
		local failed = false

		for i = 5,3000,1 do
			after((i-1)*0.05, function(expected_timestep)
				if expected_timestep ~= mock.globalsteps then
					failed = true
					print("expected="..expected_timestep..",actual="..mock.globalsteps)
				end
			end, i)
		end
		mock.globalsteps = 0
		for i=1,3005 do
			call_globalstep(0.05)
		end
		assert.is_same(false, failed)
	end)
	it('can schedule multiple tasks for the same timestep',function()
		local after = _G.core.after
		local num_run = 0
		local vl_scheduler = _G.vl_scheduler

		for i=1,10 do
			after(1, function()
				num_run = num_run + 1
			end)
		end
		for i=1,10 do
			after(5/0.05, function()
				num_run = num_run + 1
			end,10+i)
		end

		globalsteps = 0
		for i=1,2000 do
			call_globalstep(0.05)
		end
		call_globalstep(0.05)
		assert.is_same(20, num_run)
	end)
	it('will not run background tasks if over budget with priority = 3',function()
		local num_run = 0
		local vl_scheduler = _G.vl_scheduler
		vl_scheduler.after(0, 2, function()
			fastforward(40000)
		end)
		for i = 1,50 do
			vl_scheduler.after(0, 3, function()
				fastforward(1000)
				num_run = num_run + 1
			end)
		end
		call_globalstep(0.05)
		assert.is_same(10, num_run)
		while(num_run < 50) do
			call_globalstep(0.05)
		end
	end)
	it('will not run background tasks if over budget with priority = 4',function()
		local num_run = 0
		local vl_scheduler = _G.vl_scheduler
		vl_scheduler.after(0, 2, function()
			fastforward(40000)
		end)
		for i = 1,50 do
			vl_scheduler.after(0, 4, function()
				fastforward(1000)
				num_run = num_run + 1
			end)
		end
		call_globalstep(0.05)
		assert.is_same(10, num_run)
		while(num_run < 50) do
			call_globalstep(0.05)
		end
	end)
	it('will not run background tasks if over budget with mixed priority',function()
		local num_3_run = 0
		local num_4_run = 0
		local vl_scheduler = _G.vl_scheduler
		vl_scheduler.after(0, 2, function()
			fastforward(40000)
		end)
		for i = 1,10 do
			vl_scheduler.after(0, 3, function()
				fastforward(500)
				num_3_run = num_3_run + 1
			end)
		end
		for i = 1,20 do
			vl_scheduler.after(0, 4, function()
				fastforward(500)
				num_4_run = num_4_run + 1
			end)
		end
		call_globalstep(0.05)
		assert.is_same(10, num_3_run)
		assert.is_same(10, num_4_run)
		while(num_4_run < 20) do
			call_globalstep(0.05)
		end
	end)
	it('can schedule new tasks recursively and they run on the next timestep',function()
		local vl_scheduler = _G.vl_scheduler
		vl_scheduler.after(0, 2, function() end)
		vl_scheduler.after(0, 2, function()
			vl_scheduler.after(0, 2, function() end)
			vl_scheduler.after(0, 2, function() end)
		end)
		assert.no_error(function()
			call_globalstep(0.05)
		end)
	end)
	it('can provide cancellable jobs from core.after()',function()
		local after = _G.core.after
		local ran = false
		local job = after(1,function()
			ran = true
		end)
		call_globalstep(0.5)
		assert.no_error(function()
			job:cancel()
		end)
		for i = 1,10 do call_globalstep(0.5) end
		assert.is_false(ran)
	end)
end)

