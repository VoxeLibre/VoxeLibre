mcl_events = {}
mcl_events.registered_events = {}
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
	minetest.log("event started: "..e.name.." at "..minetest.pos_to_string(p))
	local idx = #active_events + 1
	active_events[idx] = table.copy(e)
	setmetatable(active_events[idx],e)
	active_events[idx].stage = 0
	active_events[idx].percent = 100
	active_events[idx].bars = {}
	active_events[idx].pos = vector.copy(p)
	active_events[idx].time_start = os.time()
	active_events[idx]:on_start(p)
	addbars(active_events[idx])
end

local function finish_event(self,idx)
	minetest.log("event finished: "..self.name.." at "..minetest.pos_to_string(self.pos))
	if self.on_complete then self:on_complete() end
	for _,b in pairs(self.bars) do
		mcl_bossbars.remove_bar(b)
	end
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
	health = 1,
	health_max = 1,
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
		self.health_max = 1
		self.health = 0
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m,o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #m < 1 then
			return true end
	end,
	on_stage_begin = function(self)
		self.health_max = 0
		for i=1,15 * self.stage do
			local m = mcl_mobs.spawn(vector.add(self.pos,vector.new(math.random(20)-10,0,math.random(20)-10)),"mobs_mc:silverfish")
			local l = m:get_luaentity()
			if l then
				self.health_max = self.health_max + l.health
				table.insert(self.mobs,m)
			end
		end
	end,
	cond_complete = function(self)
		local m = {}
		for k,o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				table.insert(m,o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
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
