local S = core.get_translator(core.get_current_modname())

local math = math

local YAW_OFFSET = -math.pi/2

local function arrow_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return {"mcl_bows_arrow.png^(mcl_bows_arrow_overlay.png^[colorize:"..colorstring..":"..tostring(opacity)..")"}
end

local how_to_shoot = core.registered_items["mcl_bows:arrow"]._doc_items_usagehelp

local arrow_longdesc = core.registered_items["mcl_bows:arrow"]._doc_items_longdesc or ""
local arrow_tt = core.registered_items["mcl_bows:arrow"]._tt_help or ""

function mcl_potions.register_arrow(name, desc, color, def)
	local longdesc = def._longdesc or ""
	local tt = def._tt or ""
	local groups = {ammo=1, ammo_bow=1, brewitem=1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end
	local arrow_item = minetest.get_current_modname()..":"..name.."_arrow"
	core.register_craftitem(arrow_item, {
		description = desc,
		_tt_help = arrow_tt .. "\n" .. tt,
		_dynamic_tt = def._dynamic_tt,
		_doc_items_longdesc = arrow_longdesc .. "\n" ..
			S("This particular arrow is tipped and will give an effect when it hits a player or mob.") .. "\n" ..
			longdesc,
		_doc_items_usagehelp = how_to_shoot,
		_effect_list = def._effect_list,
		uses_level = def.uses_level,
		has_potent = def.has_potent,
		has_plus = def.has_plus,
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		inventory_image = "mcl_bows_arrow_inv.png^(mcl_potions_arrow_inv.png^[colorize:"..color..":100)",
		groups = groups,
		_on_dispense = function(itemstack, dispenserpos, droppos, dropnode, dropdir)
			-- Shoot arrow
			local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
			local yaw = math.atan2(dropdir.z, dropdir.x) + YAW_OFFSET
			mcl_bows.shoot_arrow(itemstack:get_name(), shootpos, dropdir, yaw, nil, 19, 3)
		end,
		_arrow_image = arrow_image(color, 100),
		_on_collide_with_entity = function(self, pos, obj)
			local potency = self._potency or 0
			local plus = self._plus or 0

			if def._effect_list then
				for name, details in pairs(def._effect_list) do
					local ef_level = details.level
					if details.uses_level then
						ef_level = details.level + details.level_scaling * potency
					end

					local dur = details.dur
					if details.dur_variable then
						dur = details.dur * math.pow(mcl_potions.PLUS_FACTOR, plus)
						if potency>0 and details.uses_level then
							dur = dur / math.pow(mcl_potions.POTENT_FACTOR, potency)
						end
					end
					dur = dur * mcl_potions.SPLASH_FACTOR

					if details.effect_stacks then
						ef_level = ef_level + mcl_potions.get_effect_level(obj, name)
					end
					mcl_potions.give_effect_by_level(name, obj, ef_level, dur)
				end
			end
			if def.custom_effect then def.custom_effect(obj, potency+1, plus) end
		end,
	})

	-- Entity for older-style arrows
	local arrow_entity = table.copy(mcl_bows.arrow_entity)
	arrow_entity.on_activate = function(self, staticdata, dtime_s)
		mcl_bows.arrow_entity.on_activate(self, staticdata, dtime_s)
		self._arrow_item = arrow_item
	end
	vl_projectile.register(arrow_item.."_entity", arrow_entity)

	if core.get_modpath("mcl_bows") then
		core.register_craft({
			output = arrow_item.." 8",
			recipe = {
				{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"},
				{"mcl_bows:arrow",minetest.get_current_modname()..":"..name.."_lingering","mcl_bows:arrow"},
				{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"}
			}
		})
	end

	if core.get_modpath("doc_identifier") then
		doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
	end
end
