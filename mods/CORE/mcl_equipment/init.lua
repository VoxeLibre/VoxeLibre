MCLEquipment = class()

function MCLEquipment:constructor(inv, idx)
	self.inv = inv
	self.idx = idx
end

MCLEquipment:__cache_getter("has_main", function(self)
	return self.inv and self.idx and self.inv:get_list("main") and true or false
end)

MCLEquipment:__cache_getter("has_right", function(self)
	return self.inv and self.inv:get_list("right_hand") and true or false
end)

MCLEquipment:__cache_getter("has_left", function(self)
	return self.inv and self.inv:get_list("left_hand") and true or false
end)

MCLEquipment:__cache_getter("has_armor", function(self)
	return self.inv and self.inv:get_list("armor") and true or false
end)

function MCLEquipment:mainhand()
	if self:has_main() then
		return self.inv:get_stack("main", self.idx)
	elseif self:has_right() then
		return self.inv:get_stack("right_hand", 1)
	else
		return ItemStack()
	end
end

MCLEquipment:__setter("mainhand", function(self, new)
	if self:has_main() then
		self.inv:set_stack("main", self.idx, stack)
	elseif self:has_right() then
		self.inv:set_stack("right_hand", 1, stack)
	end
end)

function MCLEquipment:offhand()
	if self:has_left() then
		return self.inv:get_stack("left_hand", 1)
	else
		return ItemStack()
	end
end

MCLEquipment:__setter("offhand", function(self, new)
	if self:has_left() then
		self.inv:set_stack("left_hand", 1, new)
	end
end)

function MCLEquipment:__armor(idx, name)
	self[name] = function(self)
		if self:has_armor() then
			return self.inv:get_stack("armor", idx)
		else
			return ItemStack()
		end
	end

	self:__setter(name, function(self, new)
		if self:has_armor() then
			self.inv:set_stack("armor", idx, new)
		end
	end)
end

local armor_slots = {"head", "chest", "legs", "feet"}

for i, name in ipairs(armor_slots) do
	MCLEquipment:__armor(idx, name)
end

local function insert(tbl, key, stack)
	if stack:get_name() ~= "" then
		tbl[key] = stack
	end
end

function MCLEquipment:get_armor()
	local tbl = {}
	if self:has_armor() then
		for i, name in ipairs(armor_slots) do
			insert(tbl, name, self.inv:get_stack("armor", i))
		end
	end
	return tbl
end

function MCLEquipment:get_all()
	local tbl = {}
	insert(tbl, "mainhand", self:mainhand())
	insert(tbl, "offhand", self:offhand())
	for k, v in pairs(self:get_armor()) do
		tbl[k] = v
	end
	return tbl
end

