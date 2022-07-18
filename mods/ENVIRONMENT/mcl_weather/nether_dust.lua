mcl_weather.nether_dust = {}
mcl_weather.nether_dust.particlespawners = {}

local PARTICLES_COUNT_NETHER_DUST = tonumber(minetest.settings:get("mcl_weather_dust_particles")) or 150

local psdef= {
	amount = PARTICLES_COUNT_NETHER_DUST,
	time = 0,
	minpos = vector.new(-15,-15,-15),
	maxpos =vector.new(15,15,15),
	minvel = vector.new(-0.3,-0.15,-1),
	maxvel = vector.new(0.3,0.15,0.3),
	minacc = vector.new(-1,-0.4,-1),
	maxacc = vector.new(1,0.4,1),
	minexptime = 1,
	maxexptime = 10,
	minsize = 0.2,
	maxsize = 0.7,
	collisiondetection = false,
	collision_removal = false,
	object_collision = false,
	vertical = false
}

local function check_player(player)
	local name=player:get_player_name()
	if mcl_worlds.has_dust(player:get_pos()) and not mcl_weather.nether_dust.particlespawners[name] then
		return true
	end
end

mcl_weather.nether_dust.add_particlespawners = function(player)
	local name=player:get_player_name()
	mcl_weather.nether_dust.particlespawners[name]={}
	psdef.playername = name
	psdef.attached = player
	psdef.glow = math.random(0,minetest.LIGHT_MAX)
	for i=1,3 do
		psdef.texture="mcl_particles_nether_dust"..i..".png"
		mcl_weather.nether_dust.particlespawners[name][i]=minetest.add_particlespawner(psdef)
	end
end

mcl_weather.nether_dust.delete_particlespawners = function(player)
	local name=player:get_player_name()
	if mcl_weather.nether_dust.particlespawners[name] then
		for i=1,3 do
			minetest.delete_particlespawner(mcl_weather.nether_dust.particlespawners[name][i])
		end
		mcl_weather.nether_dust.particlespawners[name]=nil
	end
end

mcl_worlds.register_on_dimension_change(function(player, dimension)
	if check_player(player) then
		return mcl_weather.nether_dust.add_particlespawners(player)
	end
	mcl_weather.nether_dust.delete_particlespawners(player)
end)

minetest.register_on_joinplayer(function(player)
	if check_player(player) then
		mcl_weather.nether_dust.add_particlespawners(player)
	end
end)
minetest.register_on_leaveplayer(function(player)
	mcl_weather.nether_dust.delete_particlespawners(player)
end)
