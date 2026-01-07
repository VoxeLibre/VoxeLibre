#!/bin/sh

. ~/.config/voxelibre-docker.sh

LUANTI_VERSION=5.14.0
VOXELIBRE_VERSION=0.91.1

if test -z "$USER"; then
	echo "\$USER must be set for docker image build and uploads to function"
	exit 1
fi

./build-packages.sh
cp luanti-ci/luanti-$LUANTI_VERSION-1.tar.gz luanti-server/

(
	cd luanti-server
	docker build . -t $USER/luanti-server:$LUANTI_VERSION
	docker image tag $USER/luanti-server:$LUANTI_VERSION $USER/luanti-server:latest

	docker image push $USER/luanti-server:$LUANTI_VERSION
	docker image push $USER/luanti-server:latest
)
(
	cd luanti-ci
	docker build . -t $USER/luanti-ci:$LUANTI_VERSION
	docker image tag $USER/luanti-ci:$LUANTI_VERSION $USER/luanti-ci:latest

	docker image push $USER/luanti-ci:$LUANTI_VERSION
	docker image push $USER/luanti-ci:latest
)
(
	cd voxelibre
	docker build . -t $USER/voxelibre:$VOXELIBRE_VERSION
	docker image tag $USER/voxelibre:$VOXELIBRE_VERSION $USER/voxelibre:latest

	docker image push $USER/voxelibre:$VOXELIBRE_VERSION
	docker image push $USER/voxelibre:latest
)
