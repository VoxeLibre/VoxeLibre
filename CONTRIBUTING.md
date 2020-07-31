# Contributing to MineClone 2
So you want to MineClone 2?
Wow, thank you! :-)

But first, some things to note:

MineClone 2's development target is to make a free software clone of Minecraft,
***version 1.11***, ***PC edition***.

MineClone 2 is maintained by one person. Namely, Wuzzy. You can find me,
Wuzzy, in the Minetest forums (forums.minetest.net), in IRC in the #minetest
channel on irc.freenode.net. And finally, you can send e-mails to
<Wuzzy2@mail.ru>.

There is **no** guarantee I will accept anything from anybody.

By sending me patches or asking me to include your changes in this game,
you agree that they fall under the terms of the LGPLv2.1, which basically
means they will become part of a free software.

## The suggested workflow
I don't **dictate** your workflow, but in order to work with me in an efficient
way, you can follow my suggestions.

For small and medium changes:

* Fork the repository
* Do your change in a new branch
* Upload the repository somewhere where it can be accessed from the Internet and
  notify me

For small changes, sending me a patch is also good.

For big changes: Same as above, but consider notifying me first to avoid
duplicate work and possible tears of rejection. ;-)

For people that I trust, I might give them direct commit access to this
repository. In this case, you obviously don't need to fork, but you still
need to show your contributions align with the project goals. I still
reserve the right to revert everything that I don't like.
For bigger changes, I strongly recommend to use feature branches and
discuss with me first.

Contributors will be credited in `README.md`.

## Quality remarks
Again: There is ***no*** guarantee I will accept anything from anybody.
But I will gladly take in code from others when I feel it saves me work
in the long run.

### Inclusion criteria
Depending on what you add, the chances for inclusion vary:

### High chance for inclusion
* Gameplay features in Minecraft which are missing in MineClone 2

### Medium chance for inclusion (discuss first)
* Features which don't a impact on gameplay
* GUI improvement
* Features from pocket or console edition

### Low chance for inclusion (discuss/optimize first)
* Overhaul of architecture / mod structure
* Mass-itemstring changes all over the place
* Added files have a unusual high file size
* Indentation looks like crazy
* Single commits which add several unrelated things
* Gameplay features which don't exist in Minecraft

### Instant rejection
* Proprietary **anything**
* Code contains `minetest.env` anywhere

## Coding style guide
* Indentations should reflect the code flow
* Use tabs, not spaces for indentation (tab size = 8)
* Never use `minetest.env`

## Reporting bugs
Report all bugs and missing Minecraft features here:

<https://git.minetest.land/Wuzzy/MineClone2/issues>

## Direct discussion
We have an IRC channel! Join us on #mineclone2 in freenode.net.

<ircs://irc.freenode.net:6697/#mineclone2>
