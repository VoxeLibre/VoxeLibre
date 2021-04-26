local vector_new = vector.new


--converts yaw to degrees
local degrees = function(yaw)
	return(yaw*180.0/math.pi)
end


mobs.do_head_logic = function(self,dtime)

    local player = minetest.get_player_by_name("singleplayer")

    local look_at = player:get_pos()
    look_at.y = look_at.y + player:get_properties().eye_height




    local pos = self.object:get_pos()

    local body_yaw = self.object:get_yaw()

    local body_dir = minetest.yaw_to_dir(body_yaw)


    pos.y = pos.y + self.head_height_offset

    local head_offset = vector.multiply(body_dir, self.head_direction_offset)

    pos = vector.add(pos, head_offset)




    minetest.add_particle({
    	pos = pos,
    	velocity = {x=0, y=0, z=0},
    	acceleration = {x=0, y=0, z=0},
    	expirationtime = 0.2,
    	size = 1,
    	texture = "default_dirt.png",
    })


    local bone_pos = vector_new(0,0,0)


    --(horizontal)
    bone_pos.y = self.head_bone_pos_y

    --(vertical)
    bone_pos.z = self.head_bone_pos_z

    --print(yaw)

    --local _, bone_rot = self.object:get_bone_position("head")

    --bone_rot.x = bone_rot.x + (dtime * 10)
    --bone_rot.z = bone_rot.z + (dtime * 10)


    local head_yaw 
    head_yaw = minetest.dir_to_yaw(vector.direction(pos,look_at)) - body_yaw

    if self.reverse_head_yaw then
        head_yaw = head_yaw * -1
    end

    --over rotation protection
    --stops radians from going out of spec
    if head_yaw > math.pi then
        head_yaw = head_yaw - (math.pi * 2)
    elseif head_yaw < -math.pi then
        head_yaw = head_yaw + (math.pi * 2)
    end


    local check_failed = false
    --upper check + 90 degrees or upper math.radians (3.14/2)
    if head_yaw > math.pi - (math.pi/2) then
        head_yaw = 0
        check_failed = true
    --lower check - 90 degrees or lower negative math.radians (-3.14/2)
    elseif head_yaw < -math.pi + (math.pi/2) then
        head_yaw = 0
        check_failed = true
    end

    local head_pitch = 0

    --DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG 
    --head_yaw = 0
    --DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG 

    if not check_failed then
        head_pitch = minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(look_at.x,0,look_at.z)),0,pos.y-look_at.y))+(math.pi/2)
    end

    if self.head_pitch_modifier then
        head_pitch = head_pitch + self.head_pitch_modifier
    end

    if self.swap_y_with_x then
        self.object:set_bone_position(self.head_bone, bone_pos, vector_new(degrees(head_pitch),degrees(head_yaw),0))
    else
        self.object:set_bone_position(self.head_bone, bone_pos, vector_new(degrees(head_pitch),0,degrees(head_yaw)))
    end


    --set_bone_position([bone, position, rotation])
end