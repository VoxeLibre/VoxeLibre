local S = minetest.get_translator("mcl_experience")
mcl_experience = {}

local
minetest,math,vector,os,pairs,type
=
minetest,math,vector,os,pairs,type

local storage = minetest.get_mod_storage()

local registered_nodes
minetest.register_on_mods_loaded(function()
	registered_nodes = minetest.registered_nodes
end)

local pool = {}
-- loads data from mod storage
local name
local temp_pool
local load_data = function(player)
	name = player:get_player_name()
	pool[name] = {}
	temp_pool = pool[name]
	if storage:get_int(name.."xp_save") > 0 then
		temp_pool.xp_level = storage:get_int(name.."xp_level")
		temp_pool.xp_bar   = storage:get_int(name.."xp_bar"  )
		temp_pool.last_time= minetest.get_us_time()/1000000
	else
		temp_pool.xp_level = 0
		temp_pool.xp_bar   = 0
		temp_pool.last_time= minetest.get_us_time()/1000000
	end
end

-- saves data to be utilized on next login
local name
local temp_pool
local save_data = function(name)
	if type(name) ~= "string" and name:is_player() then
		name = name:get_player_name()
	end
	temp_pool = pool[name]
	
	storage:set_int(name.."xp_level",temp_pool.xp_level)
	storage:set_int(name.."xp_bar",  temp_pool.xp_bar  )

	storage:set_int(name.."xp_save",1)

	pool[name] = nil
end

-------hud manager
local minetest = minetest

local player_huds = {} -- the list of players hud lists (3d array)
hud_manager = {}       -- hud manager class

-- terminate the player's list on leave
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_huds[name] = nil
end)

-- create instance of new hud
hud_manager.add_hud = function(player,hud_name,def)
    local name = player:get_player_name()
    local local_hud = player:hud_add({
		hud_elem_type = def.hud_elem_type,
		position      = def.position,
		text          = def.text,
		number        = def.number,
		direction     = def.direction,
		size          = def.size,
		offset        = def.offset,
    })
    -- create new 3d array here
    -- depends.txt is not needed
    -- with it here
    if not player_huds[name] then
        player_huds[name] = {}
    end

    player_huds[name][hud_name] = local_hud
end

-- delete instance of hud
hud_manager.remove_hud = function(player,hud_name)
    local name = player:get_player_name()
    if player_huds[name] and player_huds[name][hud_name] then
        player:hud_remove(player_huds[name][hud_name])
        player_huds[name][hud_name] = nil
    end
end

-- change element of hud
hud_manager.change_hud = function(data)
    local name = data.player:get_player_name()
    if player_huds[name] and player_huds[name][data.hud_name] then
        data.player:hud_change(player_huds[name][data.hud_name], data.element, data.data)
    end
end

-- gets if hud exists
hud_manager.hud_exists = function(player,hud_name)
    local name = player:get_player_name()
    if player_huds[name] and player_huds[name][hud_name] then
        return(true)
    else
        return(false)
    end
end
-------------------

-- saves specific users data for when they relog
minetest.register_on_leaveplayer(function(player)
	save_data(player)
end)

-- is used for shutdowns to save all data
local save_all = function()
	for name,_ in pairs(pool) do
		save_data(name)
	end
end

-- save all data to mod storage on shutdown
minetest.register_on_shutdown(function()
	save_all()
end)


local name
function mcl_experience.get_player_xp_level(player)
	name = player:get_player_name()
	return(pool[name].xp_level)
end

local name
local temp_pool
function mcl_experience.set_player_xp_level(player,level)
	name = player:get_player_name()
	pool[name].xp_level = level
	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_fg",
		element  = "text",
		data     = tostring(level)
	})
	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_bg",
		element  = "text",
		data     = tostring(level)
	})
end

minetest.hud_replace_builtin("health",{
    hud_elem_type = "statbar",
    position = {x = 0.5, y = 1},
    text = "heart.png",
    number = core.PLAYER_MAX_HP_DEFAULT,
    direction = 0,
    size = {x = 24, y = 24},
    offset = {x = (-10 * 24) - 25, y = -(48 + 24 + 38)},
})

local name
local temp_pool
minetest.register_on_joinplayer(function(player)

	load_data(player)

	name = player:get_player_name()
	temp_pool = pool[name]
		
    hud_manager.add_hud(player,"experience_bar_background",{
        hud_elem_type = "statbar",
        position = {x=0.5, y=1},
        name = "experience bar background",
        text = "experience_bar_background.png",
        number = 36,
        direction = 0,
        offset = {x = (-8 * 28) - 29, y = -(48 + 24 + 16)},
        size = { x=28, y=28 },
        z_index = 0,
	})
	
    hud_manager.add_hud(player,"experience_bar",{
        hud_elem_type = "statbar",
        position = {x=0.5, y=1},
        name = "experience bar",
        text = "experience_bar.png",
        number = temp_pool.xp_bar,
        direction = 0,
        offset = {x = (-8 * 28) - 29, y = -(48 + 24 + 16)},
        size = { x=28, y=28 },
        z_index = 0,
    })
	
    hud_manager.add_hud(player,"xp_level_bg",{
        hud_elem_type = "text",
        position = {x=0.5, y=1},
        name = "xp_level_bg",
        text = tostring(temp_pool.xp_level),
        number = 0x000000,
        offset = {x = 0, y = -(48 + 24 + 24)},
        z_index = 0,
    })                            
    hud_manager.add_hud(player,"xp_level_fg",{
        hud_elem_type = "text",
        position = {x=0.5, y=1},
        name = "xp_level_fg",
        text = tostring(temp_pool.xp_level),
        number = 0xFFFFFF,
        offset = {x = -1, y = -(48 + 24 + 25)},
        z_index = 0,
	})                                                           
end)


local name
local temp_pool
local function level_up_experience(player)
	name = player:get_player_name()
	temp_pool = pool[name]
	
    temp_pool.xp_level = temp_pool.xp_level + 1
	
	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_fg",
		element  = "text",
		data     = tostring(temp_pool.xp_level)
	})
	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_bg",
		element  = "text",
		data     = tostring(temp_pool.xp_level)
	})
end


local name
local temp_pool
function mcl_experience.add_experience(player,experience)
	name = player:get_player_name()
	temp_pool = pool[name]
	
	temp_pool.xp_bar = temp_pool.xp_bar + experience
	
	if temp_pool.xp_bar > 36 then
		if minetest.get_us_time()/1000000 - temp_pool.last_time > 0.04 then
			minetest.sound_play("level_up",{gain=0.2,to_player = name})
			temp_pool.last_time = minetest.get_us_time()/1000000
		end
        temp_pool.xp_bar = temp_pool.xp_bar - 36
		level_up_experience(player)
	else
		if minetest.get_us_time()/1000000 - temp_pool.last_time > 0.01 then
			temp_pool.last_time = minetest.get_us_time()/1000000
			minetest.sound_play("experience",{gain=0.1,to_player = name,pitch=math.random(75,99)/100})
		end
	end
	hud_manager.change_hud({
		player   = player,
		hud_name = "experience_bar",
		element  = "number",
		data     = temp_pool.xp_bar
	})
end

--reset player level
local name
local temp_pool
local xp_amount
minetest.register_on_dieplayer(function(player)
	name = player:get_player_name()
	temp_pool = pool[name]
	xp_amount = temp_pool.xp_level
	
	temp_pool.xp_bar   = 0
	temp_pool.xp_level = 0


	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_fg",
		element  = "text",
		data     = tostring(temp_pool.xp_level)
	})
	hud_manager.change_hud({
		player   = player,
		hud_name = "xp_level_bg",
		element  = "text",
		data     = tostring(temp_pool.xp_level)
	})

	hud_manager.change_hud({
		player   = player,
		hud_name = "experience_bar",
		element  = "number",
		data     = temp_pool.xp_bar
	})

    mcl_experience.throw_experience(player:get_pos(), xp_amount)
end)


local name
local collector, pos, pos2
local direction, distance, player_velocity, goal
local currentvel, acceleration, multiplier, velocity
local node, vel, def
local is_moving, is_slippery, slippery, slip_factor
local size, data
local function xp_step(self, dtime)
	--if item set to be collected then only execute go to player
	if self.collected == true then
		if not self.collector then
			self.collected = false
			return
		end
		collector = minetest.get_player_by_name(self.collector)
		if collector and collector:get_hp() > 0 and vector.distance(self.object:get_pos(),collector:get_pos()) < 5 then
			self.object:set_acceleration(vector.new(0,0,0))
			self.disable_physics(self)
			--get the variables
			pos = self.object:get_pos()
			pos2 = collector:get_pos()
			
			player_velocity = collector:get_player_velocity()
										
			pos2.y = pos2.y + 0.8
							
			direction = vector.direction(pos,pos2)
			distance = vector.distance(pos2,pos)
			multiplier = distance
			if multiplier < 1 then
				multiplier = 1
			end
			goal = vector.multiply(direction,multiplier)
			currentvel = self.object:get_velocity()

			if distance > 1 then
				multiplier = 20 - distance
				velocity = vector.multiply(direction,multiplier)
				goal = velocity
				acceleration = vector.new(goal.x-currentvel.x,goal.y-currentvel.y,goal.z-currentvel.z)
				self.object:add_velocity(vector.add(acceleration,player_velocity))
			elseif distance < 0.4 then
				mcl_experience.add_experience(collector,2)
				self.object:remove()
			end
			return
		else
			self.collector = nil
			self.enable_physics(self)
		end
	end

					
	self.age = self.age + dtime
	if self.age > 300 then
		self.object:remove()
		return
	end

	pos = self.object:get_pos()

	if pos then
		node = minetest.get_node_or_nil({
			x = pos.x,
			y = pos.y -0.25,
			z = pos.z
		})
	else
		return
	end

	-- Remove nodes in 'ignore'
	if node and node.name == "ignore" then
		self.object:remove()
		return
	end

	if not self.physical_state then
		return -- Don't do anything
	end

	-- Slide on slippery nodes
	vel = self.object:get_velocity()
	def = node and registered_nodes[node.name]
	is_moving = (def and not def.walkable) or
		vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0
	is_slippery = false

	if def and def.walkable then
		slippery = minetest.get_item_group(node.name, "slippery")
		is_slippery = slippery ~= 0
		if is_slippery and (math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2) then
			-- Horizontal deceleration
			slip_factor = 4.0 / (slippery + 4)
			self.object:set_acceleration({
				x = -vel.x * slip_factor,
				y = 0,
				z = -vel.z * slip_factor
			})
		elseif vel.y == 0 then
			is_moving = false
		end
	end

	if self.moving_state == is_moving and self.slippery_state == is_slippery then
		-- Do not update anything until the moving state changes
		return
	end

	self.moving_state = is_moving
	self.slippery_state = is_slippery

	if is_moving then
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
	else
		self.object:set_acceleration({x = 0, y = 0, z = 0})
		self.object:set_velocity({x = 0, y = 0, z = 0})
	end
end

minetest.register_entity("mcl_experience:orb", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
		visual = "sprite",
		visual_size = {x = 0.4, y = 0.4},
		textures = {name="experience_orb.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0}},
		spritediv = {x = 1, y = 14},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		pointable = false,
		static_save = false,
	},
	moving_state = true,
	slippery_state = false,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out = nil,
	force_out_start = nil,
	--Collection Variables
	collectable = false,
	try_timer = 0,
	collected = false,
	delete_timer = 0,
	radius = 4,


	on_activate = function(self, staticdata, dtime_s)
		self.object:set_velocity(vector.new(
			math.random(-2,2)*math.random(),
			math.random(2,5),
			math.random(-2,2)*math.random()
		))
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
        size = math.random(20,36)/100
        self.object:set_properties({
			visual_size = {x = size, y = size},
			glow = 14,
		})
		self.object:set_sprite({x=1,y=math.random(1,14)}, 14, 0.05, false)
	end,

	enable_physics = function(self)
		if not self.physical_state then
			self.physical_state = true
			self.object:set_properties({physical = true})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=-9.81, z=0})
		end
	end,

	disable_physics = function(self)
		if self.physical_state then
			self.physical_state = false
			self.object:set_properties({physical = false})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		end
	end,
	on_step = function(self, dtime)
		xp_step(self, dtime)
	end,
})


minetest.register_chatcommand("xp", {
	params = S("[<player>] [<xp>]"),
	description = S("Gives [player <player>] [<xp>] XP"),
	privs = {server=true},
	func = function(name, params)
		local player, xp = nil, 1000
		local P, i = {}, 0
		for str in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end
		if i > 2 then
			return false, S("Error: Too many parameters!")
		end
		if i > 0 then
			xp = tonumber(P[i])
		end
		if i < 2 then
			player = minetest.get_player_by_name(name)
		end
		if i == 2 then
			player = minetest.get_player_by_name(P[1])
		end
		if (not xp) or (xp < 1) then
			return false, S("Error: Incorrect number of XP")
		end
		if not player then
			return false, S("Error: Player not found")
		end
		local pos = player:get_pos()
		pos.y = pos.y + 1.2
		mcl_experience.throw_experience(pos, xp)
	end,
})

function mcl_experience.throw_experience(pos, amount)
    for i = 1,amount do
        object = minetest.add_entity(pos, "mcl_experience:orb")
        if object then
            object:set_velocity({
				x=math.random(-2,2)*math.random(), 
				y=math.random(2,5), 
				z=math.random(-2,2)*math.random()
			})
        end
    end
end
