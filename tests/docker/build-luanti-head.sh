#!/bin/bash
VERSIONS="head head-nojit"

set -ex

test -e luanti || git clone https://github.com/luanti-org/luanti.git
test -e irrlichtmt || git clone https://github.com/minetest/irrlichtmt.git irrlichtmt
(cd luanti; git checkout master; git pull)

build-head()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti /usr/local/bin/luanti-head
}
build-head-nojit()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE -DENABLE_LUAJIT=OFF
	make -j$(nproc) && ln -sf $PWD/bin/luanti /usr/local/bin/luanti-head-nojit
}

mkdir -p bin build
for VERSION in $VERSIONS; do
	rm -f bin/luanti-$VERSION
	(
		cd build/
		git clone ../luanti/ luanti-$VERSION
		cd luanti-$VERSION
		rm -Rvf games || true
		ln -sf ../../games games
		rm -Rvf worlds || true
		ln -sf ../../worlds worlds
		rm /usr/local/bin/luanti-$VERSION || true
		build-$VERSION
	)
done
