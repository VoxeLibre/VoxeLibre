local S = minetest.get_translator(minetest.get_current_modname())

-- Liquids: River Water

local source = table.copy(minetest.registered_nodes["mcl_core:water_source"])
source.description = S("River Water Source")
source.liquid_range = 2
source.waving = 3
source.color = "#0084FF"
source.paramtype2 = nil
source.palette = nil
source.liquid_alternative_flowing = "mclx_core:river_water_flowing"
source.liquid_alternative_source = "mclx_core:river_water_source"
source.liquid_renewable = false
source._doc_items_longdesc = S("River water has the same properties as water, but has a reduced flowing distance and is not renewable.")
source._doc_items_entry_name = S("River Water")
-- Auto-expose entry only in valleys mapgen
source._doc_items_hidden = minetest.get_mapgen_setting("mg_name") ~= "valleys"
source.post_effect_color = {a=60, r=0, g=132, b=255}

local flowing = table.copy(minetest.registered_nodes["mcl_core:water_flowing"])
flowing.description = S("Flowing River Water")
flowing.liquid_range = 2
flowing.waving = 3
flowing.color = "#0084FF"
flowing.liquid_alternative_flowing = "mclx_core:river_water_flowing"
flowing.liquid_alternative_source = "mclx_core:river_water_source"
flowing.liquid_renewable = false
flowing.post_effect_color = {a=60, r=0, g=132, b=255}

minetest.register_node("mclx_core:river_water_source", source)
minetest.register_node("mclx_core:river_water_flowing", flowing)

if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mclx_core:river_water_source", "nodes", "mclx_core:river_water_flowing")
end
