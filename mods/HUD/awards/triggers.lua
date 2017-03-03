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

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

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
			label = string.format(S("%d/%d dug"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.node then
			local nname = minetest.registered_nodes[self.trigger.node].description
			if nname == nil then
				nname = self.trigger.node
			end
			if self.trigger.target ~= 1 then
				return string.format(S("Mine blocks: %d×%s"), self.trigger.target, nname)
			else
				return string.format(S("Mine a block: %s"), nname)
			end
		else
			return string.format(S("Mine %d block(s)."), self.trigger.target)
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
			label = string.format(S("%d/%d placed"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.node then
			local nname = minetest.registered_nodes[self.trigger.node].description
			if nname == nil then
				nname = self.trigger.node
			end
			if self.trigger.target ~= 1 then
				return string.format(S("Place blocks: %d×%s"), self.trigger.target, nname)
			else
				return string.format(S("Place a block: %s"), nname)
			end
		else
			return string.format(S("Place %d block(s)."), self.trigger.target)
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
			label = string.format(S("%d/%d eaten"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.item then
			local iname = minetest.registered_items[self.trigger.item].description
			if iname == nil then
				iname = self.trigger.iode
			end
			if self.trigger.target ~= 1 then
				return string.format(S("Eat: %d×%s"), self.trigger.target, iname)
			else
				return string.format(S("Eat: %s"), iname)
			end
		else
			return string.format(S("Eat %d item(s)."), self.trigger.target)
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
			label = string.format(S("%d/%d deaths"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return string.format(S("Die %d times."), self.trigger.target)
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
			label = string.format(S("%d/%d chat messages"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return string.format(S("Write %d chat messages."), self.trigger.target)
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
			label = string.format(S("%d/%d game joins"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.target ~= 1 then
			return string.format(S("Join the game %d times."), self.trigger.target)
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
			label = string.format(S("%d/%d crafted"), itemcount, tmp.target)
		}
	end
	def.getDefaultDescription = function(self)
		if self.trigger.item then
			local iname = minetest.registered_items[self.trigger.item].description
			if iname == nil then
				iname = self.trigger.item
			end
			if self.trigger.target ~= 1 then
				return string.format(S("Craft: %d×%s"), self.trigger.target, iname)
			else
				return string.format(S("Craft: %s"), iname)
			end
		else
			return string.format(S("Craft %d item(s)."), self.trigger.target)
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
	if not digger or not pos or not oldnode then
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
				if not tmod or not titem or not data.count[tmod] or not data.count[tmod][titem] then
					-- table running failed!
				elseif data.count[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "count") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_placenode(function(pos, node, digger)
	if not digger or not pos or not node or not digger:get_player_name() or digger:get_player_name()=="" then
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
				if not tmod or not titem or not data.place[tmod] or not data.place[tmod][titem] then
					-- table running failed!
				elseif data.place[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "place") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
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
				if not tmod or not titem or not data.eat[tmod] or not data.eat[tmod][titem] then
					-- table running failed!
				elseif data.eat[tmod][titem] > entry.target-1 then
					return entry.award
				end
			elseif awards.get_total_item_count(data, "eat") > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player or not itemstack then
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
				if not tmod or not titem or not data.craft[tmod] or not data.craft[tmod][titem] then
					-- table running failed!
				elseif data.craft[tmod][titem] > entry.target-1 then
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
	if not player or not name or name=="" then
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
	local name = player:get_player_name()
	if not player or not name or name=="" then
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
	if not name or (idx ~= nil and idx <= 1)  then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]
	local player = minetest.get_player_by_name(name)

	-- Increment counter
	data.chats = data.chats + 1

	awards.run_trigger_callbacks(player, data, "chat", function(entry)
		if entry.target and entry.award and data.chats and
				data.chats >= entry.target then
			return entry.award
		end
	end)
end)
