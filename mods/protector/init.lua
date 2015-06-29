minetest.register_privilege("delprotect","Delete other's protection")

protector = {}

protector.get_member_list = function(meta)
	local s = meta:get_string("members")
	local list = s:split(" ")
	return list
end

protector.set_member_list = function(meta, list)
	meta:set_string("members", table.concat(list, " "))
end

protector.is_member = function (meta, name)
	local list = protector.get_member_list(meta)
	for _, n in ipairs(list) do
		if n == name then
			return true
		end
	end
	return false
end

protector.add_member = function(meta, name)
	if protector.is_member(meta, name) then return end
	local list = protector.get_member_list(meta)
	table.insert(list,name)
	protector.set_member_list(meta,list)
end

protector.del_member = function(meta,name)
	local list = protector.get_member_list(meta)
	for i, n in ipairs(list) do
		if n == name then
			table.remove(list, i)
			break
		end
	end
	protector.set_member_list(meta,list)
end

-- Protector Interface

protector.generate_formspec = function(meta)
	if meta:get_int("page") == nil then meta:set_int("page",0) end
	local formspec = "size[8,7]"
		.."label[0,0;-- Protector interface --]"
		.."label[0,1;Punch node to show protected area]"
		.."label[0,2;Members: (type nick, press Enter to add)]"
	members = protector.get_member_list(meta)
	
	local npp = 12 -- was 15, names per page, for the moment is 4*4 (-1 for the + button)
	local s = 0
	local i = 0
	for _, member in ipairs(members) do
		if s < meta:get_int("page")*15 then s = s +1 else
			if i < npp then
				formspec = formspec .. "button["..(i%4*2)..","
				..math.floor(i/4+3)..";1.5,.5;protector_member;"..member.."]"
				formspec = formspec .. "button["..(i%4*2+1.25)..","
				..math.floor(i/4+3)..";.75,.5;protector_del_member_"..member..";X]"
			end
			i = i +1
		end
	end
	local add_i = i
	if add_i < npp then
		formspec = formspec
		.."field["..(add_i%4*2+1/3)..","..(math.floor(add_i/4+3)+1/3)..";1.433,.5;protector_add_member;;]"
	end
	               		formspec = formspec.."button_exit[1,6.2;2,0.5;close_me;<< Back]"
	return formspec
end

-- ACTUAL PROTECTION SECTION

-- r: radius to check for protects
-- Infolevel:
-- * 0 for no info
-- * 1 for "This area is owned by <owner> !" if you can't dig
-- * 2 for "This area is owned by <owner>.
--   Members are: <members>.", even if you can dig

protector.can_dig = function(r,pos,digger,onlyowner,infolevel)

	if not digger then
		return false
	end

	local whois = digger

	-- Delprotect privileged users can override protections

	if minetest.check_player_privs(whois, {delprotect=true}) and infolevel < 3 then
		return true
	end

	if infolevel == 3 then infolevel = 1 end

	-- Find the protector nodes

	local positions = minetest.find_nodes_in_area(
		{x=pos.x-r, y=pos.y-r, z=pos.z-r},
		{x=pos.x+r, y=pos.y+r, z=pos.z+r},
		"protector:protect")

	for _, pos in ipairs(positions) do
		local meta = minetest.env:get_meta(pos)
		local owner = meta:get_string("owner")

		if owner ~= whois then 
			if onlyowner or not protector.is_member(meta, whois) then
				if infolevel == 1 then
					minetest.chat_send_player(whois, "This area is owned by "..owner.." !")
				elseif infolevel == 2 then
					minetest.chat_send_player(whois,"This area is owned by "..meta:get_string("owner")..".")
					if meta:get_string("members") ~= "" then
						minetest.chat_send_player(whois,"Members: "..meta:get_string("members")..".")
					end
				end
				return false
			end
		end
	end

	if infolevel == 2 then
		if #positions < 1 then
			minetest.chat_send_player(whois,"This area is not protected.")
		else
			local meta = minetest.env:get_meta(positions[1])
			minetest.chat_send_player(whois,"This area is owned by "..meta:get_string("owner")..".")
			if meta:get_string("members") ~= "" then
				minetest.chat_send_player(whois,"Members: "..meta:get_string("members")..".")
			end
		end
		minetest.chat_send_player(whois,"You can build here.")
	end
	return true
end

-- Can node be added or removed, if so return node else true (for protected)

protector.old_is_protected = minetest.is_protected
minetest.is_protected = function(pos, digger)

	if protector.can_dig(5, pos, digger, false, 1) then
		return protector.old_is_protected(pos, digger)
	else
		return true
	end
end

-- Make sure protection block doesn't overlap another block's area

protector.old_node_place = minetest.item_place
function minetest.item_place(itemstack, placer, pointed_thing)

	if itemstack:get_name() == "protector:protect" then
		local pos = pointed_thing.above
		local user = placer:get_player_name()
		if protector.can_dig(10, pos, user, true, 3) then
-- 
		else
			minetest.chat_send_player(placer:get_player_name(),"Overlaps into another protected area")
			return protector.old_node_place(itemstack, placer, pos)
		end
	end

	return protector.old_node_place(itemstack, placer, pointed_thing)
end

-- END

minetest.register_node("protector:protect", {
	description = "Protection",
	tiles = {"protector_top.png","protector_top.png","protector_side.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {dig_immediate=2},
	drawtype = "nodebox",
	node_box = {
		type="fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	},
	selection_box = { type="regular" },
	paramtype = "light",

	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Protection (owned by "..
		meta:get_string("owner")..")")
		meta:set_string("members", "")
	end,

	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end

		protector.can_dig(5,pointed_thing.under,user:get_player_name(),false,2)
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.env:get_meta(pos)
		if protector.can_dig(1,pos,clicker:get_player_name(),true,1) then
			minetest.show_formspec(clicker:get_player_name(), 
			"protector_"..minetest.pos_to_string(pos), protector.generate_formspec(meta)
			)
		end
	end,

	on_punch = function(pos, node, puncher)
		if not protector.can_dig(1,pos,puncher:get_player_name(),true,1) then
			return
		end

		local objs = minetest.env:get_objects_inside_radius(pos,.5)
		minetest.env:add_entity(pos, "protector:display")
		minetest.env:get_node_timer(pos):start(10)
	end,

	on_timer = function(pos)
		local objs = minetest.env:get_objects_inside_radius(pos,.5)
		for _, o in pairs(objs) do
			if (not o:is_player()) and o:get_luaentity().name == "protector:display" then
				o:remove()
			end
		end
	end,
})

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if string.sub(formname,0,string.len("protector_")) == "protector_" then
		local pos_s = string.sub(formname,string.len("protector_")+1)
		local pos = minetest.string_to_pos(pos_s)
		local meta = minetest.env:get_meta(pos)

		if meta:get_int("page") == nil then meta:set_int("page",0) end

		if not protector.can_dig(1,pos,player:get_player_name(),true,1) then
			return
		end

		if fields.protector_add_member then
			for _, i in ipairs(fields.protector_add_member:split(" ")) do
				protector.add_member(meta,i)
			end
		end

		for field, value in pairs(fields) do
			if string.sub(field,0,string.len("protector_del_member_"))=="protector_del_member_" then
				protector.del_member(meta, string.sub(field,string.len("protector_del_member_")+1))
			end
		end

		if fields.protector_page_prev then
			meta:set_int("page",meta:get_int("page")-1)
		end

		if fields.protector_page_next then
			meta:set_int("page",meta:get_int("page")+1)
		end

		if fields.close_me then
			meta:set_int("page",meta:get_int("page"))
			else minetest.show_formspec(player:get_player_name(), formname,	protector.generate_formspec(meta))
		end
	end
end)

minetest.register_craft({
	output = "protector:protect 4",
	recipe = {
		{"default:stone","default:stone","default:stone"},
		{"default:stone","default:steel_ingot","default:stone"},
		{"default:stone","default:stone","default:stone"},
	}
})

minetest.register_entity("protector:display", {
	physical = false,
	collisionbox = {0,0,0,0,0,0},
	visual = "wielditem",
	visual_size = {x=1.0/1.5,y=1.0/1.5}, -- wielditem seems to be scaled to 1.5 times original node size
	textures = {"protector:display_node"},
	on_step = function(self, dtime)
		if minetest.get_node(self.object:getpos()).name ~= "protector:protect" then
			self.object:remove()
			return
		end
	end,
})

-- Display-zone node.
-- Do NOT place the display as a node
-- it is made to be used as an entity (see above)

minetest.register_node("protector:display_node", {
	tiles = {"protector_display.png"},
	use_texture_alpha = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- sides
			{-5.55, -5.55, -5.55, -5.45, 5.55, 5.55},
			{-5.55, -5.55, 5.45, 5.55, 5.55, 5.55},
			{5.45, -5.55, -5.55, 5.55, 5.55, 5.55},
			{-5.55, -5.55, -5.55, 5.55, 5.55, -5.45},
			-- top
			{-5.55, 5.45, -5.55, 5.55, 5.55, 5.55},
			-- bottom
			{-5.55, -5.55, -5.55, 5.55, -5.45, 5.55},
			-- middle (surround protector)
			{-.55,-.55,-.55, .55,.55,.55},
		},
	},
	selection_box = {
		type = "regular",
	},
	paramtype = "light",
	groups = {dig_immediate=3,not_in_creative_inventory=1},
	drop = "",
})