### Standard Release

#File to document release steps with a view to evolving into a script

#Update CREDITS.md
#Update version in game.conf

lua tools/generate_ingame_credits.lua

git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua
git add game.conf

#git add RELEASE.md

git commit -m "Pre-release update credits and set version 0.83.0"

git tag 0.83.0

git push origin 0.83.0

#Update version in game.conf to the next version with -SNAPSHOT suffix

git commit -m "Post-release set version 0.84.0-SNAPSHOT"

### Hotfix Release

##### Prepare release branch

When hotfixing, you should never release new features. Any new code increases risk of new bugs which has additional testing/release concerns. 
To mitigate this, you just release the last release, and the relevant bug fix. For this, we do the following:

* Create release branch from the last release tag, push it:

git checkout -b release/0.82.1 0.82.0

git push origin release/0.82.1

##### Prepare feature branch and fix

* Create feature branch from that release branch (can review it to check only fix is there, nothing else, and use to also merge into master separately)

git checkout -b hotfix_bug_1_branch

* Fix crash/serious bug and commit
* Push branch and create pr to the release and also the master branch (Do not rebase, to reduce merge conflict risk. Do not delete after first merge or it needs to be repushed)

##### Update version and tag the release

* After all fixes are in release branch, pull it locally  (best to avoid a merge conflict as feature branch will need to be merged into master also, which already changed version):

* Update version in game.conf to hotfix version and commit it. Example: version=0.82.1

* Tag it, push tag and branch:

git tag 0.82.1

git push origin 0.82.1

git push origin release/0.82.1

Note: If you have to do more than 1 hotfix release, can do it on the same release branch.

### Release via ContentDB

* Go to MineClone2 page (https://content.minetest.net/packages/Wuzzy/mineclone2/)
* Click +Release
* Enter the release tag number in the title and Git reference box. For example (without quotes): "0.82.1"
* In the minimum minetest version, put the oldest supported version (as of 14/02/2023 it is 5.5), leave the Maximum minetest version blank
* Click save. Release is now live.

##### Inform people

* Add a comment to the forum post with the release number and what is involved, and maintainer will update main post.
* Add a comment in Discord announcement