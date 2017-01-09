--[[
  DOM, renew of the watch mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--

watch = {}
watch.ultimo_tempo = -1

-- Image of all 64 possible faces
watch.images = {}
for frame=0,63 do
	table.insert(watch.images, "clock_clock.png^[verticalframe:64:"..frame)
end

local function round(num)
  return math.floor(num + 0.5)
end

function watch.pega_hora()
  local t = 64 * minetest.get_timeofday()
  return tostring(round(t))
end

-- Register itens
function watch.registra_item(nome,imagem,aparece_nas_receitas)
  local g = 1
  if aparece_nas_receitas then
    g = 0
  end

  minetest.register_tool(nome, {
    description = "Clock",
    inventory_image = imagem,
    groups = {not_in_creative_inventory=g},
    metadata = {w_type="d"},
    wield_image = "",
    stack_max = 1,
  })
end

minetest.register_globalstep(function(dtime)

  local now = watch.pega_hora()

  if watch.ultimo_tempo == now then
--    return
  end

  watch.ultimo_tempo = now

  local players = minetest.get_connected_players()
  for i,player in ipairs(players) do

    if string.sub(player:get_wielded_item():get_name(), 0, 63) == "watch:watch" then
      player:set_wielded_item("watch:watch_"..now)
    end
    for i,stack in ipairs(player:get_inventory():get_list("main")) do
      if i<10 and string.sub(stack:get_name(), 0, 11) == "watch:watch" then
        player:get_inventory():remove_item("main", stack:get_name())
        player:get_inventory():add_item("main", "watch:watch_"..now)
      end
    end
  end
end)
