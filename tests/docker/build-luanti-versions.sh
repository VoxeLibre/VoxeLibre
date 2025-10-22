#!/bin/bash
VERSIONS="5.14.0 5.13.0 5.12.0 5.11.0 5.10.0 5.9.1 5.9.0 5.8.0 5.7.0"

set -ex

mkdir -p build
(
	cd build
	test -e luanti || git clone https://github.com/luanti-org/luanti.git
	test -e irrlichtmt || git clone https://github.com/minetest/irrlicht.git irrlichtmt
)

build-5.14.0()
{
	git checkout tags/5.14.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-5.14.0
}
build-5.13.0()
{
	git checkout tags/5.13.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-5.13.0
}
build-5.12.0()
{
	git checkout tags/5.12.0
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-5.12.0
}
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
	ln -sf ../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt13 )
	sed -e '27i#include <algorithm>' -i src/client/sound/sound_data.cpp
	export CXX_FLAGS=-std=c++20
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.8.0
}
build-5.7.0()
{
	git checkout tags/5.7.0
	ln -sf ../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt10 )
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.7.0
}
build-5.6.1()
{
	git checkout tags/5.6.1
	ln -sf ../../irrlichtmt lib/irrlichtmt
	( cd lib/irrlichtmt; git checkout tags/1.9.0mt8 )
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.6.1
}
build-5.6.0()
{
	git checkout tags/5.6.0
	ln -sf ../../irrlichtmt lib/irrlichtmt
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/minetest $INSTALL_BIN/luanti-5.6.0
}

mkdir -p bin build
INSTALL_BIN=$PWD/bin
for VERSION in $VERSIONS; do
	if ! [[ -f bin/luanti-$VERSION ]]; then
	(
		cd build/

		# Checkout the specific version desired
		git clone luanti/ luanti-$VERSION
		cd luanti-$VERSION

		# Build the server
		rm $INSTALL_BIN/luanti-$VERSION || true
		build-$VERSION

		# Setup games and worlds
		ln -s ../../ games/VoxeLibre-Test
		rm -Rvf worlds || true
		mkdir -p ../worlds
		ln -s ../worlds worlds
	)
	fi
done
