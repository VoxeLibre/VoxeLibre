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
7. **Tag and push to the tag:**
```
git tag 0.87.0
git push origin 0.87.0
```
8. Update version in game.conf to the next version with -SNAPSHOT suffix:
```
git commit -m "Post-release set version 0.88.0-SNAPSHOT"
```
9. Push the above to a new branch, and make the release PR. Merge to finalize release process.

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

### Before releasing

First, determine if the current state of the master branch is fine for the Hotfix.
In general, Hotfixes shouldn't contain new features to minimize the risk of regressions.

* If it hasn't been long since the release, and the only PRs merged so far are bugfixes and/or documentation changes,
it is certainly fine to use it as a base for the release.
* If there are some features merged, but they are aimed at fixing/alleviating important issues with the last released version, it may still be fine.
* If there are some simple QoL features merged that are irrelevant to the last release, it may still be fine to use it as a base for the Hotfix.
* If there are major features or large overhauls merged, it *most probably* is **not** fine to use as a base for the Hotfix.

If you decided that the current state of the master branch can be used as the Hotfix version, make sure that all the PRs merged since the last release
are in the Hotfix milestone and you are working on a clean branch based on the master branch, up-to-date with the one on the repo.
In this case, **skip** the following section.

### Prepare release branch

If you decided that the current state of the master branch shouldn't be used as the Hotfix version, you must prepare a release branch.

1. Create release branch from the last release tag, push it:
```
git checkout -b release/0.89.4 0.89.3
git push origin release/0.89.4
```
2. Cherry-pick the relevant commits from the master branch, or merge them from other (PR) branches.
3. Make sure your local copy of the branch contains all the relevant changes, **do not rebase**.

### Release process

1. Update CREDITS.md if it is needed
2. Update version in game.conf
3. If you've changed CREDITS.md, run the script:
```
lua tools/generate_ingame_credits.lua
```
4. Make a commit for the above:
```
git add game.conf
git commit -m "Set version for hotfix v0.87.1"
```
or, if credits got updated:
```
git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua
git add game.conf
git commit -m "Updated release credits and set version for hotfix v0.87.1"
```
5. Add a section in the last releasnotes, like this:
```
## 0.87.1 hotfix
```
and describe the changes there

6. Make a commit for the releasenotes changes:
```
git add releasenotes/0_87-the_prismatic_release.md
git commit -m "Update release notes for hotfix v0.87.1"
```
7. **Tag and push to the tag:**
```
git tag 0.87.1
git push origin 0.87.1
```
8. If you are skipping some changes from the master branch (and thus are using a prepared branch from the previous section),
push to the remote and skip the next two steps:
```
git push origin release/0.82.1
```
9. If you're releasing master branch, update version in game.conf to the next version with -SNAPSHOT suffix:
```
git commit -m "Post-hotfix reset version 0.88.0-SNAPSHOT"
```
10. If you're releasing master branch, push the above to a new branch, and make the release PR. Merge to finalize release process.

11. Do the following if and only if you're releasing a prepared branch: cherry-pick the release notes commit onto a new branch,
then push it and open a new PR to update the relase notes in master
```
git checkout -b notes/0.89.4 master
git cherry-pick #insert relevant commit hash here
git push origin notes/0.89.4
```

### Release via ContentDB

1. Go to VoxeLibre page (https://content.minetest.net/packages/Wuzzy/mineclone2/)
2. Click [+Release] button
3. Enter the release tag number in the title and Git reference box. For example (without quotes): "0.87.1"
4. In the minimum minetest version, put the oldest supported version (as of 19/05/2024 it is 5.6), leave the Maximum minetest version blank
5. Click save. Hotfix is now live.

### After releasing

...inform people.

* Add a comment to the forum post with the release number and change log. Maintainer will update the main post with code link.
* Add a Discord announcement post and @everyone with link to the release issue and release notes, and describe briefly what the hotfix does.
* Add a Matrix announcement post and @room with content like above.
* Share the news on reddit + Lemmy. Good subs to share with:
  * r/linux_gaming
  * r/opensourcegames
  * r/opensource
  * r/freesoftware
  * r/linuxmasterrace
  * r/VoxeLibre
  * r/MineClone2 (*for now*)
