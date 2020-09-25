# ACS Docker

In this repo, we develop collectively a basic Dockerfile, to hopefully serve a dual purpose:
 - be useful for beginners to try out ACS
 - serve as living/executable documentation

[[_TOC_]]

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

In order to use this repo, you should install:

* Docker : For building and run the docker image
* git: For cloning the repo
* git-lfs : This is needed because ACS repo keeps larger files that are served with this system. Hopefully, we will remove this in the future.


Once you have the aforementioned prerequisites, clone the repo like this:

```
git clone --recursive https://github.com/dneise/acs_test acs_docker
```

NOTE: This command should **also** clone the ACS repo. If this not happen, once the ACS Docker repo is cloned, checkout the develop branch:

```
git checkout develop
```

And update the submodule:

```
git submodule update --init
```

### Building the docker image


```
docker build -t alma/acs .
```

## Deployment

```
docker run --rm -it --name=acs alma/acs
```

If you want to compile your ACS module inside the docker container, create a docker volume that binds the path of your machine:

```
docker run --rm -it -v $PWD:/test -w /test alma/acs
```

If you need to receive the graphical interface from the container:

```
docker run --rm -it -u $UID -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw" -v $PWD:/test -w /test alma/acs
```

## Built With

* Docker

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/dneise/acs_test/tags).

## License

<!---

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

-->
