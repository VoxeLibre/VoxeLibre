# CI Docker Image

The files here allow building a VoxeLibre-specific docker image for use in automated testing. There are a few things to know about this image:

* A copy of the VoxeLibre repository at the time the image is built is included in the docker image, for the purpose of decreasing the time it takes to checkout the latest changes and to reduce server load by not needing to download large assets like music, models and textures every time a test is run. If the checkout time grows excessively, rebuilding the docker image will reset this to a new baseline.
* Multiple versions of luanti are built so that compatibility tests for each supported version of luanti can be run. The list of versions is expected to change over time as support for older versions is dropped and new versions of luanti are released. Each time this occurs, the docker image should be rebuilt.
* busted, luacheck, lua-language-server and XVNC and xdotool are included in the image for use in automated tests.

# Building Image
1. Checkout the latest copy of VoxeLibre onto the machine with the forgejo runner.
2. Ensure you are in the base directory of the VoxeLibre checkout.
3. Run "./build.sh"
4. Wait. This will take a while to run as multiple versions of luanti are built clean from source.
5. The completed image will be tagged as "127.0.0.1:5000/voxelibre-test:latest" to permit sharing the image between machines with a local registry on a docker swarm, if so desired.
