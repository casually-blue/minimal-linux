# very minimal linux
just a bootable kernel with a init script that prints hello world and hangs and nothing else.

requires xorriso and gcc with static libs

to setup run `make init` and then `make` to compile and run

`make clean` removes rootfs folder so don't store anything important in there for now
