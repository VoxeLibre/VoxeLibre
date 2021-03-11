local Object = {}

function Object:__define_getter(name, cached, get, cmp)
	local key = "_" .. name
	self[name] = function (self, expected)
		local value

		if cached then
			value = self[key]
		end

		if not value then
			value = get(self)
		end

		if cached then
			self[key] =	value
		end

		if expected ~= nil then
			if cmp then
				return cmp(value, expected)
			else
				return value == expected
			end
		else
			return value
		end
	end
end

function class(super)
	return setmetatable({}, {
		__call = function(_class, ...)
			local instance = setmetatable({}, {
				__index = _class,
			})
			if instance.constructor then
				instance:constructor(...)
			end
			return instance
		end,
		__index = super or Object,
	})
end
