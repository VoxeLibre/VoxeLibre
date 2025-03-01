local lunajson = require('lunajson')
local os = require('os')

local file = io.open("./log/check.json")
assert(file, "File `./log/check.json' doesn't exist. Did you run lua-language-server --check?")
local str = file:read("*all")
local data = lunajson.decode(str)

local f = io.open("tests/lua-language-server/checks.lst","r")
local allow_findings = false
if f then
	allow_findings = {}
	for line in f:lines() do
		allow_findings[line] = true
	end
	f:close()
end

-- Display findings
local has_finding = false
for file,findings in pairs(data) do
	file = file:gsub("file://","")
	for _,finding in ipairs(findings) do
		print(file..":"..(finding.range.start.line + 1)..": "..finding.message)
		if allow_findings and allow_findings[file] then
			has_finding = true
		end
	end
end

-- Report success or failure
os.exit(has_finding and 1 or 0)
