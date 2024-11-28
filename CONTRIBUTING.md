# Contributing to VoxeLibre
So you want to contribute to VoxeLibre?
Wow, thank you! :-)

VoxeLibre is maintained by AncientMariner and Herowl. If you have any
problems or questions, contact us on Discord/Matrix (See Links section below).

You can help with VoxeLibre's development in many different ways,
whether you're a programmer or not.

## VoxeLibre's development target is to...
- Create a stable, peformant, moddable, free/libre game inspired by Minecraft
using the Luanti engine, usable in both singleplayer and multiplayer.
- Currently, a lot of features are already implemented.
Polishing existing features is always welcome.

## Links
* [Mesehub](https://git.minetest.land/VoxeLibre/VoxeLibre)
* [Discord](https://discord.gg/xE4z8EEpDC)
* [YouTube](https://www.youtube.com/channel/UClI_YcsXMF3KNeJtoBfnk9A)
* [Matrix](https://app.element.io/#/room/#voxelibre:matrix.org)
* [Reddit](https://www.reddit.com/r/VoxeLibre/)
* [Luanti forums](https://forum.luanti.org/viewtopic.php?f=50&t=16407)
* [ContentDB](https://content.luanti.org/packages/wuzzy/mineclone2/)
* [OpenCollective](https://opencollective.com/mineclone2)

## Using git
VoxeLibre is developed using the version control system
[git](https://git-scm.com/). If you want to contribute code to the
project, it is **highly recommended** that you learn the git basics.
For non-programmers and people who do not plan to contribute code to
VoxeLibre, git is not required. However, git is a tool that will be
referenced frequently because of its usefulness. As such, it is valuable
in learning how git works and its terminology. It can also help you
keeping your game updated, and easily test pull requests.

Look at our wiki for some concrete guides:
https://git.minetest.land/VoxeLibre/VoxeLibre/wiki/

## How you can help as a non-programmer
As someone who does not know how to write programs in Lua or does not
know how to use the Luanti API, you can still help us out a lot. For
example, by opening an issue in the
[Issue tracker](https://git.minetest.land/VoxeLibre/VoxeLibre/issues),
you can report a bug or request a feature.

### Rules about both bugs and feature requests
* Stay polite towards the developers and anyone else involved in the
discussion.
* Choose a descriptive title (e.g. not just "crash", "bug" or "question"
).
* Always check the currently opened issues before creating a new one.
Try not to report bugs that have already been reported or request features
that already have been requested. This can often be ambiguous though.
If in doubt open an issue!
* If you know about Luanti's inner workings, please think about
whether the bug / the feature that you are reporting / requesting is
actually an issue with Luanti itself, and if it is, head to the
[Luanti issue tracker](https://github.com/minetest/minetest/issues)
instead.
* If you need any help regarding creating a Mesehub account or opening
an issue, feel free to ask on the Discord or Matrix space.

The link to the mesehub registration page is: https://git.minetest.land/user/sign_up
(It appears to sometimes get lost on the page itsself)

### Reporting bugs
* A bug is an unintended behavior or, in the worst case, a crash.
However, it is not a bug if you believe something is missing in the
game. In this case, please read "Requesting features"
* If you report a crash, always include the error message. If you play
in singleplayer, post a screenshot of the message that Luanti showed
when the crash happened (or copy the message into your issue). If you
are a server admin, you can find error messages in the log file of the
server.
* Tell us which VoxeLibre and Luanti versions you are using (from Luanti 5.7 type /ver, for previous versions, check the game.conf or README.md file).
* Tell us how to reproduce the problem: What you were doing to trigger
the bug, e.g. before the crash happened or what causes the faulty
behavior.

### Requesting features
* Ensure the requested feature fulfills our development targets and
goals.
* Begging or excessive attention seeking does not help us in the
slightest, and may very well disrupt VoxeLibre development. It's better
to put that energy into helping or researching the feature in question.
After all, we're just volunteers working on our spare time.
* Ensure the requested feature has not been implemented in VoxeLibre
latest or development versions.

### Testing code
If you want to help us with speeding up VoxeLibre development and
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
<https://git.minetest.land/VoxeLibre/VoxeLibre/pulls>. Note that pull
requests that start with a `WIP:` are not done yet and therefore could
still undergo substantial change. Testing these is still helpful however
because that is the reason developers put them up as WIP so other people
can have a look at the PR. The wiki has an article with instructions
on how to test Pull Requests:
<https://git.minetest.land/VoxeLibre/VoxeLibre/wiki/Testing-Pull-Requests>.

### Contributing assets
Due to license problems, VoxeLibre cannot use Minecraft's assets,
therefore we are always looking for asset contributions.

To contribute assets, it can be useful to learn git basics and read
the section for Programmers of this document, however this is not required.
It's also a good idea to join the Discord server and/or Matrix space.

#### Textures
For textures we prefer original art, but in the absence of that will accept 
Pixel Perfection texture pack contributions. Be warned many of the newer 
textures in it are copies or slight modifications of the original MC textures 
so great caution needs to be taken when using any textures coming from 
Minecraft texture packs.
If you want to make such contributions, join our Discord server. Demands
for textures will be communicated there.

#### Sounds
VoxeLibre currently does not have a consistent way to handle sounds.
The sounds in the game come from different sources, like the SnowZone
resource pack or minetest_game. Unfortunately, VoxeLibre does not play
a sound in every situation you would get one in Minecraft. Any help with
sounds is greatly appreciated, however if you add new sounds you should
probably work together with a programmer, to write the code to actually
play these sounds in game. All sounds should be released under an open
source license with clear information on the source, licencing and any
changes made by the contributor. Use the README files in the mod to
communicate this information.

#### 3D Models
Many of the 3D Models in VoxeLibre come from
[22i's repository](https://github.com/22i/minecraft-voxel-blender-models).
Similar to the textures, we need people that can make 3D Models with
Blender on demand. Many of the models have to be patched, some new
animations have to be added etc.

#### Crediting
Asset contributions will be credited in their mods and their own respective 
sections in CREDITS.md. If you have commited the results yourself, you will 
also be credited in the Contributors section.

### Contributing Translations

#### Workflow
To add/update support for your language to VoxeLibre, you should take
the steps documented in the section for Programmers, add/update the
translation files of the mods that you want to update. You can add
support for all mods, just some of them or only one mod; you can update
the translation file entirely or only partly; basically any effort is
valued. If your changes are small, you can also send them to developers
via E-Mail, Discord or Matrix - they will credit you appropriately.

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
If you own a server, a great way to help us improve VoxeLibre's code
is by giving us profiler results. Profiler results give us detailed
information about the game's performance and let us know places to
investigate optimization issues. This way we can make the game faster.

#### Using Luanti's profiler
We frequently will use profiling to optimise our code. We recommend use of
the JIT profiler (RIP Jude) to fully understand performance impact:

https://content.luanti.org/packages/jwmhjwmh/jitprofiler/

Luanti also has a built in profiler. Simply set `profiler.load = true` in
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
You can help pay for our infrastructure (Mesehub) and other unforeseen
expenses (in the last few years, only payments for Mesehub have been done)
by donating to our OpenCollective link (See Links section).

### Crediting
If you opened or have contributed to an issue, you receive the
`Community` role on our Discord (after asking for it).
If you have been an author of a PR that got merged or contributed
significantly to art that got merged into the game, you receive the
`Contributor` role on our Discord (after asking for it).
Please note that what counts as "significant" is decided by Maintainers.
OpenCollective Funders are credited in their own section in
`CREDITS.md` and receive a special role "Funder" on our discord (unless
they have made their donation Incognito).

## How you can help as a programmer
(Almost) all the VoxeLibre development is done using pull requests.

### Recommended workflow
* Fork the repository (in case you have not already)
* Do your change in a new branch
* Create a pull request to get your changes merged into master
* It is important that conflicts are resolved prior to merging the pull
request.
* We update our branches via rebasing. Please avoid merging master into 
your branch unless it's the only way you can resolve a conflict. We can
rebase branches from the GUI if the user has not merged master into the 
branch.
* After the pull request got merged, you can delete the branch if the 
merger hasn't done this already.

### Discuss first
If you feel like a problem needs to fixed or you want to make a new
feature, you could start writing the code right away and notifying us
when you're done, but it never hurts to discuss things first. If there
is no issue on the topic, open one. If there is an issue, tell us that
you'd like to take care of it, to avoid duplicate work.

### Don't hesitate to ask for help
We appreciate any contributing effort to VoxeLibre. If you are a
relatively new programmer, you can reach us on Discord or Matrix
for questions about git, Lua, Luanti API, VoxeLibre codebase or
anything related to VoxeLibre. We can help you avoid writing code that
would be deemed inadequate, or help you become familiar with VoxeLibre
better, or assist you use development tools.

### Maintain your own code, even if already got merged
Sometimes, your code may cause crashes or bugs - we try to avoid such
scenarios by testing every time before merging it, but if your merged
work causes problems, we ask you fix the issues as soon as possible.

### Changing Gameplay
Pull Requests that change gameplay are always subject to discussion.
Opinions from the community on such PRs are valued, and Maintainer
should approve the concept (which is usually granted) as well as
the implementation (for which changes are often requested for either
code quality or game design reasons).

### Guidelines

#### Git Guidelines
* Pushing to master is disabled - don't even try it!
* Every change is tracked as a PR
* All changes require at least one approval from a Developer
* Maintainers may merge PRs without formal approval, but should also
take others' opinions and testing into account
* To update branches we use rebase not merge (so we don't end up with
excessive git bureaucracy commits in master)
* We use merge to add the commits from a PR/branch to master
* Smaller PRs may be squashed before merging (especially if the commit history
on them isn't valuable), but when in doubt prefer merging
* Manual merging may be done by a Maintainer if there are technical problems
with the branch, with Gitea, or the PR had been merged to from master and
the author can't fix it for whatever reason
* PR from a fork (usually the author has no contributor/developer privileges)
can be retargeted and merged first into a buffer (normal new) branch on the repo
when adopted by a Developer, and only later into master
* Submodules should only be used if a) upstream is highly reliable and
b) it is 100% certain that no VL specific changes to the code will be
needed (this has never been the case before, hence VL is submodule free so far)
* Subtrees may be used for including outside mods that don't need changes
in the foreseeable future
* Commit messages should be descriptive
* Try to group your submissions best as you can:
  * Try to keep your PRs small: In some cases things reasonably be can't
split up but in general multiple small PRs are better than a big one
  * Similarly multiple small commits are better than a giant one. (use git commit -p)

#### Code Guidelines
* Each mod must provide `mod.conf`.
* Mod names are snake case, and newly added mods (or substantially changed mods
that are included from the outside) start with `vl_`, e.g.
`vl_hollow_logs`,    . Keep in mind Luanti
does not support capital letters in mod names.
* In the past mods were prefixed with `mcl_`, e.g.
`mcl_core`, `mcl_farming`, `mcl_monster_eggs`. New mods should **never** use this prefix.
* Mods included from outside with no significant changes to the API
(especially those using git-subtree or such) aren't prefixed.
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

* Use modern Luanti API, e.g. no usage of `minetest.env`
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
VoxeLibre repository as a contributor. This means that they can push
directly to the branches of our repo (except for `master`).
Pushing to others' branches without asking is discouraged, open a PR
targeting that branch instead (PRs can target any branch).

Those that have demonstrated the right technical skills and behaviour
may be granted developer access. These are the most trusted contributors
who will contribute to ensure coding standards and processes are followed.

#### Developer responsibilities
- If you have developer/contributor privileges you can just open a new branch
in the VL repository (which is preferred). From that you create a pull request.
This way other people can review your changes and make sure they work
before they get merged.
- If you do not (yet) have contributor or developer privs you do your work on a branch
on your private repository e.g. using the "fork" function on mesehub.
- Any developer is welcome to review, test and approve PRs. A maintainer may prefer
to merge the PR especially if it is in a similar area to what has been worked on
and could result in merge conflicts for a larger older branch, or needs 
art/licencing reviewing. A PR needs at least one approval (by someone else other
than the author).
- The maintainers are usually relatively quick to react to new submissions.

### Maintainer status
Maintainers carry the main responsibility for the project.

#### Maintainer responsibilities
- Making sure issues are addressed and pull requests are reviewed and
merged.
- Making releases
- Making project decisions based on community feedback
- Granting/revoking developer access
- Enforcing the code of conduct (See CODE_OF_CONDUCT.md)
- Moderating official community spaces (See Links section)
- Resolving conflicts and problems within the community

#### Current maintainers
* AncientMariner - responsible for gameplay review, publishing releases
* Herowl - responsible for gameplay review, publishing releases,
technical guidelines

#### Release process
* Run `tools/generate_ingame_credits.lua` to update the ingame credits
from `CREDITS.md` and commit the result (if anything changed)
* Launch VoxeLibre to make sure it still runs
* Update the version number in README.md
* Use `git tag <version number>` to tag the latest commit with the
version number
* Push to repository (don't forget `--tags`!)
* Update ContentDB
(https://content.luanti.org/packages/Wuzzy/mineclone2/)
* Update first post in forum thread
(https://forum.minetest.net/viewtopic.php?f=50&t=16407)
* Post release announcement and changelog in forums

### Licensing
By asking us to include your changes in this game, you agree that they
fall under the terms of the GPLv3, which basically means they will
become part of a free/libre software.

### Crediting
Contributors, Developers and Maintainers will be credited in
`CREDITS.md`. There are also Discord roles for Contributors,
Developers and Maintainers.
