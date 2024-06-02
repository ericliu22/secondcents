OS=$(uname)
if [[ $OS = "Darwin" ]];
then
	echo "Mac System Detected: Running for Mac"
	if [[ $1 == "debug" ]];
	then
	    docker run \
		--name twocents-server-container \
		--rm \
		-p 3000:3000 \
		twocents-server-image
	else
	    docker run \
		--name twocents-server-container \
		--rm \
		--detach \
		-p 3000:3000 \
		twocents-server-image
	fi
elif [[ $OS = "Linux" ]];
then
	echo "Linux System Detected: Running for Linux"
	if [[ $1 == "debug" ]];
	then
	    docker run \
		--name twocents-server-container \
		--rm \
		--network host \
		twocents-server-image
	else
	    docker run \
		--name twocents-server-container \
		--rm \
		--detach \
		--network host \
		twocents-server-image
	fi
fi
