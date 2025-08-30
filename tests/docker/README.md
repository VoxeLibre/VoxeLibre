# CI Docker Image

The files here allow building a VoxeLibre-specific docker image for use in automated testing. There are a few things to know about this image:

* A copy of the VoxeLibre repository at the time the image is built is included in the docker image, for the purpose of decreasing the time it takes to checkout the latest changes and to reduce server load by not needing to download large assets like music, models and textures every time a test is run. If the checkout time grows excessively, rebuilding the docker image will reset this to a new baseline.
* Multiple versions of luanti are built so that compatibility tests for each supported version of luanti can be run. The list of versions is expected to change over time as support for older versions is dropped and new versions of luanti are released. Each time this occurs, the docker image should be rebuilt.
* busted, luacheck, lua-language-server and XVNC and xdotool are included in the image for use in automated tests.

# Building Image
1. Checkout the latest copy of VoxeLibre onto the machine with the forgejo runner.
2. Ensure you are in the base directory of the VoxeLibre checkout.
3. Create the file ~/.config/voxelibre-docker.sh and add `USER=` followed by the Docker Hub account to upload to.
4. Run "docker login -u $USER" with the username from step 3, then provide the account password.
3. Run "./build.sh"
4. Wait. This will take a while to run as multiple versions of luanti are built clean from source and the docker
   images are created and uploaded to Docker Hub.
