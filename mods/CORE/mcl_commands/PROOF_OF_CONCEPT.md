### `mcl_commands.register_command(name, def)`

#### Complex commands (WIP):

```
mcl_commands.register_command("test", {
	type = "complex",
	priv_level = 4,
	func = function(context)
		if self.match_type("int", {min=1, max=255} then
			print(self.last_type)
		end
	end,
})
```

#### Basic commands:

* `context.type` is the context of execution: `player` or `commandblock`
* `context.commander` is the executor/commander of the command
* `context.pos` is the position where the command is executed

This param allow the use of position target selectors

```
mcl_commands.register_command("test", {
	type = "basic",
	priv_level = 4,
	func = function(context)
		if context.commander then
			print(context.pos)
			print("--------")		 --this "concept" param allow to run command correctly
									 --(with target selector and logging) from mods or command blocks
			return true, S("Succesfull")
		end
	end,
})
```

### `mcl_commands.execute_command(name, params, context)`

#### As a player:
```
mcl_commands.execute_command("test", "foo bar true 1", {type="player", commander=player, pos=player:get_pos()})
```
#### As a command block:
```
mcl_commands.execute_command("test", "foo bar true 1", {type="commandblock", commander=commander, pos=node_pos})
```

### `mcl_commands.get_target_selector(target_selector)`

This function allow mods and commands to get the result of a given target selector in that form: `@e[gamemode=creative,limit=5]`

This function returns a code indicating the success and a table of ObjectRefs (can be empty)