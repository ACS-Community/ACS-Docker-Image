build:
	 docker build . --tag=acs:2020.6a1

run_bash:
	docker run -u almamgr -it --rm --name=acs_2020.6  \
		acs:2020.6a1 \
		/bin/bash

run_gui:
	docker run -it --rm \
	-u ${UID} \
	-e DISPLAY=${DISPLAY} \
	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
	--name=acs_2020.6 \
	acs:2020.6a1 \
	/bin/bash


image-clean:
	docker rmi acs:2020.6a1

