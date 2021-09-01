function mcl_mobs.mob:drop_loot(reason)
	if self.data.baby and self.def.type ~= "monster" then
		return
	end

	local enchantments = reason.source and mcl_enchanting.get_enchantments(mcl_util.get_wield_item(reason.source)) or {}

	local cooked = self.data.burn_time or enchantments.fire_aspect
	local looting = enchantments.looting or 0

	mcl_experience.throw_experience(self.object:get_pos(), math.random(self.def.xp_min, self.def.xp_max))

	local pos = self.object:get_pos()

	for _, dropdef in pairs(self:evaluate("drops")) do
		local chance = 1 / dropdef.chance
		local looting_type = dropdef.looting

		if looting > 0 then
			local chance_function = dropdef.looting_chance_function
			if chance_function then
				chance = chance_function(looting_level)
			elseif looting_type == "rare" then
				chance = chance + (dropdef.looting_factor or 0.01) * looting_level
			end
		end

		local count = 0

		local do_common_looting = looting > 0 and looting_type == "common"

		if math.random() < chance then
			num = math.random(dropdef.min or 1, dropdef.max or 1)
		elseif not dropdef.looting_ignore_chance then
			do_common_looting = false
		end

		if do_common_looting then
			num = num + math.floor(math.random(0, looting_level) + 0.5)
		end

		if count > 0 then
			local item = dropdef.name

			if cooked and dropdef.cookable then
				local output = minetest.get_craft_result({method = "cooking", width = 1, items = {item}})

				if output and output.item and not output.item:is_empty() then
					item = output.item:get_name()
				end
			end

			for x = 1, count do
				minetest.add_item(pos, ItemStack(item)):set_velocity({
					x = math.random(-10, 10) / 9,
					y = 6,
					z = math.random(-10, 10) / 9,
				})
			end
		end
	end
end
