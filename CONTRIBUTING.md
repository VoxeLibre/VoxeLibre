# Contributing to MineClone2
So you want to contribute to MineClone2?
Wow, thank you! :-)

But first, some things to note:

MineClone2's development target is to make a free software clone of Minecraft,
***version 1.17***, ***Java Edition***, *** + Optifine features supported by the Minetest Engine***. The priority is making polished features up to version 1.12.

MineClone2 is maintained by Nicu and Fleckenstein. If you have any
problems or questions, contact us (See Links section below).

You can help with MineClone2's development in many different ways,
whether you're a programmer or not.

## Links
* [Mesehub](https://git.minetest.land/MineClone2/MineClone2)
* [Discord](https://discord.gg/xE4z8EEpDC)
* [YouTube](https://www.youtube.com/channel/UClI_YcsXMF3KNeJtoBfnk9A)
* [IRC](https://web.libera.chat/#mineclone2)
* [Matrix](https://app.element.io/#/room/#mc2:matrix.org)
* [Reddit](https://www.reddit.com/r/MineClone2/)
* [Minetest forums](https://forum.minetest.net/viewtopic.php?f=50&t=16407)

## Using git
MineClone2 is developed using the version control system [git](https://git-scm.com/). If you want to
contribute code to the project, it is **highly recommended** that you learn the git basics.
However, if you're not a programmer or don't plan to help with the coding part of the development,
it's still useful if you know it - in case you want to contribute files that are not related to code,
or to easily keep your game updated and test out pull requests. However, it's not required in this
case.

## How you can help as a non-programmer

As someone who does not know how to write programs in Lua or does not
know how to use the Minetest API, you can still help us out a lot.
For example, by opening an issue in the [Issue tracker](https://git.minetest.land/MineClone2/MineClone2/issues), you can
report a bug or request a feature.

### Rules about both bugs and feature requests
* Stay polite towards the developers and anyone else involved in the discussion.
* Choose a descriptive title.
* Try to use proper english and please start the title with a capital letter.
* Always check the currently opened issues before creating a new one. Don't report bugs that have already been reported or request features that already have been requested.
* If you know about Minetest's inner workings, please think about whether the bug / the feature that you are reporting / requesting is actually an issue with Minetest itself, and if it is, head to the [Minetest issue tracker](https://github.com/minetest/minetest/issues) instead.
* If you need any help regarding creating a Mesehub account or opening an issue, feel free to ask on the Discord / Matrix server or the IRC channel.

### Reporting bugs
* A bug is an unintended behavior or, in the worst case, a crash. However, it is not a bug if you believe something is missing in the game. In this case, please read "Requesting features"
* If you report a crash, always include the error message. If you play in singleplayer, post a screenshot of the message that minetest showed when the crash happened (or copy the message into your issue). If you are a server admin, you can find error messages in the log file of the server.
* Tell us which MineClone2 and minetest versions you are using.
* It's always useful to tell us what you were doing to trigger the bug, e.g. before the crash happened or what causes the faulty behavior

### Requesting features
* Make sure the feature you request is Minecraft 1.17 Java Edition or Optifine behavior.
* Don't beg for something to be implemented. We are not going to rethink our development roadmap because someone sais "Pls pls make this I'm waiting for this so bad!!!11!".
* Check whether the feature has been implemented in a newer version of MineClone2, in case you are not using the latest one.

### Testing code
If you want to help us with speeding up MineClone2 development and making the game more stable, a great way to do that is by testing out new features from contributors.
For most new things that get into the game, a pull request is created. A pull request is essentially a programmer saying "Look, I modified the game, please apply my changes to the upstream version of the game".
However, every programmer makes mistakes sometimes, some of which are hard to spot. You can help by downloading this modified version of the game and trying it out - then you tell us whether the code works and does what it claims to do or whether you have encountered any issues.
You can find currently open pull requests here: <https://git.minetest.land/MineClone2/MineClone2/pulls>. Note that pull requests that start with a `WIP:` are not done yet, and therefore might not work, so it's not very useful to try them out yet.

### Profiling
If you own a server, a great way to help us improve MineClone2's code is by giving us profiler results. Profiler results give us detailed information about the game's performance and let us know where the real troublespots are. This way we can make the game faster.
Minetest has a built in profiler. Simply set `profiler.load = true` in your configuration file and restart the server. After running the server for some time, just run `/profiler save` in chat - then you will find a file in the world directory containing the results. Open a new issue and upload the file. You can name the issue "<Server name> profiler results".

### Let us know your opinion
It is always encouraged to actively contribute to issue discussions, let us know what you think about a topic and help us make decisions.

### Crediting
If you opened or have contributed to an issue, you receive the `Community` role on our Discord (after asking for it).

## How you can help as a programmer
(Almost) all the MineClone2 development is done using pull requests. If you feel like a problem needs to fixed or you want to make a new feature, you could start writing the code right away and notifying us when you're, but it it never hurts to discuss things first. If there is no issue on the topic, open one. If there is an issue, tell us that you'd like to take care of it, to avoid duplicate work. Note that we appreciate any effort, so even if you are a relatively new programmer, you can already contribute to the project - if you have problems or questions regarding git, Lua, or the Minetest API - or the MineClone2 codebase, feel free to ask them on our Discord.
By asking us to include your changes in this game, you agree that they fall under the terms of the GPLv3, which basically means they will become part of a free software.
If your code leads to bugs or crashes after being merged, it is your responsibility to fix them as soon as possible.

### The recommended workflow
* Fork the repository (in case you have not already)
* Do your change in a new branch
* Create a pull request to get your changes merged into master
* Keep your pull request up to date by regulary merging upstream
* After the pull request got merged, you can delete the branch

### Git Guidelines
* We use merge rather than rebase or squash merge
* We don't use git submodules.
* Your commit names should be relatively descriptive, e.g. when saying "Fix #issueid", the commit message should also contain the title of the issue.

### Code Guidelines
* Each mod must provide `mod.conf`.
* Each mod which add API functions should store functions inside a global table named like the mod.
* Public functions should not use self references but rather just access the table directly.
* Use modern Minetest API
* Use tabs instead of spaces
* Even if it improves performance, it is discouraged to localize variables at the beggining of files, since if another mod overrides some of the functions / variables you localized, you will still have a reference to the old function.

### Changes to Gameplay
Pull Requests that change gameplay have to be properly researched and need to state their sources. These PRs also need Fleckenstein's approval before they are merged.
You can use these sources:

* Minecraft code (Name the source file and line, however DONT post any proprietary code). You can use MCP to decompile Minecraft.
* Testing things inside of Minecraft (Attach screenshots / video footage of the results)
* Official Minecraft Wiki (Include a link to the page)

### Developer status
Active and trusted contributors are often granted write access to the MineClone2 repository. However you should not push things directly to MineClone2 master - rather, do your work on a branch on your private repo, then create a pull request. This way other people can review your changes and make sure they work before they get merged. You are allowed to merge PRs if they have recieved the necessary feedback.
You may also be assigned to issues or pull requests as a developer. In this case it is your responsibility to fix the issue / review and merge the pull request when it is ready. You can also unassign yourself from the issue / PR if you have no time or don't want to take care of it for some other reason (after all, everyone is a volunteer and we can't expect you to do work that you are not intrested in) - the important thing is really that you make sure to inform us if you won't take care of something that has been assigned to you.
Also, please assign yourself to something that you want to work on to avoid duplicate work.
As a developer, it should be easy to reach you about your code. You should be on the Discord (or, if you really don't like Discord, Matrix or IRC).

### Maintainer status
Maintainers are responsible for making sure issues are addressed and pull requests are reviewed and merged, by assigning either themselves or Developers to issues / PRs.
Maintainers are responsible for making releases, making sure guidelines are kept and making project decisions based on what the community wants.
Maintainers grant/revoke developer access.

Currently there are two maintainers with different responsibility fields:

* Fleckenstein - responsible for gameplay review, publishing releases, technical guidelines and issue/PR delegation
* Nicu - responsible for community related issues

#### Creating releases
* Launch MineClone2 to make sure it still runs
* Update the version number in README.md
* Use `git tag <version number>` to tag the latest commit with the version number
* Push to repo (don't forget `--tags`!)
* Update ContentDB (https://content.minetest.net/packages/Wuzzy/mineclone2/)
* Update first post in forum thread (https://forum.minetest.net/viewtopic.php?f=50&t=16407)
* Post release announcement and changelog in forums

## Crediting
Contributors, Developers and Maintainers will be credited in `CREDITS.md`. If you make your first time contribution, please add yourself to this file.
There are also Discord roles for Contributors, Developers and Maintainers.
