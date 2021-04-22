local S = minetest.get_translator("mcl_fireworks")

local player_rocketing = {}

local tt_help = S("Flight Duration:")
local description = S("Firework Rocket")

local function register_rocket(n, duration, force)
	minetest.register_craftitem("mcl_fireworks:rocket_" .. n, {
		description = description,
		_tt_help = tt_help .. " " .. duration,
		inventory_image = "mcl_fireworks_rocket.png",
		stack_max = 64,
		on_use = function(itemstack, user, pointed_thing)
			local elytra = mcl_playerplus.elytra[user]
			if elytra.active and elytra.rocketing <= 0 then
				elytra.rocketing = duration
				itemstack:take_item()
				minetest.sound_play("mcl_fireworks_rocket", {pos = user:get_pos()})
			end
			return itemstack
		end,
	})
end

register_rocket(1, 2.2, 10)
register_rocket(2, 4.5, 20)
register_rocket(3, 6, 30)
