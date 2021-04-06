local S = minetest.get_translator("mcl_portals")
local storage = mcl_portals.storage

local gateway_positions = {
	{x = 96, y = -26925, z = 0},
	{x = 91, y = -26925, z = 29},
	{x = 77, y = -26925, z = 56},
	{x = 56, y = -26925, z = 77},
	{x = 29, y = -26925, z = 91},
	{x = 0, y = -26925, z = 96},
	{x = -29, y = -26925, z = 91},
	{x = -56, y = -26925, z = 77},
	{x = -77, y = -26925, z = 56},
	{x = -91, y = -26925, z = 29},
	{x = -96, y = -26925, z = 0},
	{x = -91, y = -26925, z = -29},
	{x = -77, y = -26925, z = -56},
	{x = -56, y = -26925, z = -77},
	{x = -29, y = -26925, z = -91},
	{x = 0, y = -26925, z = -96},
	{x = 29, y = -26925, z = -91},
	{x = 56, y = -26925, z = -77},
	{x = 77, y = -26925, z = -56},
	{x = 91, y = -26925, z = -29},
}

function mcl_portals.spawn_gateway_portal()
	local id = storage:get_int("gateway_last_id") + 1
	local pos = gateway_positions[id]
	if not pos then return end
	storage:set_int("gateway_last_id", id)
	mcl_structures.call_struct(vector.add(pos, vector.new(-1, -2, -1)), "end_gateway_portal")
end

local gateway_def = table.copy(minetest.registered_nodes["mcl_portals:portal_end"])
gateway_def.description = S("End Gateway Portal")
gateway_def._tt_help = S("Used to construct end gateway portals")
gateway_def._doc_items_longdesc = S("An End gateway portal teleports creatures and objects to the outer End (and back!).")
gateway_def._doc_items_usagehelp = S("Throw an ender pearl into the portal to teleport. Entering an Gateway portal near the Overworld teleports you to the outer End. At this destination another gateway portal will be constructed, which you can use to get back.")
gateway_def.after_destruct = nil
gateway_def.drawtype = "normal"
gateway_def.node_box = nil
gateway_def.walkable = true
gateway_def.tiles[3] = nil
minetest.register_node("mcl_portals:portal_gateway", gateway_def)
