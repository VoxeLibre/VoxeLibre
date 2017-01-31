--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


-- Dog
mobs:register_mob("mobs_mc:dog", {
	type = "npc",
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_wolf.x",
	textures = {
		{"mobs_dog.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_wolf_attack",
	},
	view_range = 15,
	stepheight = 1.1,
	owner = "",
	order = "follow",
	floats = {x=0,y=0,z=0},
	walk_velocity = 4,
	run_velocity = 4,
	stepheight = 1.1,
	damage = 4,
	group_attack = true,
	armor = 100,
	attacks_monsters = true,
	attack_type = "dogfight",
	drops = {},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_mobitems:meat_raw" then
			local hp = self.object:get_hp()
			if hp + 4 > self.hp_max then return end
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			self.object:set_hp(hp+4)
		else
			if self.owner == "" then
				self.owner = clicker:get_player_name()
			else
				local formspec = "size[8,4]"
				formspec = formspec .. "textlist[2.85,0;2.1,0.5;dialog;What can I do for you?]"
				formspec = formspec .. "button_exit[1,1;2,2;dfollow;follow]"
				formspec = formspec .. "button_exit[5,1;2,2;dstand;stand]"
				formspec = formspec .. "button_exit[0,2;4,4;dfandp;follow and protect]"
				formspec = formspec .. "button_exit[4,2;4,4;dsandp;stand and protect]"
				formspec = formspec .. "button_exit[1,2;2,2;dgohome; go home]"
				formspec = formspec .. "button_exit[5,2;2,2;dsethome; sethome]"
				minetest.show_formspec(clicker:get_player_name(), "order", formspec)
				minetest.register_on_player_receive_fields(function(clicker, formname, fields)
					if fields.dfollow then
						self.order = "follow"
						self.attacks_monsters = false
					end
					if fields.dstand then
						self.order = "stand"
						self.attacks_monsters = false
					end
					if fields.dfandp then
						self.order = "follow"
						self.attacks_monsters = true
					end
					if fields.dsandp then
						self.order = "stand"
						self.attacks_monsters = true
					end
					if fields.dsethome then
						self.floats = self.object:getpos()
					end
					if fields.dgohome then
						if self.floats then
							self.order = "stand"
							self.object:setpos(self.floats)
						end
					end
				end)
			end
		end
	end,
	animation = {
		speed_normal = 20,
		speed_run = 30,
		stand_start = 10,
		stand_end = 20,
		walk_start = 75,
		walk_end = 100,
		run_start = 100,
		run_end = 130,
		punch_start = 135,
		punch_end = 155,
	},
	jump = true,
	step = 1,
	blood_texture = "mobs_blood.png",
})


-- Wolf by KrupnoPavel
mobs:register_mob("mobs_mc:wolf", {
	type = "animal",
	hp_min = 8,
	hp_max = 8,
	passive = false,
	group_attack = true,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	visual = "mesh",
	mesh = "mobs_wolf.x",
	textures = {
		{"mobs_wolf.png"},
	},
	makes_footstep_sound = true,
	sounds = {
		war_cry = "mobs_wolf_attack",
	},
	view_range = 7,
	walk_velocity = 2,
	run_velocity = 3,
	stepheight = 1.1,
	damage = 4,
	armor = 100,
	attack_type = "dogfight",
	drops = {},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function(self, clicker)
		local tool = clicker:get_wielded_item()
		local dog
		local ent
		if tool:get_name() == "mcl_mobitems:meat_raw" then
			clicker:get_inventory():remove_item("main", "mcl_mobitems:meat_raw")
			dog = minetest.add_entity(self.object:getpos(), "mobs_mc:dog")
			ent = dog:get_luaentity()
			ent.owner = clicker:get_player_name()
			self.object:remove()
		end
	end,
	animation = {
		speed_normal = 20,
		speed_run = 30,
		stand_start = 10,
		stand_end = 20,
		walk_start = 75,
		walk_end = 100,
		run_start = 100,
		run_end = 130,
		punch_start = 135,
		punch_end = 155,
	},
	jump = true,
	step = 0.5,
	blood_texture = "mobs_blood.png",
})
mobs:register_spawn("mobs_mc:wolf", {"mcl_core:dirt_with_grass","mcl_core:dirt","mcl_core:snow", "mcl_core:snowblock"}, 20, 0, 19000, 1, 31000)


-- compatibility
mobs:alias_mob("mobs:wolf", "mobs_mc:wolf")
mobs:alias_mob("mobs:dog", "mobs_mc:dog")
mobs:alias_mob("esmobs:wolf", "mobs_mc:wolf")
mobs:alias_mob("esmobs:dog", "mobs_mc:dog")

-- spawn eggs
mobs:register_egg("mobs_mc:wolf", "Spawn Wolf", "wool_grey.png", 1)
mobs:register_egg("mobs_mc:dog", "Spawn Dog", "wool_brown.png", 1)


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Wolf loaded")
end
