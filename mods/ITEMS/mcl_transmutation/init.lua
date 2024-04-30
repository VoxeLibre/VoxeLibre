local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local exchange_node
	function exchange_node(itemstack, placer, pointed_thing)
		-- Use pointed node's on_rightclick function first, if present
		local node = minetest.get_node(pointed_thing.under)
		if placer and not placer:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
			end
		end

		-- Node exchange recipes
		if node.name == "mcl_core:cobble" then
			minetest.sound_play({name="zap_on", pos=pos, gain=1}, true)
			minetest.set_node(pointed_thing.under, {name="mcl_deepslate:deepslate_cobbled"})
        end

		if node.name == "mcl_deepslate:deepslate_cobbled" then
			minetest.sound_play({name="zap_off", pos=pos, gain=1}, true)
			minetest.set_node(pointed_thing.under, {name="mcl_core:cobble"})
        end


		if node.name == "mcl_core:stone" then
			minetest.set_node(pointed_thing.under, {name="mcl_deepslate:deepslate"})
			minetest.sound_play({name="zap_on", pos=pos, gain=1}, true)            
		end

		if node.name == "mcl_deepslate:deepslate" then
			minetest.set_node(pointed_thing.under, {name="mcl_core:stone"})
			minetest.sound_play({name="zap_off", pos=pos, gain=1}, true)            
		end


		return itemstack
	end

--register Orb of Exchange
minetest.register_tool("mcl_transmutation:orb_of_exchange", {
	description = "Orb of Exchange",
	inventory_image = "mcl_transmutation_orb_of_exchange.png",
	wield_scale = wield_scale,
	groups = { tool=1},
	on_place = exchange_node,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	})
