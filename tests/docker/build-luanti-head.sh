#!/bin/bash
VERSIONS="head head-nojit"

set -ex

mkdir -p build
(
	cd build
	test -e luanti || git clone https://github.com/luanti-org/luanti.git
	test -e irrlichtmt || git clone https://github.com/minetest/irrlichtmt.git irrlichtmt
	(cd luanti; git checkout master; git pull)
)

build-head()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-head
}
build-head-nojit()
{
	git checkout master
	git pull
	cmake . -DRUN_IN_PLACE=TRUE -DENABLE_LUAJIT=OFF
	make -j$(nproc) && ln -sf $PWD/bin/luanti $INSTALL_BIN/luanti-head-nojit
}

mkdir -p bin build
INSTALL_BIN=$PWD/bin
for VERSION in $VERSIONS; do
	rm -f bin/luanti-$VERSION
	(
		cd build/
		rm -Rvf luanti-$VERSION || true

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
done
