local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class

local MAX_MOB_NAME_LENGTH = 30
local HORNY_TIME = 30
local HORNY_AGAIN_TIME = 300
local CHILD_GROW_TIME = 60*20


-- No-op in MCL2 (capturing mobs is not possible).
-- Provided for compability with Mobs Redo
function mcl_mobs:capture_mob(self, clicker, chance_hand, chance_net, chance_lasso, force_take, replacewith)
	return false
end


-- No-op in MCL2 (protecting mobs is not possible).
function mcl_mobs:protect(self, clicker)
	return false
end


-- feeding, taming and breeding (thanks blert2112)
function mob_class:feed_tame(clicker, feed_count, breed, tame, notake)
	if not self.follow then
		return false
	end
	-- can eat/tame with item in hand
	if self.nofollow or follow_holding(self, clicker) then
		local consume_food = false

		-- tame if not still a baby

		if tame and not self.child then
			if not self.owner or self.owner == "" then
				self.tamed = true
				self.owner = clicker:get_player_name()
				consume_food = true
			end
		end

		-- increase health

		if self.health < self.hp_max and not consume_food then
			consume_food = true
			self.health = math.min(self.health + 4, self.hp_max)

			if self.htimer < 1 then
				self.htimer = 5
			end
			self.object:set_hp(self.health)
		end

		-- make children grow quicker

		if not consume_food and self.child == true then
			consume_food = true
			-- deduct 10% of the time to adulthood
			self.hornytimer = self.hornytimer + ((CHILD_GROW_TIME - self.hornytimer) * 0.1)
		end

		--  breed animals

		if breed and not consume_food and self.hornytimer == 0 and not self.horny then
			self.food = (self.food or 0) + 1
			consume_food = true
			if self.food >= feed_count then
				self.food = 0
				self.horny = true
			end
		end

		self:update_tag()
		-- play a sound if the animal used the item and take the item if not in creative
		if consume_food then
			-- don't consume food if clicker is in creative
			if not minetest.is_creative_enabled(clicker:get_player_name()) and not notake then
				local item = clicker:get_wielded_item()
				item:take_item()
				clicker:set_wielded_item(item)
			end
			-- always play the eat sound if food is used, even in creative
			self:mob_sound("eat", nil, true)

		else
			-- make sound when the mob doesn't want food
			self:mob_sound("random", true)
		end
		return true
	end
	return false
end

-- Spawn a child
function mcl_mobs.spawn_child(pos, mob_type)
	local child = minetest.add_entity(pos, mob_type)
	if not child then
		return
	end

	local ent = child:get_luaentity()
	mcl_mobs.effect(pos, 15, "mcl_particles_smoke.png", 1, 2, 2, 15, 5)

	ent.child = true

	local textures
	-- using specific child texture (if found)
	if ent.child_texture then
		textures = ent.child_texture[1]
	end

	-- and resize to half height
	child:set_properties({
		textures = textures,
		visual_size = {
			x = ent.base_size.x * .5,
			y = ent.base_size.y * .5,
		},
		collisionbox = {
			ent.base_colbox[1] * .5,
			ent.base_colbox[2] * .5,
			ent.base_colbox[3] * .5,
			ent.base_colbox[4] * .5,
			ent.base_colbox[5] * .5,
			ent.base_colbox[6] * .5,
		},
		selectionbox = {
			ent.base_selbox[1] * .5,
			ent.base_selbox[2] * .5,
			ent.base_selbox[3] * .5,
			ent.base_selbox[4] * .5,
			ent.base_selbox[5] * .5,
			ent.base_selbox[6] * .5,
		},
	})

	ent.animation = ent._child_animations
	ent._current_animation = nil
	ent:set_animation("stand")

	return child
end
