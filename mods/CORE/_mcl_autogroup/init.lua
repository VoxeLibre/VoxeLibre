--[[
This mod implements a HACK to make 100% sure the digging times of all tools
match Minecraft's perfectly.  The digging times system of Minetest is very
different, so this weird group trickery has to be used.  In Minecraft, each
block has a hardness and the actual Minecraft digging time is determined by
this:

1) The block's hardness
2) The tool being used (the tool_multiplier and its efficiency level)
3) Whether the tool is considered as "eligible" for the block
   (e.g. only diamond pick eligible for obsidian)

See Minecraft Wiki <http://minecraft.gamepedia.com/Minecraft_Wiki> for more
information.

How the mod is used
===================

In MineClone 2, all diggable node have the hardness set in the custom field
"_mcl_hardness" (0 by default).  Digging groups are registered using the
following code:

    mcl_autogroup.register_digtime_group("pickaxey", { levels = 5 })
    mcl_autogroup.register_digtime_group("shovely")
    mcl_autogroup.register_digtime_group("shovely")

The first line registers "pickaxey" as a digging group.  The "levels" field
indicates that the digging group have 5 levels (in this case one for each
material of a pickaxe).  The second line registers "shovely" as a digging group
which does not have separate levels (if the "levels" field is not set it
defaults to 0).

Nodes indicate that they belong to a particular digging group by being member of
the digging group in their node definition.  "mcl_core:dirt" for example has
shovely=1 in its groups.  If the digging group has multiple levels the value of
the group indicates which digging level the node requires.
"mcl_core:stone_with_gold" for example has pickaxey=3 because it requires a
pickaxe of level 3 to be mined.

For tools to be able to dig nodes of the digging groups they need to use the
have the custom field "_mcl_autogroup_groupcaps" function to get the groupcaps.
See "mcl_tools/init.lua" for examples of this.

Information about the mod
=========================

The mod is also split up into two mods, mcl_autogroups and _mcl_autogroups.
mcl_autogroups contains the API functions used to register custom digging
groups.  _mcl_autogroups contains parts of the mod which need to be executed
after loading all other mods.
--]]

-- The groups which affect dig times
local basegroups = {}
for group, _ in pairs(mcl_autogroup.registered_digtime_groups) do
	table.insert(basegroups, group)
end

-- Returns a table containing the unique "_mcl_hardness" for nodes belonging to
-- each basegroup.
local function get_hardness_values_for_groups()
	local maps = {}
	local values = {}
	for _, g in pairs(basegroups) do
		maps[g] = {}
		values[g] = {}
	end

	for _, ndef in pairs(minetest.registered_nodes) do
		for _, g in pairs(basegroups) do
			if ndef.groups[g] ~= nil then
				maps[g][ndef._mcl_hardness or 0] = true
			end
		end
	end

	for g, map in pairs(maps) do
		for k, _ in pairs(map) do
			table.insert(values[g], k)
		end
	end

	for _, g in pairs(basegroups) do
		table.sort(values[g])
	end
	return values
end

-- Returns a table containing a table indexed by "_mcl_hardness_value" to get
-- its index in the list of unique hardnesses for each basegroup.
local function get_hardness_lookup_for_groups(hardness_values)
	map = {}
	for g, values in pairs(hardness_values) do
		map[g] = {}
		for k, v in pairs(values) do
			map[g][v] = k
		end
	end
	return map
end

-- Array of unique hardness values for each group which affects dig time.
local hardness_values = get_hardness_values_for_groups()

-- Map indexed by hardness values which return the index of that value in
-- hardness_value.  Used for quick lookup.
local hardness_lookup = get_hardness_lookup_for_groups(hardness_values)

local function compute_creativetimes(group)
	local creativetimes = {}

	for index, hardness in pairs(hardness_values[group]) do
		table.insert(creativetimes, 0)
	end

	return creativetimes
end

-- Get the list of digging times for using a specific tool on a specific group.
--
-- Parameters:
-- group - the group which it is digging
-- can_harvest - if the tool can harvest the block
-- tool_multiplier - dig speed multiplier for tool (default 1)
-- efficiency - efficiency level for the tool (default 0)
local function get_digtimes(group, can_harvest, tool_multiplier, efficiency)
	efficiency = efficiency or 0
	tool_multiplier = tool_multiplier or 1
	speed_multiplier = tool_multiplier
	if efficiency > 0 then
		speed_multiplier = speed_multiplier + efficiency * efficiency + 1
	end

	local digtimes = {}

	for index, hardness in pairs(hardness_values[group]) do
		local digtime = (hardness or 0) / speed_multiplier
		if can_harvest then
			digtime = digtime * 1.5
		else
			digtime = digtime * 5
		end

		if digtime <= 0.05 then
			digtime = 0
		else
			digtime = math.ceil(digtime * 20) / 20
		end
		table.insert(digtimes, digtime)
	end

	return digtimes
end

-- Get one groupcap field for using a specific tool on a specific group.
local function get_groupcap(group, can_harvest, multiplier, efficiency, uses)
	return {
		times = get_digtimes(group, can_harvest, multiplier, efficiency),
		uses = uses,
		maxlevel = 0,
	}
end

-- Get the groupcaps for a tool on the specified digging groups.  groupcaps_def
-- contains a table with keys being the digging group and values being the tools
-- properties for that digging group.
--
-- The tool properties can have the following values:
--
--   tool_multiplier - the digging speed multiplier for this tool (default 1)
--   efficiency - the efficiency level for this tool (default 0)
--   level - the maximum level of the group the tool can harvest (default 1)
--   uses - the number of uses the tool has for this group
--
-- A level of 0 means that the tool will be able to dig that group but will
-- never be able to harvest the nodes of that group and will always get a
-- digging time penalty.  This is useful for implementing the hand.
--
-- Example usage:
--
--   mcl_autogroup.get_groupcaps {
--       pickaxey = { tool_multiplier = 4, level = 3, uses = 132 }
--   }
--
-- This computes the groupcaps for a tool mining "pickaxey" blocks.  The tool
-- has a digging speed multiplier of 4, can mine nodes of level >= 3 and has 132
-- uses.
local function add_groupcaps(groupcaps, groupcaps_def)
	for g, capsdef in pairs(groupcaps_def) do
		local mult = capsdef.tool_multiplier or 1
		local eff = capsdef.efficiency or 0
		local def = mcl_autogroup.registered_digtime_groups[g]
		local level = capsdef.level or 1
		local max_level = def.levels or 0

		if max_level > 0 then
			level = math.min(level, max_level)
			groupcaps[g .. "_0_dig"] = get_groupcap(g, false, mult, eff)
			groupcaps[g .. "_" .. level .. "_dig"] = get_groupcap(g, true, mult, eff)
		else
			groupcaps[g .. "_dig"] = get_groupcap(g, true, mult, eff)
		end
	end
	return groupcaps
end

-- Checks if the given node would drop its useful drop if dug by a tool with the
-- given tool capabilities. Returns true if it will yield its useful drop, false
-- otherwise.
function mcl_autogroup.can_harvest(nodename, tool_capabilities)
	local ndef = minetest.registered_nodes[nodename]
	local groupcaps = tool_capabilities.groupcaps

	local handy = minetest.get_item_group(nodename, "handy")
	local dig_immediate = minetest.get_item_group(nodename, "handy")
	if handy > 0 or dig_immediate >= 2 then
		return true
	end

	for g, _ in pairs(groupcaps) do
		if ndef.groups[g] then
			if not string.find(g, "_0_dig$") and string.find(g, "_dig$") then
				return true
			end
		end
	end
	return false
end

local overwrite = function()
	for nname, ndef in pairs(minetest.registered_nodes) do
		local newgroups = table.copy(ndef.groups)
		if (nname ~= "ignore" and ndef.diggable) then
			-- Automatically assign the "solid" group for solid nodes
			if (ndef.walkable == nil or ndef.walkable == true)
					and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
					and (ndef.node_box == nil or ndef.node_box.type == "regular")
					and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
				newgroups.solid = 1
			end
			-- Automatically assign the "opaque" group for opaque nodes
			if (not (ndef.paramtype == "light" or ndef.sunlight_propagates)) and
					(ndef.groups.not_opaque == 0 or ndef.groups.not_opaque == nil) then
				newgroups.opaque = 1
			end

			-- Assign groups used for digging this node depending on
			-- the registered digging groups
			for g, gdef in pairs(mcl_autogroup.registered_digtime_groups) do
				local index = hardness_lookup[g][ndef._mcl_hardness]
				if ndef.groups[g] then
					if gdef.levels then
						newgroups[g .. "_0_dig"] = index
						for i = ndef.groups.pickaxey, gdef.levels do
							newgroups[g .. "_" .. i .. "_dig"] = index
						end
					else
						local index = hardness_lookup[g][ndef._mcl_hardness]
						newgroups[g .. "_dig"] = index
					end
				end
			end

			minetest.override_item(nname, {
				groups = newgroups
			})
		end
	end

	for tname, tdef in pairs(minetest.registered_tools) do
		-- Assign groupcaps for digging the registered digging groups
		-- depending on the _mcl_autogroups_groupcaps in the tool
		-- definition
		if tdef._mcl_autogroup_groupcaps then
			local toolcaps = table.copy(tdef.tool_capabilities) or {}
			local groupcaps = toolcaps.groupcaps or {}
			groupcaps = add_groupcaps(groupcaps, tdef._mcl_autogroup_groupcaps)
			toolcaps.groupcaps = groupcaps

			minetest.override_item(tname, {
				tool_capabilities = toolcaps
			})
		end
	end
end

overwrite()
