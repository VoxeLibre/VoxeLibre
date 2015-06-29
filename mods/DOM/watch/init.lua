--[[
  DOM, renew of the watch mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--


--Rotinas usadas pelo mod
dofile(minetest.get_modpath("watch").."/rotinas.lua")

--Declarações dos objetos
dofile(minetest.get_modpath("watch").."/itens.lua")

-- Apenas para indicar que este módulo foi completamente carregado.
DOM_mb(minetest.get_current_modname(),minetest.get_modpath(minetest.get_current_modname()))
