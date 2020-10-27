local S = minetest.get_translator("mcl_experience")
mcl_experience = {}
local pool = {}
local registered_nodes
local max_xp = 2^31-1
local max_orb_age = 300 -- seconds

local gravity = {x = 0, y = -((tonumber(minetest.settings:get("movement_gravity"))) or 9.81), z = 0}
local size_min, size_max = 20, 59 -- percents
local delta_size = size_max - size_min
local size_to_xp = {
	{-32768,     2}, -- 1
	{     3,     6}, -- 2
	{     7,    16}, -- 3
	{    17,    36}, -- 4
	{    37,    72}, -- 5
	{    73,   148}, -- 6
	{   149,   306}, -- 7
	{   307,   616}, -- 8
	{   617,  1236}, -- 9
	{  1237,  2476}, --10
	{  2477, 32767}  --11
}

local function xp_to_size(xp)
	local i, l = 1, #size_to_xp
	while (xp > size_to_xp[i][1]) and (i < l) do
		i = i + 1
	end
	return ((i-1) / (l-1) * delta_size + size_min)/100
end

minetest.register_on_mods_loaded(function()
	registered_nodes = minetest.registered_nodes
end)

local load_data = function(player)
	local name = player:get_player_name()
	pool[name] = {}
	local temp_pool = pool[name]
	local meta = player:get_meta()
	temp_pool.xp = meta:get_int("xp") or 0
	temp_pool.level = mcl_experience.xp_to_level(temp_pool.xp)
	temp_pool.bar, temp_pool.bar_step, temp_pool.xp_next_level = mcl_experience.xp_to_bar(temp_pool.xp, temp_pool.level)
	temp_pool.last_time= minetest.get_us_time()/1000000
end

-- saves data to be utilized on next login
local save_data = function(player)
	local name = player:get_player_name()
	local temp_pool = pool[name]
	local meta = player:get_meta()
	meta:set_int("xp", temp_pool.xp)
	pool[name] = nil
end

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
		text2         = def.text2,
		number        = def.number,
		item          = def.item,
		direction     = def.direction,
		size          = def.size,
		offset        = def.offset,
		z_index	      = def.z_index,
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
		local player = minetest.get_player_by_name(name)
		if player then
			save_data(player)
		end
	end
end

-- save all data to mod storage on shutdown
minetest.register_on_shutdown(function()
	save_all()
end)


function mcl_experience.get_player_xp_level(player)
	local name = player:get_player_name()
	return(pool[name].level)
end

function mcl_experience.set_player_xp_level(player,level)
	local name = player:get_player_name()
	if level == pool[name].level then
		return
	end
	pool[name].level = level
	pool[name].xp, pool[name].bar_step, pool[name].next_level = mcl_experience.bar_to_xp(pool[name].bar, level)
	hud_manager.change_hud({player = player, hud_name = "xp_level", element = "text", data = tostring(level)})
	-- we may don't update the bar
end

local name
local temp_pool
minetest.register_on_joinplayer(function(player)

	load_data(player)

	name = player:get_player_name()
	temp_pool = pool[name]
		
	hud_manager.add_hud(player,"experience_bar",
	{
	        hud_elem_type = "statbar", position = {x=0.5, y=1},
	        name = "experience bar",
		text = "experience_bar.png",
		text2 = "experience_bar_background.png",
	        number = temp_pool.bar, item = 36,
		direction = 0,
	        offset = {x = (-8 * 28) - 29, y = -(48 + 24 + 16)},
	        size = { x=28, y=28 }, z_index = 11,
	})
	
	hud_manager.add_hud(player,"xp_level",
	{
	        hud_elem_type = "text", position = {x=0.5, y=1},
	        name = "xp_level", text = tostring(temp_pool.level),
	        number = 0xFFFFFF,
		offset = {x = 0, y = -(48 + 24 + 24)},
	        z_index = 12,
	})                            
end)

function mcl_experience.xp_to_level(xp)
	local xp = xp or 0
	local a, b, c, D
	if xp > 1507 then
		a, b, c = 4.5, -162.5, 2220-xp
	elseif xp > 352 then
		a, b, c = 2.5, -40.5, 360-xp
	else
		a, b, c = 1, 6, -xp
	end
	D = b*b-4*a*c
	if D == 0 then
		return math.floor(-b/2/a)
	elseif D > 0  then
		local v1, v2 = -b/2/a, math.sqrt(D)/2/a
		return math.floor((math.max(v1-v2, v1+v2)))
	end
	return 0
end

function mcl_experience.level_to_xp(level)
	if (level >= 1 and level <= 16) then
		return math.floor(math.pow(level, 2) + 6 * level)
	elseif (level >= 17 and level <= 31) then
		return math.floor(2.5 * math.pow(level, 2) - 40.5 * level + 360)
	elseif level >= 32 then
		return math.floor(4.5 * math.pow(level, 2) - 162.5 * level + 2220);
	end
	return 0
end

function mcl_experience.xp_to_bar(xp, level)
	local level = level or mcl_experience.xp_to_level(xp)
	local xp_this_level = mcl_experience.level_to_xp(level)
	local xp_next_level = mcl_experience.level_to_xp(level+1)
	local bar_step = 36 / (xp_next_level-xp_this_level)
	local bar = (xp-xp_this_level) * bar_step
	return bar, bar_step, xp_next_level
end

function mcl_experience.bar_to_xp(bar, level)
	local xp_this_level = mcl_experience.level_to_xp(level)
	local xp_next_level = mcl_experience.level_to_xp(level+1)
	local bar_step = 36 / (xp_next_level-xp_this_level)
	local xp = xp_this_level + math.floor(bar/36*(xp_next_level-xp_this_level))
	return xp, bar_step, xp_next_level
end

function mcl_experience.add_experience(player, experience)
	local name = player:get_player_name()
	local temp_pool = pool[name]

	local old_bar, old_xp, old_level = temp_pool.bar, temp_pool.xp, temp_pool.level
	temp_pool.xp = math.min(math.max(temp_pool.xp + experience, 0), max_xp)

	if (temp_pool.xp < temp_pool.xp_next_level) and (temp_pool.xp >= old_xp) then
		temp_pool.bar = temp_pool.bar + temp_pool.bar_step * experience
	else
		temp_pool.level = mcl_experience.xp_to_level(temp_pool.xp)
		temp_pool.bar, temp_pool.bar_step, temp_pool.xp_next_level = mcl_experience.xp_to_bar(temp_pool.xp, temp_pool.level)
	end

	if old_bar ~= temp_pool.bar then
		hud_manager.change_hud({player = player, hud_name = "experience_bar", element = "number", data = math.floor(temp_pool.bar)})
	end

	if experience > 0 and minetest.get_us_time()/1000000 - temp_pool.last_time > 0.01 then
		if old_level ~= temp_pool.level then
			minetest.sound_play("level_up",{gain=0.2,to_player = name})
			temp_pool.last_time = minetest.get_us_time()/1000000 + 0.2
		else
			minetest.sound_play("experience",{gain=0.1,to_player = name,pitch=math.random(75,99)/100})
			temp_pool.last_time = minetest.get_us_time()/1000000
		end
	end

	if old_level ~= temp_pool.level then
		hud_manager.change_hud({player = player, hud_name = "xp_level", element = "text", data = tostring(temp_pool.level)})
	end
end

--reset player level
local name
local temp_pool
local xp_amount
minetest.register_on_dieplayer(function(player)
	if minetest.settings:get_bool("mcl_keepInventory", false) then
		return
	end

	name = player:get_player_name()
	temp_pool = pool[name]
	xp_amount = temp_pool.xp
	
	temp_pool.bar   = 0
	temp_pool.level = 0
	temp_pool.xp = 0

	hud_manager.change_hud({player = player, hud_name = "xp_level", element = "text", data = tostring(temp_pool.level)})
	hud_manager.change_hud({player = player, hud_name = "experience_bar", element = "number", data = math.floor(temp_pool.bar)})

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
				mcl_experience.add_experience(collector, self._xp)
				self.object:remove()
			end
			return
		else
			self.collector = nil
			self.enable_physics(self)
		end
	end

					
	self.age = self.age + dtime
	if self.age > max_orb_age then
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
		self.object:set_acceleration(gravity)
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
		self.object:set_acceleration(gravity)
		local xp = tonumber(staticdata)
		self._xp = xp
	        size = xp_to_size(xp)
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
			self.object:set_acceleration(gravity)
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
	params = S("[[<player>] <xp>]"),
	description = S("Gives a player some XP"),
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
		if not xp then
			return false, S("Error: Incorrect value of XP")
		end
		if not player then
			return false, S("Error: Player not found")
		end
		mcl_experience.add_experience(player, xp)
		local playername = player:get_player_name()
		minetest.chat_send_player(name, S("Added @1 XP to @2, total: @3, experience level: @4", tostring(xp), playername, tostring(pool[playername].xp), tostring(pool[playername].level)))
	end,
})

function mcl_experience.throw_experience(pos, amount)
	local i, j = 0, 0
	local obj, xp
	while i < amount and j < 100 do
		xp = math.min(math.random(1, math.min(32767, amount-math.floor(i/2))), amount-i)
		obj = minetest.add_entity(pos, "mcl_experience:orb", tostring(xp))
		if not obj then
			return false
		end
		obj:set_velocity({
			x=math.random(-2,2)*math.random(), 
			y=math.random(2,5), 
			z=math.random(-2,2)*math.random()
		})
		i = i + xp
		j = j + 1
	end
end
