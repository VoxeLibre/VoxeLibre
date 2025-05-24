#!/bin/bash
VERSIONS="5.11.0 5.10.0 5.9.1 5.9.0 5.8.0 5.7.0"

set -ex

test -e luanti || git clone https://github.com/luanti-org/luanti.git
test -e irrlichtmt || git clone https://github.com/minetest/irrlicht.git irrlichtmt

build-5.11.0()
{
	git checkout tags/5.11.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-5.11.0
}
build-5.10.0()
{
	git checkout tags/5.10.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-5.10.0
}
build-5.9.1()
{
	git checkout tags/5.9.1
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.9.1
}
build-5.9.0()
{
	git checkout tags/5.9.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.9.0
}
build-5.8.0()
{
	git checkout tags/5.8.0
	ln -sf ../../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt13 )
	sed -e '27i#include <algorithm>' -i src/client/sound/sound_data.cpp
	export CXX_FLAGS=-std=c++20
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.8.0
}
build-5.7.0()
{
	git checkout tags/5.7.0
	ln -sf ../../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt10 )
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.7.0
}
build-5.6.1()
{
	git checkout tags/5.6.1
	ln -sf ../../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt8 )
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.6.1
}
build-5.6.0()
{
	git checkout tags/5.6.0
	ln -sf ../../../irrlichtmt lib/irrlichtmt
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.6.0
}

mkdir -p bin build
INSTALL_BIN=$PWD/bin
for VERSION in $VERSIONS; do
	rm -f bin/luanti-$VERSION
	(
		cd build/
		rm -Rvf luanti-$VERSION || true
		git clone ../luanti/ luanti-$VERSION
		cd luanti-$VERSION
		rm -Rvf games || true
		rm -Rvf worlds || true
		rm $INSTALL_BIN/luanti-$VERSION || true
		build-$VERSION
		rm -Rvf games || true
		ln -sf ../../games games
		rm -Rvf worlds || true
		ln -sf ../../worlds worlds
	)
done
