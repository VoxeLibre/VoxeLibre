---@class amt_queue.Queue
---@field mask number
---@field size number

---@class amt_queue.Item
---@field next amt_queue.Item?
---@field last amt_queue.Item?

local one_over_log2 = 1.0 / math.log(2)
function bit.lsb(v)
	local k = bit.band(v, bit.bnot(v-1))
	return math.log(k) * one_over_log2
end

local math_floor = math.floor

local dummy = {rotate = 0, mask = 0}
---@param self amt_queue.Queue
---@param size number
---@param offset number
---@return number
local get_absolute_offset = function(self, size, offset)
	local block_rotate_size = 1
	local block_start_offset = 0
	for level=1,30 do
		local rotate = (self[level] or dummy).rotate
		offset = offset + rotate * block_rotate_size

		-- Return if this offset is inside this block
		if offset - block_start_offset < block_rotate_size * size then
			return offset
		end

		block_rotate_size = block_rotate_size * size
		block_start_offset = block_start_offset + block_rotate_size
	end
	error("Unable to get abolute offset for relative offset "..tostring(offset))
end

amt_queue = {}
local metatable = { __index = amt_queue }
local zero_schedule = {0}

---@param size number
---@return amt_queue.Queue
function amt_queue.new(size)
	size = size or 30
	assert(size <= 30, tostring(size).." exceeds maximum amt_queue size of 30")
	local pc = {size = size, mask = 0}
	setmetatable(pc, metatable)
	return pc
end

---@param self amt_queue.Queue
---@param item amt_queue.Item
function amt_queue.insert(self, item, offset)
	local size = self.size
	offset = get_absolute_offset(self, size, offset)

	local schedule
	if offset == 0 then
		schedule = zero_schedule
	else
		schedule = {}
		local first = true
		while offset > 0 do
			if not first then
				offset = offset - 1
			end
			first = false
			schedule[#schedule + 1] = offset % size
			offset = math_floor(offset / size)
		end
	end

	local section = self[#schedule] or {rotate = 0, mask = 0}
	self[#schedule] = section
	self.mask = bit.bor(self.mask, bit.lshift(1,#schedule - 1))

	for i=#schedule,2,-1 do
		local s = schedule[i]

		local next_section = section[s] or {rotate = 0, mask = 0}
		section[s] = next_section
		section.mask = bit.bor(section.mask, bit.lshift(1,s))
		section = next_section
	end

	local s = schedule[1]
	local next_item = section[s]
	item.next = next_item
	if next_item then
		item.last = next_item.last
		--next_item.prev = item
	else
		item.last = item
	end
	section.mask = bit.bor(section.mask, bit.lshift(1,s))
	section[s] = item
end

---@param self amt_queue.Queue
---@param level number
local function pop_from_level(self, level)
	local level_table = self[level] or {rotate = 0, mask = 0}

	local offset = level_table.rotate
	local res = level_table[offset]
	level_table[offset] = nil
	level_table.mask = bit.band(level_table.mask, bit.bnot(bit.lshift(1,offset)))
	level_table.rotate = offset + 1
	self[level] = level_table
	local level_bit = bit.lshift(1, level - 1)
	if level_table.mask == 0 then
		self.mask = bit.band(self.mask, bit.bnot(level_bit))
	else
		self.mask = bit.bor(self.mask, level_bit)
	end

	if offset == self.size - 1 then
		self[level] = pop_from_level(self, level+1)
	end

	return res
end

function amt_queue.pop(self)
	return pop_from_level(self, 1)
end
local function has_items(self)
	return self.mask ~= 0
end
amt_queue.has_items = has_items

local function iterate_items(self, i)
	return nil, nil
end
local function items(self)
	return iterate_items, self, nil
end
amt_queue.items = items

function amt_queue.advance_to_next(self)
	if self.mask == 0 then return end

	local level = bit.lsb(self.mask) + 1
	local level_table = self[level] or dummy
	level_table.rotate = bit.lsb(level_table.mask)

	for i = (level-1),1,-1 do
		level_table = self[i]
		if level_table then
			level_table.rotate = self.size - 1
		else
			self[i] = {mask = 0, rotate = self.size - 1}
		end
		local new_level_table = pop_from_level(self, i+1)
		if new_level_table then
			new_level_table.rotate = bit.lsb(new_level_table.mask)
		end
		self[i] = new_level_table
	end
end

return amt_queue
