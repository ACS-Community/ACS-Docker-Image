# ACS Docker

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

## Getting Started

### Prerequisites

```
git clone https://github.com/ACS-Community/ACS-Docker-Image
cd ACS-Docker-Image
```

In order to use this repo, you should have installed:

* Docker : For building and run the docker image
* git-lfs : This is needed because ACS repo keeps larger files that are served with this system. Hopefully, we will remove this in the future.

In order to define which version of ACS we are going to build, just `source`
the file: `VERSION` (or `export` the variables as you like):
```
source ./VERSION
```

If git-lfs is not yet installed:
```
./download_and_install_git_lfs.sh
```

Now git clone the version of ACS you want ot build.
If you want to build the same version, we build just do:
```
./git_clone_acs.sh
```

### Building the docker image

```
docker build \
    -t acscommunity/acs:$ACS_DOCKER_VERSION \
    --build-arg ACS_VERSION_NAME=$ACS_VERSION_NAME \
    --build-arg ACS_VERSION=$ACS_VERSION \
    .
```
or just
```
./hooks/build
```


## Deployment

```
docker run --rm -it --name=acs acscommunity/acs:$ACS_DOCKER_VERSION
```

If you want to compile your ACS module inside the docker container, create a docker volume that binds the path of your machine into a folder called `/test` for example:

```
docker run --rm -it \
   -v $PWD:/test \
   -w /test \
   acscommunity/acs:$ACS_DOCKER_VERSION
```

If you need to receive the graphical interface from the container:

```
docker run --rm -it \
   -u $UID \
   -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
   -v $PWD:/test \
   -w /test \
   acscommunity/acs:$ACS_DOCKER_VERSION
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/dneise/acs_test/tags).

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
