--[[ Mining times. Yeah, mining times … Alright, this is going to be FUN!

This mod does include a HACK to make 100% sure the digging times of all tools match Minecraft's perfectly.
The digging times system of Minetest is very different, so this weird group trickery has to be used.
In Minecraft, each block has a hardness and the actual Minecraft digging time is determined by this:
1) The block's hardness
2) The tool being used
3) Whether the tool is considered as “eligible” for the block
   (e.g. only diamond pick eligible for obsidian)
See Minecraft Wiki <http://minecraft.gamepedia.com/Minecraft_Wiki> for more information.

In MineClone 2, all diggable node have the hardness set in the custom field “_mcl_hardness” (0 by default).
The nodes are also required to specify the “eligible” tools in groups like “pickaxey”, “shovely”, etc.
This mod then calculates the real digging time based on the node meta data. The real digging times
are then added into mcl_autogroup.digtimes where the table indices are group rating and the values are the
digging times in seconds. These digging times can be then added verbatim into the tool definitions.

Example:
mcl_autogroup.digtimes.pickaxey_dig_diamond[1] = 0.2

→ This means that when a node has been assigned the group “pickaxey_dig_diamond=1”, it can be dug by the
diamond pickaxe in 0.2 seconds.



This strange setup with mcl_autogroup has been done to minimize the amount of required digging times
a single tool needs to use. If this is not being done, the loading time will increase considerably
(>10s).

]]

local materials = { "wood", "gold", "stone", "iron", "diamond" }
local basegroups = { "pickaxey", "axey", "shovely" }
local minigroups = { "handy", "shearsy", "swordy", "shearsy_wool", "swordy_cobweb" }
local divisors = {
	["wood"] = 2,
	["gold"] = 12,
	["stone"] = 4,
	["iron"] = 6,
	["diamond"] = 8,
	["handy"] = 1,
	["shearsy"] = 15,
	["swordy"] = 1.5,
	["shearsy_wool"] = 5,
	["swordy_cobweb"] = 15,
}
local max_efficiency_level = 5

mcl_autogroup = {}
mcl_autogroup.digtimes = {}
mcl_autogroup.creativetimes = {}	-- Copy of digtimes, except that all values are 0. Used for creative mode

for m=1, #materials do
	for g=1, #basegroups do
		mcl_autogroup.digtimes[basegroups[g].."_dig_"..materials[m]] = {}
		mcl_autogroup.creativetimes[basegroups[g].."_dig_"..materials[m]] = {}
		for e=1, max_efficiency_level do
			mcl_autogroup.digtimes[basegroups[g].."_dig_"..materials[m].."_efficiency_"..e] = {}
		end
	end
end
for g=1, #minigroups do
	mcl_autogroup.digtimes[minigroups[g].."_dig"] = {}
	mcl_autogroup.creativetimes[minigroups[g].."_dig"] = {}
	for e=1, max_efficiency_level do
		mcl_autogroup.digtimes[minigroups[g].."_dig_efficiency_"..e] = {}
		mcl_autogroup.creativetimes[minigroups[g].."_dig_efficiency_"..e] = {}
	end
end

local overwrite = function()
	for nname, ndef in pairs(minetest.registered_nodes) do
		local groups_changed = false
		local newgroups = table.copy(ndef.groups)
		if (nname ~= "ignore" and ndef.diggable) then
			-- Automatically assign the “solid” group for solid nodes
			if (ndef.walkable == nil or ndef.walkable == true)
					and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
					and (ndef.node_box == nil or ndef.node_box.type == "regular")
					and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
				newgroups.solid = 1
				groups_changed = true
			end
			-- Automatically assign the “opaque” group for opaque nodes
			if (not (ndef.paramtype == "light" or ndef.sunlight_propagates)) and
					(ndef.groups.not_opaque == 0 or ndef.groups.not_opaque == nil) then
				newgroups.opaque = 1
				groups_changed = true
			end

			local function calculate_group(hardness, material, diggroup, newgroups, actual_rating, expected_rating, efficiency)
				local time, validity_factor
				if actual_rating >= expected_rating then
					-- Valid tool
					validity_factor = 1.5
				else
					-- Wrong tool (higher digging time)
					validity_factor = 5
				end
				local speed_multiplier = divisors[material]
				if efficiency then
					speed_multiplier = speed_multiplier + efficiency * efficiency + 1
				end
				time = (hardness * validity_factor) / speed_multiplier
				if time <= 0.05 then
					time = 0
				else
					time = math.ceil(time * 20) / 20
				end
				table.insert(mcl_autogroup.digtimes[diggroup], time)
				if not efficiency then
					table.insert(mcl_autogroup.creativetimes[diggroup], 0)
				end
				newgroups[diggroup] = #mcl_autogroup.digtimes[diggroup]
				return newgroups
			end

			-- Hack in digging times
			local hardness = ndef._mcl_hardness
			if not hardness then
				hardness = 0
			end

			-- Handle pickaxey, axey and shovely
			for _, basegroup in pairs(basegroups) do
				if (hardness ~= -1 and ndef.groups[basegroup]) then
					for g=1,#materials do
						local diggroup = basegroup.."_dig_"..materials[g]
						newgroups = calculate_group(hardness, materials[g], diggroup, newgroups, g, ndef.groups[basegroup])
						for e=1,max_efficiency_level do
							newgroups = calculate_group(hardness, materials[g], diggroup .. "_efficiency_" .. e, newgroups, g, ndef.groups[basegroup], e)
						end
						groups_changed = true
					end
				end
			end
			for m=1, #minigroups do
				local minigroup = minigroups[m]
				if hardness ~= -1 then
					local diggroup = minigroup.."_dig"
					-- actual rating
					local ar = ndef.groups[minigroup]
					if ar == nil then
						ar = 0
					end
					if (minigroup == "handy")
							or
							(ndef.groups.shearsy_wool and minigroup == "shearsy_wool" and ndef.groups.wool)
							or
							(ndef.groups.swordy_cobweb and minigroup == "swordy_cobweb" and nname == "mcl_core:cobweb")
							or
							(ndef.groups[minigroup] and minigroup ~= "swordy_cobweb" and minigroup ~= "shearsy_wool") then
						newgroups = calculate_group(hardness, minigroup, diggroup, newgroups, ar, 1)
						for e=1,max_efficiency_level do
							newgroups = calculate_group(hardness, minigroup, diggroup .. "_efficiency_" .. e, newgroups, ar, 1, e)
						end
						groups_changed = true
					end
				end
			end

			if groups_changed then
				minetest.override_item(nname, {
					groups = newgroups
				})
			end
		end
	end
end

overwrite()
