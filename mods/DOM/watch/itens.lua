-- Watch recipe
minetest.register_craft({
  description = "Clock",
  output = 'watch:watch',
  groups = {not_in_creative_inventory=1},
  recipe = {
    {'', 'default:gold_ingot', ''},
    {'default:gold_ingot', 'mesecons:redstone_dust', 'default:gold_ingot'},
    {'', 'default:gold_ingot', ''}
  }
})


--Watch tool
watch.registra_item("watch:watch",watch.images[3],true)

--Faces
for a=0,63,1 do
	local b = a
	if b > 31 then
		b = b - 32
	else
		b = b + 32
	end
	watch.registra_item("watch:watch_"..tostring(a),watch.images[b+1],false)
end
