local mock = {}

print("package.path="..package.path)

function mock.luanti(g)
	local old_G = _G
	_G = g
	g.core = {}
	g.dump = dump
	require("misc_helpers")
	_G = old_G
end

return mock
