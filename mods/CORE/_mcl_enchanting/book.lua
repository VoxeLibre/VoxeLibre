local book_animations = {["close"] = 1, ["opening"] = 2, ["open"] = 3, ["closing"] = 4}
local book_animation_steps = {0, 640, 680, 700, 740}
local book_animation_speed = 40

function mcl_enchanting.schedule_book_animation(self, anim)
	self.scheduled_anim = {timer = self.anim_length, anim = anim}
end

function mcl_enchanting.set_book_animation(self, anim)
	local anim_index = book_animations[anim]
	local start, stop = book_animation_steps[anim_index], book_animation_steps[anim_index + 1]
	self.object:set_animation({x = start, y = stop}, book_animation_speed)
	self.scheduled_anim = nil
	self.anim_length = (stop - start) / 40
end

function mcl_enchanting.check_animation_schedule(self, dtime)
	local schedanim = self.scheduled_anim
	if schedanim then
		schedanim.timer = schedanim.timer - dtime
		if schedanim.timer <= 0 then
			 mcl_enchanting.set_book_animation(self, schedanim.anim)local pos1=self.object:get_pos()
		end
	end
end

function mcl_enchanting.look_at(self, pos2)
	local pos1 = self.object:get_pos()
	local vec = vector.subtract(pos1, pos2)
	local yaw = math.atan(vec.z / vec.x) - math.pi/2
	yaw = yaw + (pos1.x >= pos2.x and math.pi or 0)
	self.object:set_yaw(yaw + math.pi)
end

function mcl_enchanting.check_book(pos)
	local obj_pos = vector.add(pos, mcl_enchanting.book_offset)
	for _, obj in pairs(minetest.get_objects_inside_radius(obj_pos, 0.1)) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_enchanting:book" then
			if minetest.get_node(pos).name ~= "mcl_enchanting:table" then
				obj:remove()
			end
			return
		end
	end
	minetest.add_entity(obj_pos, "mcl_enchanting:book")
end

minetest.register_entity("mcl_enchanting:book", {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_enchanting_book.b3d",
		visual_size = {x = 12.5, y = 12.5},
		collisionbox = {0, 0, 0},
		physical = false,
		textures = {"mcl_enchanting_book_entity.png"},
	},
	player_near = false,
	on_activate = function(self)
		self.object:set_armor_groups({immortal = 1})
		mcl_enchanting.set_book_animation(self, "close")
		mcl_enchanting.check_book(vector.subtract(self.object:get_pos(), mcl_enchanting.book_offset))
	end,
	on_step = function(self, dtime)
		local old_player_near = self.player_near
		local player_near = false
		local player
		for _, obj in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 2.5)) do
			if obj:is_player() then
				player_near = true
				player = obj
			end
		end
		if player_near and not old_player_near then
			mcl_enchanting.set_book_animation(self, "opening")
			mcl_enchanting.schedule_book_animation(self, "open")
		elseif old_player_near and not player_near then
			mcl_enchanting.set_book_animation(self, "closing")
			mcl_enchanting.schedule_book_animation(self, "close")
		end
		if player then
			mcl_enchanting.look_at(self, player:get_pos())
		end
		self.player_near = player_near
		mcl_enchanting.check_animation_schedule(self, dtime)
	end,
}) 
