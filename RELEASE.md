#File to document release steps with a view to evolving into a script

#Update CREDITS.md
#Update version in README.md (soon to be game.conf from of 0.82.0)

lua tools/generate_ingame_credits.lua

git add CREDITS.md
git add mods/HUD/mcl_credits/people.lua

git add README.md
# To uncomment when applicable
#git add game.conf

git commit -m "Pre-release update credits and set version"