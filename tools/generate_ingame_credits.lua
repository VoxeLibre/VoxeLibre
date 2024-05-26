#! /usr/bin/env lua
-- Script to automatically generate mods/HUD/mcl_credits/people.lua from CREDITS.md
-- Run from MCL2 root folder

local colors = {
	["Creator of MineClone"] = "0x0A9400",
	["Creator of VoxeLibre"] = "0xFBF837",
	["Maintainers"] = "0xFF51D5",
	["Developers"] = "0xF84355",
	["Past Developers"] = "0xF84355",
	["Contributors"] = "0x52FF00",
	["Music"] = "0xA60014",
	["Original Mod Authors"] = "0x343434",
	["3D Models"] = "0x0019FF",
	["Textures"] = "0xFF9705",
	["Translations"] = "0x00FF60",
	["Funders"] = "0xF7FF00",
	["Special thanks"] = "0x00E9FF",
}

local from = io.open("CREDITS.md", "r")
local to = io.open("mods/HUD/mcl_credits/people.lua", "w")

to:write([[
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

]])

to:write("return {\n")

local started_block = false

for line in from:lines() do
	if line:find("## ") == 1 then
		if started_block then
			to:write("\t}},\n")
		end
		local title = line:sub(4, #line)
		to:write("\t{S(\"" .. title .. "\"), " .. (colors[title] or "0xFFFFFF") .. ", {\n")
		started_block = true
	elseif line:find("*") == 1 then
		to:write("\t\t\"" .. line:sub(3, #line) .. "\",\n")
	end
end

if started_block then
	to:write("\t}},\n")
end

to:write("}\n")
