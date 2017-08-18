--MCmobs v0.5
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--maikerumines throwing code
--arrow (weapon)

local c = mobs_mc.is_item_variable_overridden

minetest.register_node("mobs_mc:arrow_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"mcl_throwing_arrow.png^[transformFX", "mcl_throwing_arrow.png^[transformFX", "mcl_throwing_arrow_back.png", "mcl_throwing_arrow_front.png", "mcl_throwing_arrow.png", "mcl_throwing_arrow.png^[transformFX"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"mobs_mc:arrow_box"},
	velocity = 10,
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

--ARROW CODE
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.get_node(pos)

	minetest.add_particle({
		pos = pos,
		velocity = {x=0, y=0, z=0},
		acceleration = {x=0, y=0, z=0},
		expirationtime = .3,
		size = 1,
		collisiondetection = false,
		vertical = false,
		texture = "mobs_mc_arrow_particle.png",
	})

	if self.timer>0.2 then
		local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "mobs_mc:arrow_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 3
					minetest.sound_play("damage", {pos = pos})
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					self.object:remove()
				end
			else
				local damage = 3
				minetest.sound_play("damage", {pos = pos})
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.sound_play("bowhit1", {pos = pos})
			minetest.add_item(self.lastpos, 'mobs_mc:arrow')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("mobs_mc:arrow_entity", THROWING_ARROW_ENTITY)

local arrows = {
	{"mobs_mc:arrow", "mobs_mc:arrow_entity" },
}

local throwing_shoot_arrow = function(itemstack, player)
	for _,arrow in ipairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
			if not minetest.settings:get_bool("creative_mode") then
				player:get_inventory():remove_item("main", arrow[1])
			end
			local playerpos = player:getpos()
			local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])  --mc
			local dir = player:get_look_dir()
			obj:setvelocity({x=dir.x*22, y=dir.y*22, z=dir.z*22})
			obj:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
			obj:setyaw(player:get_look_yaw()+math.pi)
			minetest.sound_play("throwing_sound", {pos=playerpos})
			if obj:get_luaentity().player == "" then
				obj:get_luaentity().player = player
			end
			obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
			return true
		end
	end
	return false
end

if c("arrow") then
	minetest.register_craftitem("mobs_mc:arrow", {
		description = S("Arrow"),
		_doc_items_longdesc = S("Arrows are ammunition for bows."),
		_doc_items_usagehelp = S("To use arrows as ammunition for a bow, put them in the inventory slot following the bow. Slots are counted left to right, top to bottom."),
		inventory_image = "mcl_throwing_arrow_inv.png",
	})
end

if c("arrow") and c("flint") and c("feather") and c("stick") then
	minetest.register_craft({
		output = 'mobs_mc:arrow 4',
		recipe = {
			{mobs_mc.items.flint},
			{mobs_mc.items.stick},
			{mobs_mc.items.feather},
		}
	})
end

if c("bow") then
	minetest.register_tool("mobs_mc:bow_wood", {
		description = S("Bow"),
		_doc_items_longdesc = S("Bows are ranged weapons to shoot arrows at your foes."),
		_doc_items_usagehelp = S("To use the bow, you first need to have at least one arrow in slot following the bow. Leftclick to shoot. Each hit deals 3 damage."),
		inventory_image = "mcl_throwing_bow.png",
		on_use = function(itemstack, user, pointed_thing)
			if throwing_shoot_arrow(itemstack, user, pointed_thing) then
				if not minetest.settings:get_bool("creative_mode") then
					itemstack:add_wear(65535/50)
				end
			end
			return itemstack
		end,
	})

	minetest.register_craft({
		output = 'mobs_mc:bow_wood',
		recipe = {
			{mobs_mc.items.string, mobs_mc.items.stick, ''},
			{mobs_mc.items.string, '', mobs_mc.items.stick},
			{mobs_mc.items.string, mobs_mc.items.stick, ''},
		}
	})
end

local how_to_throw = "Hold it in your and and leftclick to throw."

-- egg throwing item
-- egg entity
if c("egg") then
	local egg_GRAVITY = 9
	local egg_VELOCITY = 19

	mobs:register_arrow("mobs_mc:egg_entity", {
		visual = "sprite",
		visual_size = {x=.5, y=.5},
		textures = {"mobs_chicken_egg.png"},
		velocity = egg_VELOCITY,

		hit_player = function(self, player)
			player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {},
			}, nil)
		end,

		hit_mob = function(self, player)
			player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {},
			}, nil)
		end,

		hit_node = function(self, pos, node)

			if math.random(1, 10) > 1 then
				return
			end

			pos.y = pos.y + 1

			local nod = minetest.get_node_or_nil(pos)

			if not nod
			or not minetest.registered_nodes[nod.name]
			or minetest.registered_nodes[nod.name].walkable == true then
				return
			end

			local mob = minetest.add_entity(pos, "mobs_mc:chicken")
			local ent2 = mob:get_luaentity()

			mob:set_properties({
				visual_size = {
					x = ent2.base_size.x / 2,
					y = ent2.base_size.y / 2
				},
				collisionbox = {
					ent2.base_colbox[1] / 2,
					ent2.base_colbox[2] / 2,
					ent2.base_colbox[3] / 2,
					ent2.base_colbox[4] / 2,
					ent2.base_colbox[5] / 2,
					ent2.base_colbox[6] / 2
				},
			})

			ent2.child = true
			ent2.tamed = true
			ent2.owner = self.playername
		end
	})

	-- shoot egg
	local mobs_shoot_egg = function (item, player, pointed_thing)

		local playerpos = player:getpos()

		minetest.sound_play("default_place_node_hard", {
			pos = playerpos,
			gain = 1.0,
			max_hear_distance = 5,
		})

		local obj = minetest.add_entity({
			x = playerpos.x,
			y = playerpos.y +1.5,
			z = playerpos.z
		}, "mobs_mc:egg_entity")

		local ent = obj:get_luaentity()
		local dir = player:get_look_dir()

		ent.velocity = egg_VELOCITY -- needed for api internal timing
		ent.switch = 1 -- needed so that egg doesn't despawn straight away

		obj:setvelocity({
			x = dir.x * egg_VELOCITY,
			y = dir.y * egg_VELOCITY,
			z = dir.z * egg_VELOCITY
		})

		obj:setacceleration({
			x = dir.x * -3,
			y = -egg_GRAVITY,
			z = dir.z * -3
		})

		-- pass player name to egg for chick ownership
		local ent2 = obj:get_luaentity()
		ent2.playername = player:get_player_name()

		if not minetest.settings:get_bool("creative_mode") then
			item:take_item()
		end

		return item
	end

	minetest.register_craftitem("mobs_mc:egg", {
		description = S("Egg"),
		_doc_items_longdesc = S("Eggs can be thrown and break on impact. There is a small chance that 1 or even 4 chicks will pop out"),
		_doc_items_usagehelp = how_to_throw,
		inventory_image = "mobs_chicken_egg.png",
		on_use = mobs_shoot_egg,
	})
end

-- Snowball

local snowball_GRAVITY = 9
local snowball_VELOCITY = 19

mobs:register_arrow("mobs_mc:snowball_entity", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"mcl_throwing_snowball.png"},
	velocity = snowball_VELOCITY,

	hit_player = function(self, player)
		-- FIXME: No knockback
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {},
		}, nil)
	end,

	hit_mob = function(self, mob)
		-- Hurt blazes, but not damage to anything else
		local dmg = {}
		if mob:get_luaentity().name == "mobs_mc:blaze" then
			dmg = {fleshy = 3}
		end
		-- FIXME: No knockback
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = dmg,
		}, nil)
	end,

})

if c("snowball") then
	-- shoot snowball
	local mobs_shoot_snowball = function (item, player, pointed_thing)

		local playerpos = player:getpos()

		local obj = minetest.add_entity({
			x = playerpos.x,
			y = playerpos.y +1.5,
			z = playerpos.z
		}, "mobs_mc:snowball_entity")

		local ent = obj:get_luaentity()
		local dir = player:get_look_dir()

		ent.velocity = snowball_VELOCITY -- needed for api internal timing
		ent.switch = 1 -- needed so that egg doesn't despawn straight away

		obj:setvelocity({
			x = dir.x * snowball_VELOCITY,
			y = dir.y * snowball_VELOCITY,
			z = dir.z * snowball_VELOCITY
		})

		obj:setacceleration({
			x = dir.x * -3,
			y = -snowball_GRAVITY,
			z = dir.z * -3
		})

		-- pass player name to egg for chick ownership
		local ent2 = obj:get_luaentity()
		ent2.playername = player:get_player_name()

		if not minetest.settings:get_bool("creative_mode") then
			item:take_item()
		end

		return item
	end


	-- Snowball
	minetest.register_craftitem("mobs_mc:snowball", {
		description = S("Snowball"),
		_doc_items_longdesc = S("Snowballs can be thrown at your enemies. A snowball deals 3 damage to blazes, but is harmless to anything else."),
		_doc_items_usagehelp = how_to_throw,
		inventory_image = "mcl_throwing_snowball.png",
		on_use = mobs_shoot_snowball,
	})
end

--end maikerumine code

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC mobs loaded")
end
