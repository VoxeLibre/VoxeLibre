--[[
  DOM, renew of the watch mod

  Original from Echo, here: http://forum.minetest.net/viewtopic.php?id=3795
]]--

watch = {}
watch.ultimo_tempo = -1

-- Image of all 12 possible faces, only cover hours, a day is to short to lost time with game minutes...  :-P
watch.images_a = {
    "watch_a0.png",
    "watch_a1.png",
    "watch_a2.png",
    "watch_a3.png",
    "watch_a4.png",
    "watch_a5.png",
    "watch_a6.png",
    "watch_a7.png",
    "watch_a8.png",
    "watch_a9.png",
    "watch_a10.png",
    "watch_a11.png",
}
watch.images_d={
    "watch_d0.png",
    "watch_d1.png",
    "watch_d2.png",
    "watch_d3.png",
    "watch_d4.png",
    "watch_d5.png",
    "watch_d6.png",
    "watch_d7.png",
    "watch_d8.png",
    "watch_d9.png",
    "watch_d10.png",
    "watch_d11.png",
}

--Catch the sever time and convert to hour, 12000 = 12h = 0.5, 6000 = 6h = 0.25
function watch.pega_hora(tipo)
  local tempo_r = "12:00"
  local t = minetest.env:get_timeofday()
  local tempo = t*24 -- Get the time
  local tempo_h = math.floor(tempo) -- Get 24h only, losting minutes
  local tempo_m =math.floor((tempo - tempo_h)*60) --Get only minutes

  --Hour
  tempo_h_12=tempo_h
  if tempo_h > 12 then -- Converte time to time in 12h format
    tempo_h_12 = tempo_h - 12
  end

  if tipo==2 then -- hh
    return(tostring(tempo_h_12))
  end

  tempo_r = tostring(tempo_h) .. ":"

  --Minutes  
  if tempo_m < 10 then -- Add a zero at left if need.
    tempo_r = tempo_r .. "0"
  end
  tempo_r = tempo_r .. tostring(tempo_m)

  return(tempo_r) --HH:MM
end

--When someone try use the watch.
function watch.usa (itemstack, user, pointed_thing)
  item=itemstack:to_table()
  local meta=DOM_get_item_meta(item)
  local w_type="a"

  if meta~=nil then
    w_type = meta["w_type"]
  end

--DOM_inspeciona_r("Valores no meta:"..dump(meta))
  --print("Relógio em modo: "..w_type)
  meta["time"] = watch.pega_hora(1)
  meta["w_type"] = w_type
  DOM_set_item_meta(item, meta)
  meta=DOM_get_item_meta(item)
--DOM_inspeciona_r("Valores no meta:"..dump(meta))
  minetest.chat_send_player(user:get_player_name(), "[Watch] Time now is:" .. meta["time"])

  itemstack:replace(item)

  return itemstack
end

-- Register itens
function watch.registra_item(nome,imagem,aparece_nas_receitas)
  local g = 1
  if aparece_nas_receitas then
    g = 0
  end

--DOM_inspeciona_r("Registrando item "..nome..","..imagem)
  minetest.register_tool(nome, {
    description = "Watch",
    inventory_image = imagem,
    groups = {not_in_creative_inventory=g},
    metadata = {w_type="d"},
    wield_image = "",
    stack_max = 1,
    on_use = watch.usa,
  })
end

minetest.register_globalstep(function(dtime)
  local t="a" -- d to digital, a to analogic

  now = watch.pega_hora(2)
--DOM_inspeciona_r("Hora:"..now)
  if now == "12" then now = "0" end

  if watch.ultimo_tempo == now then
    return
  end

  watch.ultimo_tempo = now


  local players  = minetest.get_connected_players()
  for i,player in ipairs(players) do

    if string.sub(player:get_wielded_item():get_name(), 0, 11) == "watch:watch" then
      player:set_wielded_item("watch:watch_"..t..now)
    end
    for i,stack in ipairs(player:get_inventory():get_list("main")) do
      if i<9 and string.sub(stack:get_name(), 0, 11) == "watch:watch" then
        player:get_inventory():remove_item("main", stack:get_name())
        player:get_inventory():add_item("main", "watch:watch_"..t..now)
      end
    end
  end
end)
