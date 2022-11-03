mcl_events = {}
mcl_events.registered_events = {}
local DBG = minetest.settings:get_bool("mcl_logging_event_api",false)
local active_events = {}

local tpl_eventdef = {
	stage = 0,
	max_stage = 1,
	percent = 100,
	bars = {},
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

local function mcl_log(m,l)
	if DBG then
		if not l then l = "action" end
		minetest.log(l,"[mcl_events] "..m)
	end
end

function mcl_events.register_event(name,def)
	mcl_events.registered_events[name] = {}
	--setmetatable(mcl_events.registered_events[name],tpl_eventdef)
	mcl_events.registered_events[name] = def
	mcl_events.registered_events[name].name = name
end

local function addbars(self)
	for _,player in pairs(minetest.get_connected_players()) do
		if vector.distance(self.pos,player:get_pos()) < 75 then
			local bar = mcl_bossbars.add_bar(player, {color = "red", text = self.name .. " stage "..self.stage.." / "..self.max_stage, percentage = self.percent }, true,1)
			table.insert(self.bars,bar)
		end
	end
end

local function update_bars(self)
	for _,b in pairs(self.bars) do
		mcl_bossbars.update_bar(b,{text = self.name .. " stage "..self.stage,percentage=self.percent})
	end
end

local function start_event(p,e)
	mcl_log("event started: "..e.name.." at "..minetest.pos_to_string(vector.round(p.pos)))
	local idx = #active_events + 1
	active_events[idx] = table.copy(e)
	setmetatable(active_events[idx],e)
	for k,v in pairs(p) do active_events[idx][k] = v end
	active_events[idx].stage = 0
	active_events[idx].percent = 100
	active_events[idx].bars = {}
	active_events[idx].time_start = os.time()
	active_events[idx]:on_start(p.pos)
	addbars(active_events[idx])
end

local function finish_event(self,idx)
	mcl_log("Finished: "..self.name.." at "..minetest.pos_to_string(vector.round(self.pos)))
	if self.on_complete then self:on_complete() end
	for _,b in pairs(self.bars) do
		mcl_bossbars.remove_bar(b)
	end
	table.remove(active_events,idx)
end

local etime = 0
function check_events(dtime)
	--process active events
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
				ae:on_stage_begin()
			elseif tonumber(p) then
				ae.stage = tonumber(p) or ae.stage + 1
				ae:on_stage_begin()
			end
		elseif not ae.finished and ae.on_step then
			ae:on_step()
		end
		addbars(ae)
		--update_bars(ae)
	end
	-- check if a new event should be started
	etime = etime - dtime
	if etime > 0 then return end
	etime = 10
	for _,e in pairs(mcl_events.registered_events) do
		local pp = e.cond_start()
		if pp then
			for _,p in pairs(pp) do
				local start = true
				if e.exclusive_to_area then
					for _,ae in pairs(active_events) do
						if e.name == ae.name and vector.distance(p.pos,ae.pos) < e.exclusive_to_area then start = false end
					end
				end
				if start then
					start_event(p,e)
				elseif DBG then
					mcl_log("event "..e.name.." already active at "..minetest.pos_to_string(vector.round(p.pos)))
				end
			end
		end
	end
end

minetest.register_globalstep(check_events)

minetest.register_chatcommand("event_start",{
	privs = {debug = true},
	func = function(pname,param)
		local p = minetest.get_player_by_name(pname)
		local evdef = mcl_events.registered_events[param]
		if not evdef then return end
		start_event({pos=p:get_pos(),player=pname,factor=1},evdef)
	end,
})
