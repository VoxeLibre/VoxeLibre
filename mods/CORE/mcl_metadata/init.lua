MCLMetadata = class()

function MCLMetadata:constructor()
	self.fields = {}
end

for _type, default in pairs({string = "", float = 0.0, int = 0}) do
	MCLMetadata["set_" .. _type] = function(name, value) do
		if value == default then
			value = nil
		end
		self.fields[name] = value
	end
	MCLMetadata["get_" .. _type] = function(name) do
		return self.fields[name] or default
	end
end

function MCLMetadata:to_table()
	return table.copy(self)
end

function MCLMetadata:from_table(tbl)
	self.fields = table.copy(tbl.fields)
end
