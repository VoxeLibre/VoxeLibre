local S = minetest.get_translator(minetest.get_current_modname())
local explosions_griefing = minetest.settings:get_bool("mcl_explosions_griefing", true)

local gamerule_tntExplodes = true
vl_tuning.setting("gamerule:tntExplodes", "bool", {
	set = function(value) gamerule_tntExplodes = value end,
	get = function() return gamerule_tntExplodes end,
	default = true,
	description = S("Whether TNT explodes after activation."),
})

tnt = {}

tnt.BOOMTIMER = 4
tnt.BLINKTIMER = 0.25

---@param pos vector.Vector
---@param entname string
---@return core.ObjectRef?
local function spawn_tnt(pos, entname)
	minetest.sound_play("tnt_ignite", { pos = pos, gain = 1.0, max_hear_distance = 15 }, true)
	local ent = minetest.add_entity(pos, entname)
	if ent then
		ent:set_armor_groups({ immortal = 1 })
	end
	return ent
end

---@param pos vector.Vector
---@return core.ObjectRef?
function tnt.ignite(pos)
	minetest.remove_node(pos)
	local e = spawn_tnt(pos, "mcl_tnt:tnt")
	minetest.check_for_falling(pos)
	return e
end

---Add smoke particle of entity at pos.
---
---Intended to be called every step.
---@param pos vector.Vector
function tnt.smoke_step(pos)
	minetest.add_particle({
		pos                = vector.offset(pos, 0, 0.5, 0),
		velocity           = vector.new(math.random() * 0.2 - 0.1, 1.0 + math.random(), math.random() * 0.2 - 0.1),
		acceleration       = vector.new(0, -0.1, 0),
		expirationtime     = 0.15 + math.random() * 0.25,
		size               = 1.0 + math.random(),
		collisiondetection = false,
		texture            = "mcl_particles_smoke.png"
	})
end

local TNT_RANGE = 3

local sounds
if minetest.get_modpath("mcl_sounds") then
	sounds = mcl_sounds.node_sound_wood_defaults()
end

local tnt_mesecons
if minetest.get_modpath("mesecons") then
	tnt_mesecons = {
		effector = {
			action_on = tnt.ignite,
			rules = mesecon.rules.alldirs,
		},
	}
end

local longdesc
if explosions_griefing then
	longdesc = S("An explosive device. When it explodes, it will hurt living beings and destroy blocks around it. TNT has an explosion radius of @1. With a small chance, blocks may drop as an item (as if being mined) rather than being destroyed. TNT can be ignited by tools, explosions, fire, lava and redstone signals."
		, TNT_RANGE)
else
	longdesc = S("An explosive device. When it explodes, it will hurt living beings. TNT has an explosion radius of @1. TNT can be ignited by tools, explosions, fire, lava and redstone signals."
		, TNT_RANGE)
end

minetest.register_node("mcl_tnt:tnt", {
	tiles = {
		"default_tnt_top.png",
		"default_tnt_bottom.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
	},
	is_ground_content = false,
	stack_max = 64,
	description = S("TNT"),
	paramtype = "light",
	sunlight_propagates = true,
	_tt_help = S("Ignited by tools, explosions, fire, lava, redstone power") ..
		"\n" .. S("Explosion radius: @1", tostring(TNT_RANGE)),
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = S("Place the TNT and ignite it with one of the methods above. Quickly get in safe distance. The TNT will start to be affected by gravity and explodes in 4 seconds."),
	groups = { dig_immediate = 3, tnt = 1, enderman_takable = 1, flammable = -1 },
	mesecons = tnt_mesecons,
	on_blast = function(pos, _)
		local e = tnt.ignite(pos)
		if e then
			e:get_luaentity().timer = tnt.BOOMTIMER - (0.5 + math.random())
		end
	end,
	_on_ignite = function(player, pointed_thing)
		tnt.ignite(pointed_thing.under)
		return true
	end,
	_on_burn = function(pos)
		tnt.ignite(pos)
		return true
	end,
	_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
		-- Place and ignite TNT
		if minetest.registered_nodes[dropnode.name].buildable_to then
			minetest.set_node(droppos, { name = stack:get_name() })
			tnt.ignite(droppos)
		end
	end,
	_vl_projectile = {
		on_collide = function(projectile, pos, node, node_def)
			if mcl_burning.is_burning(projectile) then
				tnt.ignite(pos)
			end
		end
	},
	sounds = sounds,
})

local TNT = {
	-- Static definition
	description = S("TNT"),
	physical = true, -- Collides with things
	collide_with_objects = false,
	--weight = -100,
	collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	visual = "cube",
	textures = {
		"default_tnt_top.png",
		"default_tnt_bottom.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
		"default_tnt_side.png",
	},
	-- Initial value for our timer
	timer = 0,
	blinktimer = 0,
	tnt_knockback = true,
	blinkstatus = true,
}

function TNT:on_activate(_, _)
	local phi = math.random(0, 65535) / 65535 * 2 * math.pi
	local hdir_x = math.cos(phi) * 0.02
	local hdir_z = math.sin(phi) * 0.02
	self.object:set_velocity(vector.new(hdir_x, 2, hdir_z))
	self.object:set_acceleration(vector.new(0, -10, 0))
	self.object:set_texture_mod("^mcl_tnt_blink.png")
end

--[[local function add_effects(pos, radius, drops)
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = vector.new(-10, -10, -10),
		maxvel = vector.new(10, 10, 10),
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 1,
		maxsize = radius * 3,
		texture = "mcl_particles_smoke.png",
	})

	-- we just dropped some items. Look at the items entities and pick
	-- one of them to use as texture
	local texture = "mcl_particles_smoke.png" --fallback texture
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
		minvel = vector.new(-3, 0, -3),
		maxvel = vector.new(3, 5, 3),
		minacc = vector.new(0, -10, 0),
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 2,
		texture = texture,
		collisiondetection = true,
	})
end]]

function TNT:on_step(dtime, _)
	if self._removed then return end

	local pos = self.object:get_pos()
	tnt.smoke_step(pos)
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
	if self.blinktimer > tnt.BLINKTIMER then
		self.blinktimer = self.blinktimer - tnt.BLINKTIMER
		if self.blinkstatus then
			self.object:set_texture_mod("")
		else
			self.object:set_texture_mod("^mcl_tnt_blink.png")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > tnt.BOOMTIMER then
		if gamerule_tntExplodes then
			mcl_explosions.explode(self.object:get_pos(), 4, {}, self.object)
		end
		mcl_util.remove_entity(self)
	end
end

minetest.register_entity("mcl_tnt:tnt", TNT)

if minetest.get_modpath("mcl_mobitems") then
	minetest.register_craft({
		output = "mcl_tnt:tnt",
		recipe = {
			{ "mcl_mobitems:gunpowder", "group:sand", "mcl_mobitems:gunpowder" },
			{ "group:sand", "mcl_mobitems:gunpowder", "group:sand" },
			{ "mcl_mobitems:gunpowder", "group:sand", "mcl_mobitems:gunpowder" }
		},
	})
end

if minetest.get_modpath("doc_identifier") then
	doc.sub.identifier.register_object("mcl_tnt:tnt", "nodes", "mcl_tnt:tnt")
end
