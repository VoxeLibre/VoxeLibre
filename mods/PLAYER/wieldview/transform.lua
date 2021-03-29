-- Wielded Item Transformations - http://dev.minetest.net/texture

wieldview.register_transform = function(item, rotation)
	wieldview.transform[item] = rotation
end

wieldview.transform = {}

