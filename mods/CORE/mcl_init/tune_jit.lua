--- This code is largely based on the work by halon for mineclonia, but encapsulated differently
local luajit_present = core.global_exists("jit")

-- Increased limits for the JIT, as of 2024
-- TODO: re-assess this every year or so, as either upstream Luanti may
-- eventually increase these limits itself, or the luajit libraries increase
-- their parameters - e.g., the openresty version already has increase limits
-- because apparently we can not query the JIT parameters
if luajit_present then
	local status, opt = jit.status()
	if not status then
		core.log("warning", "[mcl_init] LuaJIT appears to be available, but turned off. This will result in degraded performance.")
	end
	jit.opt.start(
		"maxtrace=24000",
		"maxrecord=32000",
		"minstitch=3",
		"maxmcode=163840"
	)
	core.log("action", "[mcl_init] increased LuaJIT parameters. LuaJIT version: "..jit.version.." with flags "..tostring(opt))
else
	core.log("warning", "[mcl_init] LuaJIT not detected - it is strongly recommended to build luanti with LuaJIT for performance reasons!")
end
