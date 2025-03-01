local lunajson = require('lunajson')
local os = require('os')

local file = io.open("./log/check.json")
assert(file, "File `./log/check.json' doesn't exist. Did you run lua-language-server --check?")
local str = file:read("*all")
local data = lunajson.decode(str)

local f = io.open("tests/lua-language-server/check.lst","r")
local allow_findings = false
if f then
	allow_findings = {}
	for line in f:lines() do
		line = line:gsub("\n",""):gsub(" ","")
		allow_findings[line] = true
	end
	f:close()
end

-- Display findings
local has_finding = false
for file,findings in pairs(data) do
	file = file:gsub("file://","")
	for _,finding in ipairs(findings) do
		local prefix = "Warning"
		if allow_findings and allow_findings[file] then
			has_finding = true
			prefix = "Error"
		end
		print(prefix..": "..file..":"..(finding.range.start.line + 1)..": "..finding.message)
	end
end

-- Report success or failure
if has_finding then
	print("At least one error has been detected")
	os.exit(1)
else
	print("No errors found")
	os.exit(0)
end
