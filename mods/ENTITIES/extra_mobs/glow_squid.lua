--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("extra_mobs")

mobs:register_mob("extra_mobs:glow_squid",{
    type = "animal",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 10,
    hp_max = 10,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
    -- FIXME: If the qlow squid is near the floor, it turns black
    collisionbox = {-0.4, 0.0, -0.4, 0.4, 0.9, 0.4},
    visual = "mesh",
    mesh = "extra_mobs_glow_squid.b3d",
    textures = {
        {"extra_mobs_glow_squid.png"}
    },
    sounds = {
	damage = {name="mobs_mc_squid_hurt", gain=0.3},
	death = {name="mobs_mc_squid_death", gain=0.4},
	flop = "mobs_mc_squid_flop",
	distance = 16,
    },
    animation = {
	    stand_start = 1,
	    stand_end = 60,
	    walk_start = 1,
	    walk_end = 60,
	    run_start = 1,
	    run_end = 60,
	},
    drops = {
	    {name = "extra_mobs:glow_ink_sac",
	    chance = 1,
	    min = 1,
	    max = 3,
	    looting = "common",},
	},
    visual_size = {x=3, y=3},
    makes_footstep_sound = false,
    fly = true,
    fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
    breathes_in_water = true,
    jump = false,
    view_range = 16,
    runaway = true,
    fear_height = 4,
    glow = minetest.LIGHT_MAX,
    do_custom = function(self, dtime)
        local glowSquidPos = self.object:get_pos()
        local chanceOfParticle = math.random(0, 2)
        if chanceOfParticle >= 1 then
            minetest.add_particle({
                pos = {x=glowSquidPos.x+math.random(-2,2)*math.random()/2,y=glowSquidPos.y+math.random(-1,2),z=glowSquidPos.z+math.random(-2,2)*math.random()/2},
                velocity = {x=math.random(-0.25,0.25), y=math.random(-0.25,0.25), z=math.random(-0.25,0.25)},
                acceleration = {x=math.random(-0.5,0.5), y=math.random(-0.5,0.5), z=math.random(-0.5,0.5)},
                expirationtime = math.random(),
                size = 1.5 + math.random(),
                collisiondetection = true,
                vertical = false,
                texture = "glint"..math.random(1, 4)..".png",
                glow = minetest.LIGHT_MAX,
            })
        end
    end
})

-- spawning

local water = mobs_mc.spawn_height.water
mobs:spawn_specific("extra_mobs:glow_squid", mobs_mc.spawn.water, {mobs_mc.items.water_source}, 0, minetest.LIGHT_MAX+1, 30, 10000, 3, water-16, water)

-- spawn egg
mobs:register_egg("extra_mobs:glow_squid", S("Glow Squid"), "extra_mobs_spawn_icon_glow_squid.png", 0)
