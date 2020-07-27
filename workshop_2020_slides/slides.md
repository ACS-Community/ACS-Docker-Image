% Docker image for beginners
% Dominik Neise
% 22.07.2020

---

# Disclaimer

 - I am not a docker evangelist, in fact I only used docker in a few projects so far.

 - I have not much experience with virtualization in general.

 - So this is just me showing you a preliminary proposal, and then brainstorming?

---

# What's the problem?

ACS is hard to install. (I never managed to install it from the sources yet)

We want a strong and growing community. So we need to reduce friction loss for newcomers.

---

# Requirements

In order of importance

 1. Easy to use: download & start right away!

 2. Allows to explore *all* ACS examples

 3. Allows to develop and test a first component

 4. No need to unlearn: Is extentable, once developer becomes more experienced

 5. ... ?

---

# The Proposal

Let's provide newcomers with a ready-made *minimal* docker image, they can just
use as a start.

Provide information about its use in a *prominent place* on the ACS website.

At the *same place* provide information on how to report any issues.

---

## Current state

What I show here is heavily based on an ACS Dockerfile taken from LST,
where it is used for the Telescope Control Unit

<https://github.com/dneise/acs_test>

This github repo, is linked to a dockerhub repo, which automatically builds a fresh
image when the github repo makes a new release.

<https://hub.docker.com/r/dneise/acs_test>

Issues:

 - build is based on RPMs proided by CTA.
 - it does not use the most recent version of ACS, but ACS 2017.
 - I do not know if it really is minimal
 - I use SSH, which is a docker-anti-pattern.

---

## Usage for beginners

Download the image, it is pretty big and takes some time

    docker pull dneise/acs_test:latest

run a fresh instance of the image named `test`.

    docker run -dP --name=test dneise/acs_test

This starts a pseudo VM on your machine, in order to play with this machine you'll
need to log into that machine, via SSH. The port you'll need to connect to is random,
so we need to ask the machine which port it uses:

    docker port test
    # e.g. 22/tcp -> 0.0.0.0:33775

Now we can connect to the machine, we provide passwordless SSH access.
This is **insecure** but very convenient.

    ssh -p 33775 -X almamgr@localhost

---

## Trying it out

Once you are logged into the machine you can start to explore ACS examples
The first thing you might want to test, is: Can I really start a program
in the docker container:

    7f1e7e9be6fa almamgr:~ 1 > acscommandcenter

You should see the command center window opening.
If not, please send open an issue: **explain how to open issues here**

---

## Ending your day

After a day full of new experiences with the ACS docker VM, you can just disconnect from
the SSH session and stop the machine (put it to sleep), like this:

    docker stop test

## Restarting

And tomorrow after a good nights sleep and full of new ideas, just do:

    docker start test
    docker port test # note down the port
    ssh -p <possibly different port than yesterday> -X almamgr@localhost

---

# Almost done! - Proposed Workflow

I propose the following workflow regarding maintenance of this image:

Have a *public* git repo on github, where ACS community members maintain the Dockerfile to keep it up to date.

This takes workload off the sholders of ACS authors.

It allows newcomers to *examine* the Dockerfile in order to learn how to extend it once they get more experience.

The git-repo on github forms a natural place for newcomers to ask questions, since it has a public issue tracker right from the start. So there is no question about whom to ask.

# Brainstorming Time!

 3 ... 2 ... 1 ... go!


---

# Backup slides

SSH-ing into the container with checking the port is inconvenient.
Therefore I've put this into my `.bashrc`:

```bash
sshdocker(){
    if [ -z "$1" ]
    then
        echo "Usage: sshdocker <container_name>"
        return -1
    fi

    port=$(docker port $1 22 | cut -d: -f2)
    shift 1
    ssh -X -p $port $@ almamgr@localhost
}
```

And connect to a container like:

    sshdocker <container name>

Problem: No tab-completion for container name in this case.
