# Contributing to MineClone2
So you want to contribute to MineClone2?
Wow, thank you! :-)

MineClone2 is maintained by Nicu and Fleckenstein. If you have any
problems or questions, contact us (See Links section below).

You can help with MineClone2's development in many different ways,
whether you're a programmer or not.

## MineClone2's development target is to...
- Crucially, create a stable, moddable, free/libre clone of Minecraft
based on the Minetest engine with polished features, usable in both
singleplayer and multiplayer. Currently, most of **Minecraft Java
Edition 1.12.2** features are already implemented and polishing existing
features are prioritized over new feature requests.
- With lessened priority yet strictly, implement features targetting
**Minecraft version 1.17 + OptiFine** (OptiFine only as far as supported
by the Minetest Engine). This means features in parity with the listed
Minecraft experiences are prioritized over those that don't fulfill this
scope.
- Optionally, create a performant experience that will run relatively
well on really low spec computers. Unfortunately, due to Minecraft's
mechanisms and Minetest engine's limitations along with a very small
playerbase on low spec computers, optimizations are hard to investigate.

## Links
* [Mesehub](https://git.minetest.land/MineClone2/MineClone2)
* [Discord](https://discord.gg/xE4z8EEpDC)
* [YouTube](https://www.youtube.com/channel/UClI_YcsXMF3KNeJtoBfnk9A)
* [IRC](https://web.libera.chat/#mineclone2)
* [Matrix](https://app.element.io/#/room/#mc2:matrix.org)
* [Reddit](https://www.reddit.com/r/MineClone2/)
* [Minetest forums](https://forum.minetest.net/viewtopic.php?f=50&t=16407)
* [ContentDB](https://content.minetest.net/packages/wuzzy/mineclone2/)
* [OpenCollective](https://opencollective.com/mineclone2)

## Using git
MineClone2 is developed using the version control system
[git](https://git-scm.com/). If you want to contribute code to the
project, it is **highly recommended** that you learn the git basics.
For non-programmers and people who do not plan to contribute code to
MineClone2, git is not required. However, git is a tool that will be
referenced frequently because of its usefulness. As such, it is valuable
in learning how git works and its terminology. It can also help you
keeping your game updated, and easily test pull requests.

## How you can help as a non-programmer

As someone who does not know how to write programs in Lua or does not
know how to use the Minetest API, you can still help us out a lot. For
example, by opening an issue in the
[Issue tracker](https://git.minetest.land/MineClone2/MineClone2/issues),
you can report a bug or request a feature.

### Rules about both bugs and feature requests
* Stay polite towards the developers and anyone else involved in the
discussion.
* Choose a descriptive title (e.g. not just "crash", "bug" or "question"
).
* Please write in plain, understandable English. It will be easier to
communicate.
* Please start the issue title with a capital letter.
* Always check the currently opened issues before creating a new one.
Don't report bugs that have already been reported or request features
that already have been requested.
* If you know about Minetest's inner workings, please think about
whether the bug / the feature that you are reporting / requesting is
actually an issue with Minetest itself, and if it is, head to the
[Minetest issue tracker](https://github.com/minetest/minetest/issues)
instead.
* If you need any help regarding creating a Mesehub account or opening
an issue, feel free to ask on the Discord / Matrix server or the IRC
channel.

### Reporting bugs
* A bug is an unintended behavior or, in the worst case, a crash.
However, it is not a bug if you believe something is missing in the
game. In this case, please read "Requesting features"
* If you report a crash, always include the error message. If you play
in singleplayer, post a screenshot of the message that Minetest showed
when the crash happened (or copy the message into your issue). If you
are a server admin, you can find error messages in the log file of the
server.
* Tell us which MineClone2 and Minetest versions you are using.
* Tell us how to reproduce the problem: What you were doing to trigger
the bug, e.g. before the crash happened or what causes the faulty
behavior.

### Requesting features
* Ensure the requested feature fulfills our development targets and
goals.
* Begging or excessive attention seeking does not help us in the
slightest, and may very well disrupt MineClone2 development. It's better
to put that energy into helping or researching the feature in question.
After all, we're just volunteers working on our spare time.
* Ensure the requested feature has not been implemented in MineClone2
latest or development versions.

### Testing code
If you want to help us with speeding up MineClone2 development and
making the game more stable, a great way to do that is by testing out
new features from contributors. For most new things that get into the
game, a pull request is created. A pull request is essentially a
programmer saying "Look, I modified the game, please apply my changes
to the upstream version of the game". However, every programmer makes
mistakes sometimes, some of which are hard to spot. You can help by
downloading this modified version of the game and trying it out - then
tell us if the code works as expected without any issues. Ideally, you
would report issues will pull requests similar to when you were
reporting bugs that are the mainline (See Reporting bugs section). You
can find currently open pull requests here:
<https://git.minetest.land/MineClone2/MineClone2/pulls>. Note that pull
requests that start with a `WIP:` are not done yet, and therefore might
not work, so it's not very useful to try them out yet.

### Contributing assets
Due to license problems, MineClone2 unfortunately cannot use
Minecraft's assets, therefore we are always looking for asset
contributions. To contribute assets, it can be useful to learn git
basics and read the section for Programmers of this document, however
this is not required. It's also a good idea to join the Discord server
(or alternatively IRC or Matrix).

#### Textures
For textures we use the Pixel Perfection texture pack. This is mostly
enough; however in some cases - e.g. for newer Minecraft features, it's
useful to have texture artists around. If you want to make such
contributions, join our Discord server. Demands for textures will be
communicated there.

#### Sounds
MineClone2 currently does not have a consistent way to handle sounds.
The sounds in the game come from different sources, like the SnowZone
resource pack or minetest_game. Unfortunately, MineClone2 does not play
a sound in every situation you would get one in Minecraft. Any help with
sounds is greatly appreciated, however if you add new sounds you should
probably work together with a programmer, to write the code to actually
play these sounds in game.

#### 3D Models
Most of the 3D Models in MineClone2 come from
[22i's repository](https://github.com/22i/minecraft-voxel-blender-models).
Similar to the textures, we need people that can make 3D Models with
Blender on demand. Many of the models have to be patched, some new
animations have to be added etc.

#### Crediting
Asset contributions will be credited in their own respective sections in
CREDITS.md. If you have commited the results yourself, you will also be
credited in the Contributors section.

### Contributing Translations

#### Workflow
To add/update support for your language to MineClone2, you should take
the steps documented in the section for Programmers, add/update the
translation files of the mods that you want to update. You can add
support for all mods, just some of them or only one mod; you can update
the translation file entirely or only partly; basically any effort is
valued. If your changes are small, you can also send them to developers
via E-Mail, Discord, IRC or Matrix - they will credit you appropriately.

#### Things to note
You can use the script at `tools/check_translate_files.py` to compare
the translation files for the language you are working on with the
template files, to see what is missing and what is out of date with
the template file. However, template files are often incomplete and/or
out of date, sometimes they don't match the code. You can update the
translation files if that is required, you can also modify the code in
your translation PR if it's related to translation. You can also work on
multiple languages at the same time in one PR.

#### Crediting
Translation contributions will be credited in their own in CREDITS.md.
If you have commited the results yourself, you will also be credited in
the Contributors section.

### Profiling
If you own a server, a great way to help us improve MineClone2's code
is by giving us profiler results. Profiler results give us detailed
information about the game's performance and let us know places to
investigate optimization issues. This way we can make the game faster.

#### Using Minetest's profiler
Minetest has a built in profiler. Simply set `profiler.load = true` in
your configuration file and restart the server. After running the server
for some time, just run `/profiler save` in chat - then you will find a
file in the world directory containing the results. Open a new issue and
upload the file. You can name the issue "<Server name> profiler
results".

### Let us know your opinion
It is always encouraged to actively contribute to issue discussions on
MeseHub, let us know what you think about a topic and help us make
decisions. Also, note that a lot of discussion takes place on the
Discord server, so it's definitely worth checking it out.

### Funding
You can help pay for our infrastructure (Mesehub) by donating to our
OpenCollective link (See Links section).

### Crediting
If you opened or have contributed to an issue, you receive the
`Community` role on our Discord (after asking for it).
OpenCollective Funders are credited in their own section in
`CREDITS.md` and receive a special role "Funder" on our discord (unless
they have made their donation Incognito).

## How you can help as a programmer
(Almost) all the MineClone2 development is done using pull requests.

### Recommended workflow
* Fork the repository (in case you have not already)
* Do your change in a new branch
* Create a pull request to get your changes merged into master
* Keep your pull request up to date by regularly merging upstream. It is
imperative that conflicts are resolved prior to merging the pull
request.
* After the pull request got merged, you can delete the branch

### Discuss first
If you feel like a problem needs to fixed or you want to make a new
feature, you could start writing the code right away and notifying us
when you're done, but it never hurts to discuss things first. If there
is no issue on the topic, open one. If there is an issue, tell us that
you'd like to take care of it, to avoid duplicate work.

### Don't hesitate to ask for help
We appreciate any contributing effort to MineClone2. If you are a
relatively new programmer, you can reach us on Discord, Matrix or IRC
for questions about git, Lua, Minetest API, MineClone2 codebase or
anything related to MineClone2. We can help you avoid writing code that
would be deemed inadequate, or help you become familiar with MineClone2
better, or assist you use development tools.

### Maintain your own code, even if already got merged
Sometimes, your code may cause crashes or bugs - we try to avoid such
scenarios by testing every time before merging it, but if your merged
work causes problems, we ask you fix the issues as soon as possible.

### Changing Gameplay
Pull Requests that change gameplay have to be properly researched and
need to state their sources. These PRs also need Fleckenstein's approval
before they are merged.
You can use these sources:

* Testing things inside of Minecraft (Attach screenshots / video footage
of the results)
* Looking at [Minestom](https://github.com/Minestom/Minestom) code. An open source Minecraft Server implementation
* [Official Minecraft Wiki](https://minecraft.fandom.com/wiki/Minecraft_Wiki)
(Include a link to the specific page you used)

### Stick to our guidelines

#### Git Guidelines
* We use merge rather than rebase or squash merge
* We don't use git submodules.
* Your commit names should be relatively descriptive, e.g. when saying
"Fix #issueid", the commit message should also contain the title of the
issue.
* Try to keep your commits as atomic as possible (advise, but completely
optional)

#### Code Guidelines
* Each mod must provide `mod.conf`.
* Mod names are snake case, and newly added mods start with `mcl_`, e.g.
`mcl_core`, `mcl_farming`, `mcl_monster_eggs`. Keep in mind Minetest
does not support capital letters in mod names.
* To export functions, store them inside a global table named like the
mod, e.g.

```lua
mcl_example = {}

function mcl_example.do_something()
	-- ...
end

```

* Public functions should not use self references but rather just access
the table directly, e.g.

```lua
-- bad
function mcl_example:do_something()
end

-- good
function mcl_example.do_something()
end
```

* Use modern Minetest API, e.g. no usage of `minetest.env`
* Tabs should be used for indent, spaces for alignment, e.g.

```lua

-- use tabs for indent

for i = 1, 10 do
	if i % 3 == 0 then
		print(i)
	end
end

-- use tabs for indent and spaces to align things

some_table = {
	{"a string",                   5},
	{"a very much longer string", 10},
}
```

* Use double quotes for strings, e.g. `"asdf"` rather than `'asdf'`
* Use snake_case rather than CamelCase, e.g. `my_function` rather than
`MyFunction`
* Don't declare functions as an assignment, e.g.

```lua
-- bad
local some_local_func = function()
	-- ...
end

my_mod.some_func = function()
	-- ...
end

-- good
local function some_local_func()
	-- ...
end

function my_mod.some_func()
	-- ...
end
```

### Developer status
Active and trusted contributors are often granted write access to the
MineClone2 repository.

#### Developer responsibilities
- You should not push things directly to
MineClone2 master - rather, do your work on a branch on your private
repository, then create a pull request. This way other people can review
your changes and make sure they work before they get merged.
- Merge PRs only when they have recieved the necessary feedback and have
been tested by at least two different people (including the author of
the pull request), to avoid crashes or the introduction of new bugs.
- You may also be assigned to issues or pull
requests as a developer. In this case it is your responsibility to fix
the issue / review and merge the pull request when it is ready. You can
also unassign yourself from the issue / PR if you have no time or don't
want to take care of it for some other reason. After all, everyone is a
volunteer and we can't expect you to do work that you are not interested
in. **The important thing is that you make sure to inform us if you
won't take care of something that has been assigned to you.**
- Please assign yourself to something that you want to work on to avoid
duplicate work.
- As a developer, it should be easy to reach you about your work. You
should be in at least one of the public MineClone2 discussion rooms -
preferrably Discord, but if you really don't like Discord, Matrix
or IRC are fine too.

### Maintainer status
Maintainers carry the main responsibility for the project.

#### Maintainer responsibilities
- Making sure issues are addressed and pull requests are reviewed and
merged, by assigning either themselves or Developers to issues / PRs
- Making releases
- Making sure guidelines are kept
- Making project decisions based on community feedback
- Granting/revoking developer access
- Enforcing the code of conduct (See CODE_OF_CONDUCT.md)
- Moderating official community spaces (See Links section)
- Resolving conflicts and problems within the community

#### Current maintainers
* Fleckenstein - responsible for gameplay review, publishing releases,
technical guidelines and issue/PR delegation
* Nicu - responsible for community related issues

#### Release process
* Run `tools/generate_ingame_credits.lua` to update the ingame credits
from `CREDITS.md` and commit the result (if anything changed)
* Launch MineClone2 to make sure it still runs
* Update the version number in README.md
* Use `git tag <version number>` to tag the latest commit with the
version number
* Push to repository (don't forget `--tags`!)
* Update ContentDB
(https://content.minetest.net/packages/Wuzzy/mineclone2/)
* Update first post in forum thread
(https://forum.minetest.net/viewtopic.php?f=50&t=16407)
* Post release announcement and changelog in forums

### Licensing
By asking us to include your changes in this game, you agree that they
fall under the terms of the GPLv3, which basically means they will
become part of a free/libre software.

### Crediting
Contributors, Developers and Maintainers will be credited in
`CREDITS.md`. If you make your first time contribution, please add
yourself to this file. There are also Discord roles for Contributors,
Developers and Maintainers.
