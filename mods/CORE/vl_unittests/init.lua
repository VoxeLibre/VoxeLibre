--SPDX-FileCopyrightText: 2026 AFCMS <afcm.contact@gmail.com>
--SPDX-License-Identifier: GPL-3.0-or-later

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

---Unittests API
vl_unittests = {}

---Whether unit tests are currently enabled for this run.
---@type boolean
vl_unittests.enabled = core.settings:get_bool("vl_unittests_enabled", false)

dofile(modpath .. "/assertions.lua")

---@class vl_unittests.Test
---@field modname string
---@field name string
---@field func fun()

---@class vl_unittests.TestResult
---@field event "test"
---@field mod string
---@field name string
---@field status "pass"|"fail"
---@field duration number Elapsed time in seconds.
---@field traceback string Empty for passing tests.

---@class vl_unittests.Summary
---@field event "summary"
---@field total integer
---@field passed integer
---@field failed integer

---@type vl_unittests.Test[]
local tests = {}
---@type table<string, table<string, boolean>>
local names = {}
local started = false

---Register a test
---@param name string Test name, unique within the registering mod.
---@param func fun() Synchronous test callback; return values are ignored.
function vl_unittests.test(name, func)
	assert(not started, "cannot register tests after execution starts")
	assert(type(name) == "string" and name:find("%S"), "test name must be a nonempty string")
	assert(type(func) == "function", "test callback must be a function")

	local test_modname = core.get_current_modname()
	assert(test_modname, "tests must be registered during mod loading")
	names[test_modname] = names[test_modname] or {}

	assert(not names[test_modname][name], "duplicate test: " .. test_modname .. ":" .. name)
	names[test_modname][name] = true

	if vl_unittests.enabled then
		tests[#tests + 1] = { modname = test_modname, name = name, func = func }
	end
end

---Output to log a test or summary record
---@param record vl_unittests.TestResult|vl_unittests.Summary
local function emit(record)
	local json, err = core.write_json(record)
	assert(json, err)
	core.log("action", "[vl_unittests] " .. json)
end

---@param err any
---@return string traceback Printable error message + stack trace
local function traceback(err)
	local ok, message = pcall(tostring, err)
	return debug.traceback(ok and message or "unprintable Lua error", 2)
end

core.register_on_mods_loaded(function()
	if not vl_unittests.enabled or started then return end
	started = true
	table.sort(tests, function(a, b)
		if a.modname == b.modname then return a.name < b.name end
		return a.modname < b.modname
	end)

	local passed, failed = 0, 0
	for _, test in ipairs(tests) do
		local start = core.get_us_time()
		local ok, err = xpcall(test.func, traceback)
		local duration = (core.get_us_time() - start) / 1000000
		if ok then passed = passed + 1 else failed = failed + 1 end
		emit({
			event = "test",
			mod = test.modname,
			name = test.name,
			status = ok and "pass" or "fail",
			duration = duration,
			traceback = ok and "" or err,
		})
	end

	emit({ event = "summary", total = #tests, passed = passed, failed = failed })

	core.request_shutdown("VoxeLibre unit tests finished", false, 0)
end)
