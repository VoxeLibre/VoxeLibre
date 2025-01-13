-- Recursively merge tables with each other
local function table_merge(tbl, ...)
	local t = table.copy(tbl)
	for _, to in ipairs{...} do
		for k,v in pairs(to) do
			if type(t[k]) == "table" and type(v) == "table" then
				t[k] = table_merge(t[k], v)
			else
				t[k] = v
			end
		end
	end
	return t
end

-- Queue class
--
-- The queue class is using clever tricks to avoid allocating more memory than
-- needed. It stores its back and front index are stored in the same table as
-- the elements.
-- * index 1: the queue's front
-- * index 2: the queue's back
--
-- orig: <https://codeberg.org/mineclonia/mineclonia/src/commit/1b6364cd22/mods/CORE/mcl_util/init.lua#L1384>
--       by ryvnf and xXx_GLOCKrzmitz_xXx
local queue_class = {
	enqueue = function(self, value)
		self[self[1]] = value
		self[1] = self[1] + 1
	end,

	dequeue = function(self)
		local value = self[self[2]]
		if value == nil then
			return
		end
		self[self[2]] = nil
		self[2] = self[2] + 1
		return value
	end,

	size = function(self)
		return self[1] - self[2]
	end,

	iterate = function(self)
		local idx = self[2] - 1
		return function()
			idx = idx + 1
			if self[1] <= idx then
				return nil
			end
			return self[idx]
		end
	end
}

queue_class.__index = queue_class

local function queue()
	return setmetatable({3, 3}, queue_class)
end

return table_merge, queue
