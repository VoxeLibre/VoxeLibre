# Setting up a runner

1. Checkout the VoxeLibre source code onto a system with Docker installed.
2. Run the `register.sh` script in this directory.
3. Provide the current repo base url (i.e. https://git.minetest.land/) for the repo url.
4. From the repo Web UI, open Settings, then go to Actions -> Runners.
5. Click on "Create new Runner" and copy the registration token.
6. Paste the registration token into the script prompt.
7. Enter a name for the runner. This is the name it will appear as in the Web UI. 
8. Enter "voxelibre-ci" for labels.
9. You should get a message to the effect that the registration was successful.
10. Run the "start.sh" script in this directory.
11. Enter 'docker ps' and ensure the runner is alive and running.
12. In the repo Web UI, ensure the runner appears in the list of runners under Settings -> Actions -> Runners and it reports "idle".
