# acs_test
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



