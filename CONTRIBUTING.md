# Contributing to MineClone 2
So you want to MineClone 2?
Wow, thank you! :-)

But first, some things to note:

MineClone 2's development target is to make a free software clone of Minecraft,
***version 1.12***, ***PC edition***, *** + Optifine features supported by the Minetest Engine ***.

MineClone 2 is maintained by three persons. Namely, kay27, EliasFleckenstein and jordan4ibanez. You can find us
in the Minetest forums (forums.minetest.net), in IRC in the #mineclone2
channel on irc.freenode.net. And finally, you can send e-mails to
<eliasfleckenstein@web.de> or <kay27@bk.ru>.

By sending us patches or asking us to include your changes in this game,
you agree that they fall under the terms of the LGPLv2.1, which basically
means they will become part of a free software.

## The suggested workflow
We don't **dictate** your workflow, but in order to work with us in an efficient
way, you can follow these suggestions:

For small and medium changes:

* Fork the repository
* Do your change in a new branch
* Create a pull request to get your changes merged into master

For small changes, sending us a patch is also good.

For big changes: Same as above, but consider notifying us first to avoid
duplicate work and possible tears of rejection. ;-)

For trusted people, we might give them direct commit access to this
repository. In this case, you obviously don't need to fork, but you still
need to show your contributions align with the project goals. We still
reserve the right to revert everything that we don't like.
For bigger changes, we strongly recommend to use feature branches and
discuss with me first.

If your code causes bugs and crashes, it is your responsibility to fix them as soon as possible.

We mostly use plain merging rather than rebasing or squash merging.

Your commit names should be relatively descriptive, e.g. when saying "Fix #issueid", the commit message should also contain the title of the issue.

Contributors will be credited in `CREDITS.md`.

## Features > 1.12

If you want to make a feature that was added in a Minecraft version later than 1.12, you should fork MineClone5 (mineclone5 branch in the repository) and add your changes to this.

## What we accept

* Every MC features up to version 1.12 JE.
* Every already finished and working good features from versions above (only when making a MineClone5 PR / Contribution).
* Except features which couldn't be done easily and bugfree because of Minetest engine limitations. Eg. we CAN extend world boundaries by playing with map chunks, just teleporting player onto next layer after 31000 , but it would cost too much (time, code, bugs, performance, stability, etc).
* Some features, approved by the rest of the community, I mean maybe some voting and really missing any negative feedback.

## What we reject

* Any features which cause critical bugs, sending them to rework/fix or trying to fix immediately.
* Some small portions of big entirely missing features which just definitely break gamplay balance give nothing useful
* Controversial features, which some people support while others do not should be discussed well, with publishing forum announcements, at least during the week. In case if there are still doubts - send them into the mod.

## Reporting bugs
Report all bugs and missing Minecraft features here:

<https://git.minetest.land/MineClone2/MineClone2/issues>

## Direct discussion
We have an IRC channel! Join us on #mineclone2 in freenode.net.

<ircs://irc.freenode.net:6697/#mineclone2>

## Creating releases
* Launch MineClone2 to make sure it still runs
* Update the version number in README.md
* Use `git tag <version number>` to tag the latest commit with the version number
* Push to repo (don't forget `--tags`!)
* Update ContentDB (https://content.minetest.net/packages/Wuzzy/mineclone2/)
* Update first post in forum thread (https://forum.minetest.net/viewtopic.php?f=50&t=16407)
* Post release announcement and changelog in forums
