-- Updates all values in t using values from to*.
function table.update(t, ...)
	for _, to in ipairs {...} do
		for k, v in pairs(to) do
			t[k] = v
		end
	end
	return t
end

-- Updates nil values in t using values from to*.
function table.update_nil(t, ...)
	for _, to in ipairs {...} do
		for k, v in pairs(to) do
			if t[k] == nil then
				t[k] = v
			end
		end
	end
	return t
end

---Works the same as `pairs`, but order returned by keys
---
---Taken from https://www.lua.org/pil/19.3.html
---@generic T: table, K, V, C
---@param t T
---@param f? fun(a: C, b: C):boolean
---@return fun():K, V
function table.pairs_by_keys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)

	local i = 0        -- iterator variable
	local function iter() -- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

---@param a table
---@param b table
---@return table
function table.intersect(a, b)
	local values_map = {}

	for _,v in pairs(a) do values_map[v] = 1 end

	-- Get all the values that are in both tables
	local result = {}
	for _,v in pairs(b) do
		if values_map[v] then
			result[#result + 1] = v
		end
	end
	return result
end

-- Removes one element randomly selected from the array section of the table and
-- returns it, or nil if there are no elements in the array section of the table
function table.remove_random_element(table)
	local count = #table
	if count == 0 then return nil end

	local idx = math.random(count)
	local res = table[idx]
	table[idx] = table[count]
	table[count] = nil
	count = count - 1
	return res
end

--- Searches for strings beginning with n in array part of the table h
---@param n string
---@param h string[]
---@return boolean|string[]
function mcl_util.search_in_table(n, h)
	local l = string.len(n)
	local found = {}
	for _, v in ipairs(h) do
		if string.sub(v, 1, l) == n then
			table.insert(found, v)
		end
	end
	if #found > 1 then return found
	elseif #found == 1 then return found[1]
	else return false end
end
