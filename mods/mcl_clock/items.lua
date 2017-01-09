-- Clock recipe
minetest.register_craft({
	description = "Clock",
	output = 'mcl_clock:clock',
	groups = {not_in_creative_inventory=1},
	recipe = {
		{'', 'default:gold_ingot', ''},
		{'default:gold_ingot', 'mesecons:redstone_dust', 'default:gold_ingot'},
		{'', 'default:gold_ingot', ''}
	}
})

-- Clock tool
watch.register_item("mcl_clock:clock", watch.images[1], true)

-- Faces
for a=0,63,1 do
	local b = a
	if b > 31 then
		b = b - 32
	else
		b = b + 32
	end
	watch.register_item("mcl_clock:clock_"..tostring(a), watch.images[b+1], false)
end
