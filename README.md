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
By providing a `Dockerfile`, which is built for every release, we hope to make sure that the `Dockerfile`
itself is correct, in the sense that it is syntactically correct as well as it creates a workable ACS build.

Since building ACS on your laptop can take a long while, we thought it'd be nice
if pulling a docker image and trying it out **before** actually executing the build
would be a nice experience.

Of course, in order to understand the Dockerfile, one might need some introduction.
So we tried to document each line in the Dockfile for you.



# Build

    docker build . --tag=acs:2020.6

    If you are interested on the expected output, please go to [our docker hub page](https://hub.docker.com/repository/docker/dneise/acs_test/builds). Click on any recent successful build. And then look at the Build Logs.
    For example [this one](https://hub.docker.com/repository/registry-1.docker.io/dneise/acs_test/builds/7d7669bf-59dc-43db-bd1d-592ca072de45)

# Run

    docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw" --name=acs acs:2020.6

# SSH into

if you want to use SSH do access your container, you'll need to build another image
which derives from the official image, e.g. like this
```Dockerfile
FROM dneise/acs_test:2020.6

# Here we make sure, that sshd is setup correctly. Using sshd is a docker anti-pattern
# but for simplicity we do it nevertheless.
# NOTE! We allow empty passwords.
RUN  sed "s@#X11UseLocalhost yes@X11UseLocalhost no@g" -i /etc/ssh/sshd_config && \
     sed "s@#UseDNS yes@UseDNS no@g" -i /etc/ssh/sshd_config && \
     sed "s@#PermitEmptyPasswords no@PermitEmptyPasswords yes@g" -i /etc/ssh/sshd_config
# sshd needs these keys to be created.
RUN /usr/bin/ssh-keygen -A

# We tell docker, that we plan to expost port 22 - the default SSH port.
# With: docker run -dP   docker decides which port to use on the host
# With: docker run -d -p 10022:22  we decided that port 22 should be exposed as 10022.
# Both variants have their use cases.
EXPOSE 22

# As a last step we, we start the SSH daemon.
CMD ["/usr/sbin/sshd", "-D"]

```

Then build this e.g. like this:

    docker build . --tag=acs:2020.6-ssh

And then run it like this:

    docker run -dP --name=acs acs:2020.6

check exposed port with

    docker port acs

then ssh into the running container with

    ssh -X -p <exposed port> almamgr@localhost

# Try out things

in the ssh shell try to start `acscommandcenter` like

    7f1e7e9be6fa almamgr:~ 1 > acscommandcenter

The containers hostname will not be exactly the same

# Start/Stop the container

The containers data is persistent over starts and stops. So when you are done playing with ACS:

    docker stop acs

And the next morning when you want to start playing around again:

    docker start acs
    docker port acs   # take note of port
    ssh -X -p <exposed_port> almamgr@localhost

