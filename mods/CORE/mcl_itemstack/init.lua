MCLItemStack = class()

function MCLItemStack:constructor(stack)
	self.stack = stack
end

MCLItemStack:__getter("enchantments", function(self)
	return mcl_enchanting.get_enchantments(self.stack)
end)
MCLItemStack:__comparator("enchantments", mcl_types.match_enchantments)

function MCLItemStack:meta()
	return self.stack:get_meta()
end
MCLItemStack:__comparator("meta", mcl_types.match_meta)

function MCLItemStack:get_enchantment(name)
	return self:enchantments()[name] or 0
end

function MCLItemStack:has_enchantment(name)
	return self:get_enchantment(name) > 0
end

function MCLItemStack:total_durability()
end

function MCLItemStack:durability()
	local def = self.stack:get_definition()
	if def then
		local base_uses = def._durability

	end
end

function MCLItemStack:use_durability()
end

function MCLItemStack:restore_durability()
end

function MCLItemStack:get_group()
end
