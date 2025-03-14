local fake_metadata_ref_metatable = {
	__index = {
		get_string = function(self, key)
			return tostring(self.table[tostring(key)] or "")
		end,
		set_string = function(self, key, value)
			if self.readonly then return end

			self.table[tostring(key)] = tostring(value)
			self:on_save()
		end,
	},
}

---@param data {table: table, on_save: fun(any)}
---@return core.MetaDataRef
function mcl_util.make_fake_metadata(data)
	-- Validate argument
	assert(type(data.table) == "table", "Fake metadata requires a 'table' field that is a table")
	if not data.readonly then
		assert(type(data.on_save) == "function", "Writable fake metadata requires an 'on_save' field that is a function")
	end

	return setmetatable(data, fake_metadata_ref_metatable)
end
