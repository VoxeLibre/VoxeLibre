local fake_meta_data_ref_metatable = {
	__index = {
		get_string = function(self, key)
			return tostring(self.table[tostring(key)] or "")
		end,
		set_string = function(self, key, value)
			self.table[tostring(key)] = tostring(value)
			self:on_save()
		end,
	},
}

---@param data {table: table, on_save: fun(any)}
---@return core.MetaDataRef
function mcl_util.make_fake_meta_data_ref(data)
	-- Validate argument
	assert(type(data.table) == "table", "Fake meta data requires a 'table' field that is a table in order to function")
	assert(data.on_save, "Fake meta data requires an 'on_save' field in order to function")

	return setmetatable(data, fake_meta_data_ref_metatable)
end
