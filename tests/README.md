## Automated Testing

This directory contains the scripts and support files for automated testing of VoxeLibre.

### Checks
#### Luacheck

[luacheck](https://github.com/mpeterv/luacheck) is being run against the source. The checks done here calculate what
globals should be available for a given module based on the mod.conf dependencies so that module dependency issues can
be found more easily. All issues are reported and files with issues included in `tests/luacheck/check.lst` are flagged
as failures.

#### Unit Testing

This will search the source code for modules with a directory `test/` and run each lua file under that directory with
[busted](https://lunarmodules.github.io/busted/), a unit testing framework for Lua.

To add new unit tests, add a `test/` directory under the module, create a `unit.lua` file and add the desired tests.

#### Lua Type Checking

This adds checks using [lua-language-server](https://luals.github.io/) that can catch missing fields, inappropriate
type casting, missing nil checks, and similar classes of bugs that compilers for strongly-typed languages will
typically catch.

### Docker

The automated workflow uses [teknomunk/luanti-ci](https://hub.docker.com/r/teknomunk/luanti-ci), which includes multiple
luanti versions, busted, luacheck, lua-language-server, and xdotool. The

Included is a Dockerfile for a image based on alpine that includes luanti (package and binary is still named minetest),
Xvnc and xdotool for automated play testing, busted, luacheck and lua-langauge-server for code quality and unit tests.

To rebuild the docker images, create `~/.config/voxelibre-build.sh` and add `USER=<name>` and specify a valid Docker Hub
user account, use `docker login -u $USER` then run `tests/docker/build.sh`. This will build the images and upload them
to Docker Hub for use by the actions workflow.

### Forgejo Actions Workflow

Automated testing has integration with Forgejo Actions to automatically run whenever branches and PRs get new commits.

#### Forgejo Runner

To setup a new runner, get the registration token from `Actions -> Runners -> Create new runner` from under settings,
the follow the instructions [here](https://forgejo.org/docs/latest/admin/actions/runner-installation/#oci-image-installation)
to install the runner.
