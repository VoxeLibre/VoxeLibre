local function spawn_tnt(pos, entname)
	minetest.sound_play("tnt_ignite", {pos = pos,gain = 1.0,max_hear_distance = 15,})
	local tnt = minetest.add_entity(pos, entname)
	tnt:set_armor_groups({immortal=1})
	return tnt
end

local function activate_if_tnt(nname, np, tnt_np, tntr)
    if nname == "mcl_tnt:tnt" then
        local e = spawn_tnt(np, nname)
        e:setvelocity({x=(np.x - tnt_np.x)*5+(tntr / 4), y=(np.y - tnt_np.y)*5+(tntr / 3), z=(np.z - tnt_np.z)*5+(tntr / 4)})
    end
end

local function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "mcl_tnt:tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                local dist = math.max(1, vector.distance(tnt_np, p))
                local damage = (4 / dist) * tntr
                if obj:is_player() == true then
                    mcl_death_messages.player_damage(obj, string.format("%s was caught in an explosion.", obj:get_player_name()))
                    mcl_hunger.exhaust(obj:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
                end
                obj:set_hp(obj:get_hp() - damage)
            end
        end
    end
end

tnt = {}
tnt.ignite = function(pos)
	minetest.remove_node(pos)
	spawn_tnt(pos, "mcl_tnt:tnt")
	core.check_for_falling(pos)
end

local TNT_RANGE = 3

minetest.register_node("mcl_tnt:tnt", {
	tiles = {"default_tnt_top.png", "default_tnt_bottom.png",
			"default_tnt_side.png", "default_tnt_side.png",
			"default_tnt_side.png", "default_tnt_side.png"},
	is_ground_content = false,
	stack_max = 64,
	description = "TNT",
	paramtype = "light",
	sunlight_propagates = true,
	_doc_items_longdesc = string.format("An explosive device. When it explodes, it will hurt living beings, destroy blocks around it, throw blocks affected by gravity all over the place and light fires. A single TNT has an explosion radius of %d. With a small chance, blocks may drop as an item (as if being mined) rather than being destroyed. TNT can be ignited by tools, explosions, fire, lava and redstone signals.", TNT_RANGE),
	_doc_items_usagehelp = "Place the TNT on the ground and ignite it with one of the methods above. Quickly get in safe distance quickly. The TNT will start to be affected by gravity and explodes in 4 seconds.",
	groups = { dig_immediate = 3, tnt = 1, enderman_takable=1 },
	mesecons = {effector = {
		action_on = tnt.ignite
	}},
	_on_ignite = function(pos, player)
		tnt.ignite(pos)
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
})

local TNT = {
	-- Static definition
	physical = true, -- Collides with things
	 --weight = -100,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"default_tnt_top.png", "default_tnt_bottom.png",
			"default_tnt_side.png", "default_tnt_side.png",
			"default_tnt_side.png", "default_tnt_side.png"},
	-- Initial value for our timer
	timer = 0,
	blinktimer = 0,
	blinkstatus = true,}

function TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^mcl_tnt_blink.png")
end

local function add_effects(pos, radius, drops)
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 1,
		maxsize = radius * 3,
		texture = "tnt_smoke.png",
	})

	-- we just dropped some items. Look at the items entities and pick
	-- one of them to use as texture
	local texture = "tnt_smoke.png" --fallback texture
	local most = 0
	for name, stack in pairs(drops) do
		local count = stack:get_count()
		if count > most then
			most = count
			local def = minetest.registered_nodes[name]
			if def and def.tiles and def.tiles[1] then
				texture = def.tiles[1]
			end
		end
	end

	minetest.add_particlespawner({
		amount = 32,
		time = 0.1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -3, y = 0, z = -3},
		maxvel = {x = 3, y = 5,  z = 3},
		minacc = {x = 0, y = -10, z = 0},
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 2,
		texture = texture,
		collisiondetection = true,
	})
end

function TNT:on_step(dtime)
	local pos = self.object:getpos()
	minetest.add_particle({
		pos = {x=pos.x,y=pos.y+0.5,z=pos.z},
		velocity = {x=math.random(-.1,.1),y=math.random(1,2),z=math.random(-.1,.1)},
		acceleration = {x=0,y=-0.1,z=0},
		expirationtime = math.random(.5,1),
		size = math.random(1,2),
		collisiondetection = false,
		texture = "tnt_smoke.png"
	})
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
	if self.blinktimer > 0.25 then
		self.blinktimer = self.blinktimer - 0.25
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^mcl_tnt_blink.png")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 4 then
		tnt.boom(self.object:getpos(), TNT_RANGE)
		self.object:remove()
	end
end

tnt.boom = function(pos, info)
	local range = info.radius
	local damage_range = info.damage_radius

	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
	do_tnt_physics(pos, range)
	local meta = minetest.get_meta(pos)
	local sound
	if not info.sound then
		sound = "tnt_explode"
	else
		sound = info.sound
	end
	minetest.sound_play(sound, {pos = pos,gain = 1.0,max_hear_distance = 16,})
	if minetest.get_node(pos).name == "mcl_core:water_source" or minetest.get_node(pos).name == "mcl_core:water_flowing" or minetest.get_node(pos).name == "mcl_core:bedrock" or minetest.get_node(pos).name == "protector:display" or minetest.is_protected(pos, "tnt") then
		-- Cancel the Explosion
		return
        end
	for x=-range,range do
		for y=-range,range do
			for z=-range,range do
				if x*x+y*y+z*z <= range * range + range then
					local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
					local n = minetest.get_node(np)
					local def = minetest.registered_nodes[n.name]
					-- Simple blast resistance check (for now). This keeps the important blocks like bedrock, command block, etc. intact.
					-- TODO: Implement the real blast resistance algorithm
					if def and n.name ~= "air" and n.name ~= "ignore" and (def._mcl_blast_resistance == nil or def._mcl_blast_resistance < 1000) then
						activate_if_tnt(n.name, np, pos, 3)
						minetest.remove_node(np)
						core.check_for_falling(np)
						if n.name ~= "mcl_tnt:tnt" and math.random() > 0.9 then
							local drop = minetest.get_node_drops(n.name, "")
							for _,item in ipairs(drop) do
								if type(item) == "string" then
									if math.random(1,100) > 40 then
										local obj = minetest.add_item(np, item)
									end
								end
							end
						end
					end
				end
			end
		end
		add_effects(pos, range, {})
	end
end

minetest.register_entity("mcl_tnt:tnt", TNT)

minetest.register_craft({
	output = "mcl_tnt:tnt",
	recipe = {
		{'mcl_mobitems:gunpowder','group:sand','mcl_mobitems:gunpowder'},
		{'group:sand','mcl_mobitems:gunpowder','group:sand'},
		{'mcl_mobitems:gunpowder','group:sand','mcl_mobitems:gunpowder'}
	}
})

if minetest.get_modpath("doc_identifier") then
	doc.sub.identifier.register_object("mcl_tnt:tnt", "nodes", "mcl_tnt:tnt")
end
