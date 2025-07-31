--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
mobs_mc = {}

local pr = PseudoRandom(os.time()*5)

local offsets = {}
for x=-2, 2 do
	for z=-2, 2 do
		table.insert(offsets, {x=x, y=0, z=z})
	end
end

--[[ Periodically check and teleport mob to owner if not sitting (order ~= "sit") and
the owner is too far away. To be used with do_custom. Note: Optimized for mobs smaller than 1×1×1.
Larger mobs might have space problems after teleportation.

* dist: Minimum required distance from owner to teleport. Default: 12
* teleport_check_interval: Optional. Interval in seconds to check the mob teleportation. Default: 4 ]]
mobs_mc.make_owner_teleport_function = function(dist, teleport_check_interval)
	return function(self, dtime)
		-- No teleportation if no owner or if sitting
		if not self.owner or self.order == "sit" then
			return
		end
		if not teleport_check_interval then
			teleport_check_interval = 4
		end
		if not dist then
			dist = 12
		end
		if self._teleport_timer == nil then
			self._teleport_timer = teleport_check_interval
			return
		end
		self._teleport_timer = self._teleport_timer - dtime
		if self._teleport_timer <= 0 then
			self._teleport_timer = teleport_check_interval
			local mob_pos = self.object:get_pos()
			local owner = minetest.get_player_by_name(self.owner)
			if not owner then
				-- No owner found, no teleportation
				return
			end
			local owner_pos = owner:get_pos()
			local dist_from_owner = vector.distance(owner_pos, mob_pos)
			if dist_from_owner > dist then
				-- Check for nodes below air in a 5×1×5 area around the owner position
				local check_offsets = table.copy(offsets)
				-- Attempt to place mob near player. Must be placed on walkable node below a non-walkable one. Place inside that air node.
				while #check_offsets > 0 do
					local r = pr:next(1, #check_offsets)
					local telepos = vector.add(owner_pos, check_offsets[r])
					local telepos_below = {x=telepos.x, y=telepos.y-1, z=telepos.z}
					table.remove(check_offsets, r)
					-- Long story short, spawn on a platform
					local trynode = minetest.registered_nodes[minetest.get_node(telepos).name]
					local trybelownode = minetest.registered_nodes[minetest.get_node(telepos_below).name]
					if trynode and not trynode.walkable and
							trybelownode and trybelownode.walkable then
						-- Correct position found! Let's teleport.
						self.object:set_pos(telepos)
						return
					end
				end
			end
		end
	end
end

local function is_forbidden_node(pos, node)
	node = node or minetest.get_node(pos)
	return minetest.get_item_group(node.name, "stair") > 0 or minetest.get_item_group(node.name, "slab") > 0 or minetest.get_item_group(node.name, "carpet") > 0
end

function mcl_mobs:spawn_abm_check(pos, node, name)
	-- Don't spawn monsters on mycelium
	if (node.name == "mcl_core:mycelium" or node.name == "mcl_core:mycelium_snow") and minetest.registered_entities[name].type == "monster" then
		return true
    --Don't Spawn mobs on stairs, slabs, or carpets
	elseif is_forbidden_node(pos, node) or is_forbidden_node(vector.add(pos, vector.new(0, 1, 0))) then
		return true
	-- Spawn on opaque or liquid nodes
	elseif minetest.get_item_group(node.name, "opaque") ~= 0 or minetest.registered_nodes[node.name].liquidtype ~= "none" or node.name == "mcl_core:grass_path" then
		return false
	end

	-- Reject everything else
	return true
end

mobs_mc.shears_wear = 276
mobs_mc.water_level = tonumber(minetest.settings:get("water_level")) or 0

-- Animals
local path = minetest.get_modpath("mobs_mc")
dofile(path .. "/axolotl.lua") -- Mesh and animation by JoeEnderman, Textures by Nova Wustra, modified by JoeEnderman
dofile(path .. "/bat.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/rabbit.lua") -- Mesh and animation byExeterDad
dofile(path .. "/chicken.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/cow+mooshroom.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/horse.lua") -- KrupnoPavel; Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/llama.lua") --  Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/ocelot.lua") --  Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/parrot.lua") --  Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/pig.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/polar_bear.lua") --  Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/sheep.lua") -- Mesh and animation by Pavel_S
dofile(path .. "/wolf.lua") -- KrupnoPavel
dofile(path .. "/squid.lua") -- Animation, sound and egg texture by daufinsyd

-- NPCs
dofile(path .. "/villager.lua") -- KrupnoPavel Mesh and animation by toby109tt  / https://github.com/22i

-- Illagers and witch
dofile(path .. "/pillager.lua") -- Mesh by KrupnoPavel and MrRar, animation by MrRar
dofile(path .. "/villager_evoker.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/villager_vindicator.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/villager_zombie.lua") -- Mesh and animation by toby109tt  / https://github.com/22i

dofile(path .. "/witch.lua") -- Mesh and animation by toby109tt  / https://github.com/22i

--Monsters
dofile(path .. "/elementals.lua") -- Animation by daufinsyd
dofile(path .. "/ender_dragon.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/endermite.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/villager_illusioner.lua") -- Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/ghast.lua") -- maikerumine
dofile(path .. "/guardian.lua") -- maikerumine Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/guardian_elder.lua") -- maikerumine Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/snowman.lua")
dofile(path .. "/iron_golem.lua") -- maikerumine Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/rover.lua") -- Mesh and Animation by Herowl
dofile(path .. "/shulker.lua") -- maikerumine Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/silverfish.lua") -- maikerumine Mesh and animation by toby109tt  / https://github.com/22i
dofile(path .. "/skeleton+stray.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/skeleton_wither.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/stalker.lua") -- Mesh and Animation by Herowl
dofile(path .. "/zombie.lua") -- Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/slime+magma_cube.lua") -- Wuzzy
dofile(path .. "/spider.lua") -- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
dofile(path .. "/vex.lua") -- KrupnoPavel
dofile(path .. "/wither.lua") -- Mesh and animation by toby109tt  / https://github.com/22i

dofile(path .. "/cod.lua")
dofile(path .. "/salmon.lua")
dofile(path .. "/tropical_fish.lua")
dofile(path .. "/dolphin.lua")


dofile(path .. "/glow_squid.lua")

dofile(path .. "/piglin.lua") -- "mobs_mc_zombie_pigman.b3d" Mesh by Morn76 Animation by Pavel_S
dofile(path .. "/hoglin+zoglin.lua")

dofile(path .. "/strider.lua")
