# What is this?

In this repo, we develop collectively a basic Dockerfile, to hopefully serve a dual purpose:
 - be useful for beginners to try out ACS
 - serve as living/executable documentation

### Releases & Images

This github repository is connected to a docker.hub project at <https://hub.docker.com/repository/docker/dneise/acs_test>
so that whenever a new release is made in this repo, docker hub auto-magically builds
a new docker image for you to use.

We hope this image might be useful for you.

### Living Documentation?

There is very nice documentation on how to build ACS from source on <https://confluence.alma.cl>,
but it has happened at some point in the past, that this documentation was outdated and/or not complete.
By providing a `Dockerfile`, which is build for every release, we hope to make sure that the `Dockerfile` itself is correct, in the sense that it is syntactically correct as well as creating a workable ACS build.

Since building ACS on your laptop can take a long while, we thought it'd be nice
if pulling a docker image and trying it out **before** actually executing the build
would be a nice experience.

Of course, in order to understand the Dockerfile, one might need some introduction.
So we tried to document each line in the Dockfile for you.



just a docker hub build test

# Build

    docker build . --tag=acs_test:1.0

# Run

    docker run -dP --name=test acs_test:1.0

# SSH into

check exposed port with

    docker port test

then ssh into the running container with

    ssh -X -p <exposed port> almamgr@localhost

# Try out things

in the ssh shell try to start `acscommandcenter` like

    7f1e7e9be6fa almamgr:~ 1 > acscommandcenter

The containers hostname will not be exactly the same

# Start/Stop the container

The containers data is persistent over starts and stops. So when you are done playing with ACS:

    docker stop test

And the next morning when you want to start playing around again:

    docker start test
    docker port test   # take not of port
    ssh -X -p <exposed_port> almamgr@localhost



