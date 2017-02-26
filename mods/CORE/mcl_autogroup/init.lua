--[[ This mod automatically adds groups to items based on item metadata.

Specifically, this mod has 2 purposes:
1) Automatically adding the group “solid” for blocks considered “solid” in Minecraft.
2) Generating digging time group for all nodes based on node metadata (it's complicated)

]]

--[[ Mining times. Yeah, mining times … Alright, this is going to be FUN!

This mod does include a HACK to make 100% sure the digging times of all tools match Minecraft's perfectly.
The digging times system of Minetest is very different, so this weird group trickery has to be used.so this weird group trickery has to be used.so this weird group trickery has to be used.so this weird group trickery has to be used.
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

→ This menas that when a node has been assigned the group “pickaxey_dig_diamond=1”, it can be dug by the
diamond pickaxe in 0.2 seconds.



This strange setup with mcl_autogroup has been done to minimize the amount of required digging times
a single tool needs to use. If this is not being done, the loading time will increase considerably
(>10s).

]]

local materials = { "wood", "gold", "stone", "iron", "diamond" }
local material_divisors = { 2, 12, 4, 6, 8 }
local basegroups = { "pickaxey", "axey", "shovely" }
local minigroups = { "handy", "shearsy", "swordy" }

mcl_autogroup = {}
mcl_autogroup.digtimes = {}

for m=1, #materials do
	for g=1, #basegroups do
		mcl_autogroup.digtimes[basegroups[g].."_dig_"..materials[m]] = {}
	end
end
for g=1, #minigroups do
	mcl_autogroup.digtimes[minigroups[g].."_dig"] = {}
end



local overwrite = function()
	for nname, ndef in pairs(minetest.registered_nodes) do
		local groups_changed = false
		local newgroups = table.copy(ndef.groups)
		if (nname ~= "ignore") then
			-- Automatically assign the “solid” group for solid nodes
			if (ndef.walkable == nil or ndef.walkable == true)
					and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
					and (ndef.node_box == nil or ndef.node_box.type == "regular")
					and (ndef.groups.falling_node == 0 or ndef.groups.falling_node == nil)
					and (ndef.groups.not_solid == 0 or ndef.groups.not_solid == nil) then
				newgroups.solid = 1
				groups_changed = true
			end

			-- Hack in digging times
			local hardness = ndef._mcl_hardness
			if not hardness then
				hardness = 0
			end
			-- Handle pickaxey, axey and shovely, and also handy indirectly
			for _, basegroup in pairs(basegroups) do
				if (hardness ~= -1 and ndef.groups[basegroup]) then
					for g=1,#materials do
						local diggroup = basegroup.."_dig_"..materials[g]
						local time, validity_factor
						if g >= ndef.groups[basegroup] then
							-- Valid tool
							validity_factor = 1.5
						else
							-- Wrong tool (higher digging time)
							validity_factor = 5
						end
						time = (hardness * validity_factor) / material_divisors[g]
						if time <= 0.05 then
							time = 1
						else
							time = math.ceil(time * 20) / 20
						end
						table.insert(mcl_autogroup.digtimes[diggroup], time)
						newgroups[diggroup] = #mcl_autogroup.digtimes[diggroup]
						groups_changed = true
					end
					if not ndef.groups.handy then
						local time = hardness * 5
						if time <= 0.05 then
							time = 0
						else
							time = math.ceil(time * 20) / 20
						end
						table.insert(mcl_autogroup.digtimes.handy_dig, time)
						newgroups.handy_dig = #mcl_autogroup.digtimes.handy_dig
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
