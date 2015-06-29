function spawn_tnt(pos, entname)
    minetest.sound_play("", {pos = pos,gain = 1.0,max_hear_distance = 15,})
    return minetest.env:add_entity(pos, entname)
end

function activate_if_tnt(nname, np, tnt_np, tntr)
    if nname == "tnt:tnt" then
        local e = spawn_tnt(np, nname)
        e:setvelocity({x=(np.x - tnt_np.x)*5+(tntr / 4), y=(np.y - tnt_np.y)*5+(tntr / 3), z=(np.z - tnt_np.z)*5+(tntr / 4)})
    end
end

function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "tnt:tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
                    obj:set_hp(obj:get_hp() - 1)
                end
            end
        end
    end
end

minetest.register_node("tnt:tnt", {
	tile_images = {"default_tnt_top.png", "default_tnt_bottom.png",
			"default_tnt_side.png", "default_tnt_side.png",
			"default_tnt_side.png", "default_tnt_side.png"},
	dug_item = '', -- Get nothing
	material = {
		diggability = "not",
	},
	stack_max = 64,
	description = "TNT",
	mesecons = {effector = {
		action_on = (function(p, node)
			minetest.env:remove_node(p)
			spawn_tnt(p, "tnt:tnt")
			nodeupdate(p)
		end),
	}}
})

minetest.register_on_punchnode(function(p, node)
	if node.name == "tnt:tnt" then
		minetest.env:remove_node(p)
		spawn_tnt(p, "tnt:tnt")
		nodeupdate(p)
	end
end)

local TNT_RANGE = 3
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
	-- Number of punches required to defuse
	health = 1,
	blinktimer = 0,
	blinkstatus = true,}

function TNT:on_activate(staticdata)
	self.object:setvelocity({x=0, y=4, z=0})
	self.object:setacceleration({x=0, y=-10, z=0})
	self.object:settexturemod("^[brighten")
end

function TNT:on_step(dtime)
	local pos = self.object:getpos()
	minetest.add_particle({x=pos.x,y=pos.y+0.5,z=pos.z}, {x=math.random(-.1,.1),y=math.random(1,2),z=math.random(-.1,.1)}, {x=0,y=-0.1,z=0}, math.random(.5,1),math.random(1,2), false, "tnt_smoke.png")
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + dtime
    if self.timer>3 then
        self.blinktimer = self.blinktimer + dtime
        if self.timer>5 then
            self.blinktimer = self.blinktimer + dtime
            self.blinktimer = self.blinktimer + dtime
        end
    end
	if self.blinktimer > 0.5 then
		self.blinktimer = self.blinktimer - 0.5
		if self.blinkstatus then
			self.object:settexturemod("")
		else
			self.object:settexturemod("^[brighten")
		end
		self.blinkstatus = not self.blinkstatus
	end
	if self.timer > 8 then
		local pos = self.object:getpos()
        pos.x = math.floor(pos.x+0.5)
        pos.y = math.floor(pos.y+0.5)
        pos.z = math.floor(pos.z+0.5)
        do_tnt_physics(pos, TNT_RANGE)
		local meta = minetest.env:get_meta(pos)
        minetest.sound_play("tnt_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})
        if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" or minetest.env:get_node(pos).name == "default:bedrock" or minetest.env:get_node(pos).name == "protector:display" or minetest.is_protected(pos, "tnt") then
            -- Cancel the Explosion
            self.object:remove()
            return
        end
        for x=-TNT_RANGE,TNT_RANGE do
			for y=-TNT_RANGE,TNT_RANGE do
				for z=-TNT_RANGE,TNT_RANGE do
					if x*x+y*y+z*z <= TNT_RANGE * TNT_RANGE + TNT_RANGE then
						local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
						local n = minetest.env:get_node(np)
						if n.name ~= "air" and n.name ~= "default:obsidian" and n.name ~= "default:bedrock" and n.name ~= "protector:protect" then
							activate_if_tnt(n.name, np, pos, 3)
							minetest.env:remove_node(np)
							nodeupdate(np)
							if n.name ~= "tnt:tnt" and math.random() > 0.9 then
								local drop = minetest.get_node_drops(n.name, "")
									for _,item in ipairs(drop) do
										if type(item) == "string" then
											if math.random(1,100) > 40 then
												local obj = minetest.env:add_item(np, item)
											end
										end
									end
							end
						end
					end
				end
			end
			self.object:remove()
		end
	end
end

function TNT:on_punch(hitter)
	self.health = self.health - 1
	if self.health <= 0 then
		self.object:remove()
		hitter:get_inventory():add_item("main", "tnt:tnt")
	end
end

minetest.register_entity("tnt:tnt", TNT)

minetest.register_craft({
	output = "tnt:tnt",
	recipe = {
		{'default:gunpowder','default:sand','default:gunpowder'},
		{'default:sand','default:gunpowder','default:sand'},
		{'default:gunpowder','default:sand','default:gunpowder'}
	}
})