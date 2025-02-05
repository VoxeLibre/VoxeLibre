local lunajson = require('lunajson')
local os = require('os')

local file = io.open("./log/check.json")
assert(file, "File `./log/check.json' doesn't exist. Did you run lua-language-server --check?")
local str = file:read("*all")
local data = lunajson.decode(str)

-- Display findings
local has_finding = false
for file,findings in pairs(data) do
	for _,finding in ipairs(findings) do
		print(file:gsub("file://","")..":"..(finding.range.start.line + 1)..": "..finding.message)
		has_finding = true
	end
end

-- Report success or failure
os.exit(has_finding and 1 or 0)
