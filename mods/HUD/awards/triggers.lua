-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--

local S = minetest.get_translator(minetest.get_current_modname())
local is_fake_player = mcl_util.is_fake_player

awards.register_trigger("dig", function(def)
	local tmp = {
		award  = def.name,
		node   = def.trigger.node,
		target = def.trigger.target,
	}
	table.insert(awards.on.dig, tmp)
	def.getProgress = function(self, data)
		local itemcount
		if tmp.node then
			itemcount = awards.get_item_count(data, "count", tmp.node) or 0
		else
			itemcount = awards.get_total_item_count(data, "count")
		end
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 dug", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.node then
			local nname = minetest.registered_nodes[self.trigger.node].description
			if nname == nil then
				nname = self.trigger.node
			end
			if self.trigger.target ~= 1 then
				return S("Mine blocks: @1×@2", self.trigger.target, nname)
			else
				return S("Mine a block: @1", nname)
			end
		else
			return S("Mine @1 block(s).", self.trigger.target)
		end
	end
end)

awards.register_trigger("place", function(def)
	local tmp = {
		award  = def.name,
		node   = def.trigger.node,
		target = def.trigger.target,
	}
	table.insert(awards.on.place, tmp)
	def.getProgress = function(self, data)
		local itemcount
		if tmp.node then
			itemcount = awards.get_item_count(data, "place", tmp.node) or 0
		else
			itemcount = awards.get_total_item_count(data, "place")
		end
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 placed"), itemcount, tmp.target
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.node then
			local nname = minetest.registered_nodes[self.trigger.node].description
			if nname == nil then
				nname = self.trigger.node
			end
			if self.trigger.target ~= 1 then
				return S("Place blocks: @1×@2", self.trigger.target, nname)
			else
				return S("Place a block: @1", nname)
			end
		else
			return S("Place @1 block(s).", self.trigger.target)
		end
	end
end)

awards.register_trigger("eat", function(def)
	local tmp = {
		award  = def.name,
		item = def.trigger.item,
		target = def.trigger.target,
	}
	table.insert(awards.on.eat, tmp)
	def.getProgress = function(self, data)
		local itemcount
		if tmp.item then
			itemcount = awards.get_item_count(data, "eat", tmp.item) or 0
		else
			itemcount = awards.get_total_item_count(data, "eat")
		end
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 eaten", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.item then
			local iname = minetest.registered_items[self.trigger.item].description
			if iname == nil then
				iname = self.trigger.iode
			end
			if self.trigger.target ~= 1 then
				return S("Eat: @1×@2", self.trigger.target, iname)
			else
				return S("Eat: @1", iname)
			end
		else
			return S("Eat @1 item(s).", self.trigger.target)
		end
	end
end)

awards.register_trigger("death", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target,
	}
	table.insert(awards.on.death, tmp)
	def.getProgress = function(self, data)
		local itemcount = data.deaths or 0
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 deaths", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return S("Die @1 times.", self.trigger.target)
		else
			return S("Die.")
		end
	end
end)

awards.register_trigger("chat", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target,
	}
	table.insert(awards.on.chat, tmp)
	def.getProgress = function(self, data)
		local itemcount = data.chats or 0
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 chat messages", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return S("Write @1 chat messages.", self.trigger.target)
		else
			return S("Write something in chat.")
		end
	end
end)

awards.register_trigger("join", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target,
	}
	table.insert(awards.on.join, tmp)
	def.getProgress = function(self, data)
		local itemcount = data.joins or 0
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 game joins", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return S("Join the game @1 times.", self.trigger.target)
		else
			return S("Join the game.")
		end
	end
end)

awards.register_trigger("craft", function(def)
	local tmp = {
		award  = def.name,
		item = def.trigger.item,
		target = def.trigger.target,
	}
	table.insert(awards.on.craft, tmp)
	def.getProgress = function(self, data)
		local itemcount
		if tmp.item then
			itemcount = awards.get_item_count(data, "craft", tmp.item) or 0
		else
			itemcount = awards.get_total_item_count(data, "craft")
		end
		return {
			perc = itemcount / tmp.target,
			label = S("@1/@2 crafted", itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.item then
			local iname = minetest.registered_items[self.trigger.item].description
			if iname == nil then
				iname = self.trigger.item
			end
			if self.trigger.target ~= 1 then
				return S("Craft: @1×@2", self.trigger.target, iname)
			else
				return S("Craft: @1", iname)
			end
		else
			return S("Craft @1 item(s).", self.trigger.target)
		end
	end
end)

-- Backwards compatibility
awards.register_onDig   = awards.register_on_dig
awards.register_onPlace = awards.register_on_place
awards.register_onDeath = awards.register_on_death
awards.register_onChat  = awards.register_on_chat
awards.register_onJoin  = awards.register_on_join
awards.register_onCraft = awards.register_on_craft

-- Trigger Handles
minetest.register_on_dignode(function(pos, oldnode, digger)
	if is_fake_player(digger) or not pos or not oldnode then
		return
	end

	local data = awards.players[digger:get_player_name()]
	if not awards.increment_item_counter(data, "count", oldnode.name) then
		return
	end
	awards.run_trigger_callbacks(digger, data, "dig", function(entry)
		if entry.target then
			if entry.node then
				local tnodedug = string.split(entry.node, ":")
				local tmod = tnodedug[1]
				local titem = tnodedug[2]
				if tmod and titem and data.count[tmod] and data.count[tmod][titem] and data.count[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "count") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_placenode(function(pos, node, digger)
	if is_fake_player(digger) or not pos or not node or not digger:get_player_name() or digger:get_player_name()=="" then
		return
	end
	local data = awards.players[digger:get_player_name()]
	if not awards.increment_item_counter(data, "place", node.name) then
		return
	end

	awards.run_trigger_callbacks(digger, data, "place", function(entry)
		if entry.target then
			if entry.node then
				local tnodedug = string.split(entry.node, ":")
				local tmod = tnodedug[1]
				local titem = tnodedug[2]
				if tmod and titem and data.place[tmod] and data.place[tmod][titem] and data.place[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "place") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	if is_fake_player(user) then return end
	if not user or not itemstack or not user:get_player_name() or user:get_player_name()=="" then
		return
	end
	local data = awards.players[user:get_player_name()]
	if not awards.increment_item_counter(data, "eat", itemstack:get_name()) then
		return
	end
	awards.run_trigger_callbacks(user, data, "eat", function(entry)
		if entry.target then
			if entry.item then
				local titemstring = string.split(entry.item, ":")
				local tmod = titemstring[1]
				local titem = titemstring[2]
				if tmod and titem and data.eat[tmod] and data.eat[tmod][titem] and data.eat[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "eat") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if is_fake_player(player) or not itemstack then
		return
	end

	local data = awards.players[player:get_player_name()]
	if not awards.increment_item_counter(data, "craft", itemstack:get_name(), itemstack:get_count()) then
		return
	end

	awards.run_trigger_callbacks(player, data, "craft", function(entry)
		if entry.target then
			if entry.item then
				local titemcrafted = string.split(entry.item, ":")
				local tmod = titemcrafted[1]
				local titem = titemcrafted[2]
				if tmod and titem and data.craft[tmod] and data.craft[tmod][titem] and data.craft[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "craft") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_dieplayer(function(player)
	-- Run checks
	local name = player:get_player_name()
	if is_fake_player(player) or not name or name=="" then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]

	-- Increment counter
	data.deaths = data.deaths + 1

	awards.run_trigger_callbacks(player, data, "death", function(entry)
		if entry.target and entry.award and data.deaths and
				data.deaths >= entry.target then
			return entry.award
		end
	end)
end)

minetest.register_on_joinplayer(function(player)
	-- Run checks
	if is_fake_player(player) then return end
	local name = player:get_player_name()
	if not name or name=="" then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]

	-- Increment counter
	data.joins = data.joins + 1

	awards.run_trigger_callbacks(player, data, "join", function(entry)
		if entry.target and entry.award and data.joins and
				data.joins >= entry.target then
			return entry.award
		end
	end)
end)

minetest.register_on_chat_message(function(name, message)
	-- Run checks
	local idx = string.find(message,"/")
	if not name or (idx and idx <= 1)  then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]
	local player = minetest.get_player_by_name(name)
	if is_fake_player(player) then return end

	-- Increment counter
	data.chats = data.chats + 1

	awards.run_trigger_callbacks(player, data, "chat", function(entry)
		if entry.target and entry.award and data.chats and
				data.chats >= entry.target then
			return entry.award
		end
	end)
end)
