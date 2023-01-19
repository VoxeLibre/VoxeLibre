#File to document release steps with a view to evolving into a script

#Update CREDITS.md
#Update version in README.md (soon to be game.conf from of 0.82.0)

lua tools/generate_ingame_credits.lua

git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua

#Should not be needed anymore as version is going to be kept in game.conf
#git add README.md
git add game.conf
git add RELEASE.md

git commit -m "Pre-release update credits and set version 0.82.0"

git tag 0.82.0

git push origin 0.82.0