--- Created by SmokeyDope
--- See License.txt and Additional Terms.txt for licensing.
--- If you did not receive a copy of the license with this content package, please see:
--- https://www.gnu.org/licenses/gpl-3.0.en.html and https://creativecommons.org/licenses/by-sa/4.0/

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_tools = vl_tools or {}

function vl_tools.build_tool_def(def, defaults)
	local tool_def = table.copy(defaults or {})

	tool_def.description = def.description
	tool_def._doc_items_hidden = def._doc_items_hidden
	tool_def.inventory_image = def.icon
	tool_def._repair_material = def.repair_material
	tool_def._mcl_upgradable = def._mcl_upgradable
	tool_def._mcl_upgrade_item = def._mcl_upgrade_item

	tool_def.groups = table.update(table.copy((defaults or {}).groups or {}), def.groups or {})
	tool_def.tool_capabilities = table.update(table.copy((defaults or {}).tool_capabilities or {}), def.tool_capabilities or {})
	tool_def._mcl_diggroups = table.update(table.copy((defaults or {})._mcl_diggroups or {}), def._mcl_diggroups or {})

	return table.update(tool_def, def.overrides or {})
end

dofile(modpath.."/axe.lua")
dofile(modpath.."/pickaxe.lua")

dofile(modpath.."/shears.lua")
dofile(modpath.."/shovel.lua")
dofile(modpath.."/hoe.lua")

--[[

unused/wip placeholder lua files for future foreseeable utilities and general callable API-ification if the need arises for other tool uses.

dofile(modpath.."/hammer.lua")
dofile(modpath.."/bucket.lua")
dofile(modpath.."/shield.lua")
dofile(modpath.."/spear.lua")
]]
