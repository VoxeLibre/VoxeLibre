#!/usr/bin/env lua

local luacheck = "luacheck"

core = {}
dofile("tests/lib/misc_helpers.lua")

function read_mod_configuration(file)
	local parts = file:split("/")
	parts[#parts] = nil

	local conf = {
		file = file,
		dir = table.concat(parts,"/").."/",
	}

	local f = io.open(file, "r")
	if not f then return conf end

	for line in f:lines() do
		parts = line:split("=")
		if parts and #parts >= 2 then
			local key = parts[1]:trim()
			local value = parts[2]:trim()
			conf[key] = value
		end
	end
	f:close()
	return conf
end

function read_mod_data()
	local mods = {}
	local mod_names = {}

	while true do
		local line = io.read()
		if not line or line == "EOF" then break end

		local mod_conf = read_mod_configuration(line)
		local name = mod_conf.name
		if name then
			table.insert(mod_names, name)
			mods[name] = mod_conf
		else
			print("echo 'Warning! "..line.." doesn't declare module name'")
		end
	end

	return mods,mod_names
end

local function add_deps_for_mod(mod, mods, deps, seen)
	if not mods[mod] then return end

	local dep_list = mods[mod].depends
	if dep_list then
		local depends = dep_list:split(",")
		for i = 1,#depends do
			local depend = depends[i]:trim()
			if not seen[depend] then
				seen[depend] = true
				table.insert(deps, depend)
				add_deps_for_mod(depend, mods, deps, seen)
			end
		end
	end

	dep_list = mods[mod].optional_depends
	if dep_list then
		local depends = dep_list:split(",")
		for i = 1,#depends do
			local depend = depends[i]:trim()
			if not seen[depend] then
				seen[depend] = true
				table.insert(deps, depend)
				add_deps_for_mod(depend, mods, deps, seen)
			end
		end
	end

	dep_list = mods[mod].luacheck_globals
	if dep_list then
		local globals = dep_list:split(",")
		for i = 1,#globals do
			local global = globals[i]:trim()
			if not seen["global: "..global] then
				seen["global: "..global] = true
				table.insert(deps, global)
			end
		end
	end
end

function get_deps_for_mod(mod, mods)
	local deps = {mod}
	local seen = {[mod] = true}
	add_deps_for_mod(mod, mods, deps, seen)
	return deps
end

local mods,mod_names = read_mod_data()
for i = 1,#mod_names do
	local mod = mod_names[i]
	local config = mods[mod]

	local deps = get_deps_for_mod(mod, mods)

	local cmd_options = ""
	for j = 1,#deps do
		cmd_options = cmd_options .. " --globals "..deps[j]
	end

	print("set -e")
	print("echo Checking "..config.name.." located at "..config.dir)
	--print("echo 'Using "..luacheck.." <file> "..cmd_options.."'")
	print("BASE=$(pwd)")
	print("(")
	print(	"cd "..config.dir)
	print(	"for FILE in *.lua; do")
	print(		"if grep -q \""..config.dir.."$FILE\" $BASE/tests/luacheck/check.lst; then")
	print(			"if ! "..luacheck.." $FILE "..cmd_options.." 2>&1 >/tmp/output; then")
	print(				"cat /tmp/output | sed -e 's/warning/error/'")
	print(				"exit 1")
	print(			"fi")
	print(			"echo \""..config.dir.."$FILE\" >> $BASE/luacheck-passed.lst")
	print(		"else")
	print(			"if "..luacheck.." $FILE"..cmd_options.." 2>&1 > /tmp/output; then")
	print(				"echo \""..config.dir.."$FILE\" >> $BASE/luacheck-passed.lst")
	print(			"else")
	print(				"if ! grep -q OK /tmp/output; then")
	print(					"cat /tmp/output")
	print(				"fi")
	print(				"echo \"Checks for $FILE are currently advisory only\"")
	print(			"fi")
	print(		"fi")
	print(	"done")
	print(")")
end

