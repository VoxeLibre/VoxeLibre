## Standard Release

### Before releasing

Make sure all PRs in the release milestone are merged and you are working on a clean branch based on the master branch, up-to-date with the one on the repo.

### Release process

1. Update CREDITS.md
2. Update version in game.conf
3. Run the script:
```
lua tools/generate_ingame_credits.lua
```
4. Make a commit for the above:
```
git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua
git add game.conf
git commit -m "Updated release credits and set version for v0.87"
```
5. Add release notes to the `releasenotes` folder, named like
```
0_87-the_prismatic_release.md
```
6. Make a commit for the release notes:
```
git add releasenotes/0_87-the_prismatic_release.md
git commit -m "Add release notes for v0.87"
```
5. **Tag and push to the tag:**
```
git tag 0.87.0
git push origin 0.87.0
```
6. Update version in game.conf to the next version with -SNAPSHOT suffix:
```
git commit -m "Post-release set version 0.87.0-SNAPSHOT"
```
7. Push the above to a new branch, and make the release PR. Merge to finalize release process.

### Release via ContentDB

1. Go to VoxeLibre page (https://content.minetest.net/packages/Wuzzy/mineclone2/)
2. Click [+Release] button
3. Enter the release tag number in the title and Git reference box. For example (without quotes): "0.87.0"
4. In the minimum minetest version, put the oldest supported version (as of 19/05/2024 it is 5.6), leave the Maximum minetest version blank
5. Click save. Release is now live.

### After releasing

...inform people.

* Open a release meta issue on the tracker, unpin and close the issue for the previous release, pin the new one.
* Upload video to YouTube.
* Add a comment to the forum post with the release number and change log. Maintainer will update the main post with code link.
* Add a Discord announcement post and @everyone with link to the release issue, release notes and other content, like video and forum post.
* Add a Matrix announcement post and @room with links like above.
* Share the news on reddit + Lemmy. Good subs to share with:
  * r/linux_gaming
  * r/opensourcegames
  * r/opensource
  * r/freesoftware
  * r/linuxmasterrace
  * r/VoxeLibre
  * r/MineClone2 (*for now*)


## Hotfix Release

The below is not up-to-date. At the next hotfix the process should be finalized and updated.

### Prepare release branch

When hotfixing, you should never release new features. Any new code increases risk of new bugs which has additional testing/release concerns. 
To mitigate this, you just release the last release, and the relevant bug fix. For this, we do the following:

* Create release branch from the last release tag, push it:

```
git checkout -b release/0.82.1 0.82.0

git push origin release/0.82.1
```

#### Prepare feature branch and fix

* Create feature branch from that release branch (can review it to check only fix is there, nothing else, and use to also merge into master separately)

`git checkout -b hotfix_bug_1_branch`

* Fix crash/serious bug and commit
* Push branch and create pr to the release and also the master branch (Do not rebase, to reduce merge conflict risk. Do not delete after first merge or it needs to be repushed)

#### Update version and tag the release

* After all fixes are in release branch, pull it locally  (best to avoid a merge conflict as feature branch will need to be merged into master also, which already changed version):

* Update version in game.conf to hotfix version and commit it. Example: version=0.82.1

* Tag it, push tag and branch:

```
git tag 0.82.1

git push origin 0.82.1

git push origin release/0.82.1
```

Note: If you have to do more than 1 hotfix release, can do it on the same release branch.


