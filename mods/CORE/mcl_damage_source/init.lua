MCLDamageSource = class()

function MCLDamageSource:constructor(tbl)
	if tbl then
		for k, v in pairs(tbl) do
			self[k] = v
		end
	end
end

function MCLDamageSource:from_mt(reason)

end

MCLDamageSource:__getter("direct_object", function(self)
	local obj = self.raw_source_object
	if not obj then
		return
	end
	return mcl_object_mgr.get(obj)
end)

MCLDamageSource:__getter("source_object", function(self)
	local direct = self:direct_object()
	if not direct then
		return
	end
	return direct.source_object or direct
end)
