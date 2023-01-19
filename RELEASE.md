#File to document release steps with a view to evolving into a script

#Update CREDITS.md
#Update version in game.conf

lua tools/generate_ingame_credits.lua

git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua
git add game.conf

#git add RELEASE.md

git commit -m "Pre-release update credits and set version 0.82.0"

git tag 0.82.0

git push origin 0.82.0

#Update version in game.conf to -SNAPSHOT

git commit -m "Post-release set version 0.82.0-SNAPSHOT"