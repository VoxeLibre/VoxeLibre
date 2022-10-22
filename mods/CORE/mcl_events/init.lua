mcl_events = {}
mcl_events.registered_events = {}
local active_events = {}

local tpl_eventdef = {
	stage = 1,
	max_stage = 1,
	--pos = vector.zero(),
	--time_start = 0,
	completed = false,
	cond_start = function(event) end, --return table of positions
	on_step = function(event) end,
	on_start = function(event) end,
	on_stage_begin = function(event) end,
	cond_progress = function(event) end, --return next stage
	cond_complete = function(event) end, --return success
}

function mcl_events.register_event(name,def)
	mcl_events.registered_events[name] = {}
	--setmetatable(mcl_events.registered_events[name],tpl_eventdef)
	mcl_events.registered_events[name] = def
	mcl_events.registered_events[name].name = name
end

local function start_event(p,e)
	minetest.log("event started: "..e.name.." at "..minetest.pos_to_string(p))
	local idx = #active_events + 1
	active_events[idx] = table.copy(e)
	setmetatable(active_events[idx],e)
	active_events[idx].pos = vector.copy(p)
	active_events[idx].stage = 1
	active_events[idx].time_start = os.time()
	active_events[idx]:on_start(p)
end

local function finish_event(self,idx)
	minetest.log("event finished: "..self.name.." at "..minetest.pos_to_string(self.pos))
	if self.on_complete then self:on_complete() end
	table.remove(active_events,idx)
end

local etime = 0
function check_events(dtime)
	for idx,ae in pairs(active_events) do
		if ae.cond_complete and ae:cond_complete() then
			ae.finished = true
			finish_event(ae,idx)
		elseif not ae.cond_complete and ae.max_stage and ae.max_stage <= ae.stage then
			ae.finished = true
			finish_event(ae,idx)
		elseif not ae.finished and ae.cond_progress then
			local p = ae:cond_progress()
			if p == true then
				ae.stage = ae.stage + 1
				minetest.log("event progressed to stage "..ae.stage)
				ae:on_stage_begin()
			elseif tonumber(p) then
				ae.stage = tonumber(p) or ae.stage + 1
				minetest.log("event progressed to stage "..ae.stage)
				ae:on_stage_begin()
			end
		elseif not ae.finished and ae.on_step then
			ae:on_step()
		end
	end
	etime = etime - dtime
	if etime > 0 then return end
	etime = 10
	for _,e in pairs(mcl_events.registered_events) do
		local pp = e.cond_start()
		if pp then
			for _,p in pairs(pp) do
				start_event(p,e)
			end
		end
	end
end

minetest.register_globalstep(check_events)

mcl_events.register_event("infestation",{
	max_stage = 5,
	cond_start  = function(self)
		local r = {}
		for _,p in pairs(minetest.get_connected_players()) do
			if p:get_meta():get_string("infestation-omen") == "yes" then
				p:get_meta():set_string("infestation-omen","")
				table.insert(r,p:get_pos())
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
	end,
	cond_progress = function(self)
		local m = {}
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then table.insert(m,o) end
		end
		if #m < 1 then
			minetest.log("INFESTATION stage "..self.stage.." completed")
			return true end
		self.mobs = m
	end,
	on_stage_begin = function(self)
		minetest.log("event "..self.name.." stage "..self.stage.." begin...")
		for i=1,5 * self.stage do
			local m = mcl_mobs.spawn(vector.add(self.pos,vector.new(math.random(20)-10,0,math.random(20)-10)),"mobs_mc:silverfish")
			if m then
				table.insert(self.mobs,m)
			end
		end
	end,
	cond_complete = function(self)
		return self.stage >= self.max_stage
	end,
	on_complete = function(self)
		minetest.log("INFESTATION complete")
	end,
})

minetest.register_chatcommand("infest",{
	privs = {debug = true},
	func = function(n,param)
		local p = minetest.get_player_by_name(n)
		p:get_meta():set_string("infestation-omen","yes")
	end,
})
