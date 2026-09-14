-- SPDX-FileCopyrightText: 2026 AFCMS <afcm.contact@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

---Get a string description of a value
---@param value any
---@return string
local function describe(value)
	local ok, result = pcall(dump, value)
	return ok and result or "<unprintable value>"
end

---@param message? string Optional prefix for the failure diagnostic.
---@param detail string Failure description.
local function fail(message, detail)
	error((message and tostring(message) .. ": " or "") .. detail, 3)
end

---Assert ordinary Lua equality, raising an error on mismatch.
---@param actual any Value being tested.
---@param expected any Expected value; tables use Lua equality semantics.
---@param message? string Optional prefix for the failure diagnostic.
function vl_unittests.assert_equal(actual, expected, message)
	if actual ~= expected then
		fail(message, "expected " .. describe(expected) .. ", got " .. describe(actual))
	end
end

-- Compare raw contents. Table keys retain Lua identity semantics; metatables
-- and the sharing topology of otherwise equal nested tables are ignored.
---@param actual any Value or table being compared.
---@param expected any Expected value or table contents.
---@param seen table<table, table<table, boolean>> Previously visited table pairs.
---@return boolean equal Whether both values have equal raw contents.
local function deep_equal(actual, expected, seen)
	if rawequal(actual, expected) then return true end
	if type(actual) ~= "table" or type(expected) ~= "table" then return false end
	seen[actual] = seen[actual] or {}
	if seen[actual][expected] then return true end
	seen[actual][expected] = true
	for key, value in next, actual do
		if not deep_equal(value, rawget(expected, key), seen) then return false end
	end
	for key in next, expected do
		if rawget(actual, key) == nil then return false end
	end
	return true
end

---Assert recursive raw equality, supporting cycles and ignoring metatables.
---@param actual any Value or table being tested.
---@param expected any Expected value or table contents.
---@param message? string Optional prefix for the failure diagnostic.
function vl_unittests.assert_deep_equal(actual, expected, message)
	if not deep_equal(actual, expected, {}) then
		fail(message, "expected table contents " .. describe(expected) .. ", got " .. describe(actual))
	end
end

---Assert that the absolute numeric difference is within the given tolerance.
---@param actual number Number being tested.
---@param expected number Expected number.
---@param tolerance number Finite, nonnegative absolute tolerance.
---@param message? string Optional prefix for the failure diagnostic.
function vl_unittests.assert_near(actual, expected, tolerance, message)
	if type(tolerance) ~= "number" or tolerance < 0 or tolerance ~= tolerance or tolerance == math.huge then
		fail(message, "tolerance must be a finite nonnegative number")
	end
	if type(actual) ~= "number" or type(expected) ~= "number"
		or not (math.abs(actual - expected) <= tolerance) then
		fail(message, "expected " .. describe(expected) .. " within " .. tolerance .. ", got " .. describe(actual))
	end
end

---Assert that a synchronous callback raises an error.
---@param func fun() Callback invoked without arguments; return values are ignored.
---@param expected_substring? string Literal substring required in the error text.
---@param message? string Optional prefix for the failure diagnostic.
function vl_unittests.assert_error(func, expected_substring, message)
	if type(func) ~= "function" then fail(message, "expected a function") end
	if expected_substring ~= nil and type(expected_substring) ~= "string" then
		fail(message, "expected error substring must be a string")
	end

	local ok, err = pcall(func)

	if ok then fail(message, "expected an error, function returned successfully") end
	if expected_substring ~= nil then
		local printable, text = pcall(tostring, err)
		if not printable or not text:find(expected_substring, 1, true) then
			fail(message, "expected error containing " .. describe(expected_substring) .. ", got " .. describe(err))
		end
	end
end
