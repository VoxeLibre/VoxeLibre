--- Created by SmokeyDope
--- See License.txt and Additional Terms.txt for licensing.
--- If you did not receive a copy of the license with this content package, please see:
--- https://www.gnu.org/licenses/gpl-3.0.en.html and https://creativecommons.org/licenses/by-sa/4.0/

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
--focus on these first as they are most relevant for real world use by modders.
dofile(modpath.."/shear-functions.lua")
dofile(modpath.."/shovel-functions.lua")
dofile(modpath.."/hoe-functions.lua")
dofile(modpath.."/axe-functions.lua")

--[[

unused/wip placeholder lua files for future foreseeable utilities and general callable API-ification if the need arises for other tool uses.

dofile(modpath.."/hammer-functions.lua")
dofile(modpath.."/bucket-functions.lua")
dofile(modpath.."/pickaxe-functions.lua")
dofile(modpath.."/shield-functions.lua")
dofile(modpath.."/fishing-rod-functions.lua")
dofile(modpath.."/spear-functions.lua")
]]

--NOTE: desc-strings.lua is meant to make the tools description strings callable so there isn't a need to copy paste them. I think it makes sense in this context. Make sure translations still work.'

--STAGE 1 Collect functions from other mods - done
-- STAGE 2 api-ify & Integrate with other mods
-- STAGE 4 Playtest
--STAGE 5 PR & DOCUMENT DOCUMENT DOCUMENT!!!!@!

--[[

STAGE 1 Strategy: 

collect various tool use functions scattered throughout mcl_tools, mcl_farming, and vl_weaponry.
NOTES:


STAGE 2 Strategy:
start with the simplest/shortest function possible to get a feel for how this will go down and better focus on making everything properly callable. Shear carving function and axe scraping are good cannidates to start with. 


]]
