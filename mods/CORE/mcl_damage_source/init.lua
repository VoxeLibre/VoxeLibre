MCLDamageSource = class()

function MCLDamageSource:constructor(tbl, hitter)
	for k, v in pairs(tbl or {}) do
		self[k] = v
	end
	self.hitter = hitter
end

MCLDamageSource:__getter("direct_object", function(self)
	local hitter = self.hitter
	if not hitter then
		return
	end
	return mcl_object_mgr.get(hitter)
end)

MCLDamageSource:__getter("source_object", function(self)
	local direct = self:direct_object()
	if not direct then
		return
	end
	return direct.source_object or direct
end)
