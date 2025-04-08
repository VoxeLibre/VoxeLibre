local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- Exchange function using item groups and _mcl_changey_variant field
local function exchange_node(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
 --   local node = minetest.get_node(pointed_thing.under)
    local node_name = minetest.get_node(pointed_thing.under).name
    local noddef = minetest.registered_nodes[node_name]


    -- Preserve default right-click behavior if present
    if placer and not placer:get_player_control().sneak then
        local node_def = minetest.registered_nodes[node.name]
        if node_def and node_def.on_rightclick then
            return node_def.on_rightclick(pos, node, placer, itemstack) or itemstack
        end
    end

    -- Transmutation logic
    local def = minetest.registered_nodes[node.name]
    local node = minetest.get_node(pointed_thing.under)
    local node_name = minetest.get_node(pointed_thing.under).name
    local noddef = minetest.registered_nodes[node_name]

    if noddef._mcl_changey_variant == nil then
		return itemstack
	else
        local target_name = def._mcl_changey_variant
        if target_name then
            minetest.set_node(pos, {name=target_name, param2=node.param2})
            minetest.sound_play({name="zap_on", pos=pos, gain=1}, true)
            itemstack:add_wear(65535 / 65)
        end
    end

    return itemstack
end

-- Register Orb of Exchange tool
minetest.register_tool("vl_exchange_orb:orb_of_exchange", {
    description = "Orb of Exchange",
    inventory_image = "vl_exchange_orb_orb_of_exchange.png",
    groups = {tool=1},
    on_place = exchange_node,
    sound = {breaks = "default_tool_breaks"},
    _mcl_toollike_wield = true,
    uses = 20,
    wield_scale = {x=1.5, y=1.5, z=0.5}
})
