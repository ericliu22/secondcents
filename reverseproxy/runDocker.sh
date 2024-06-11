OS=$(uname)
if [[ $OS = "Darwin" ]];
then
	echo "Mac System Detected: Running for Mac"
	if [[ $1 == "debug" ]];
	then
	    docker run \
		--name twocents-reverseproxy-container \
		--rm \
		-p 80:80 \
		-p 443:443 \
		twocents-reverseproxy-image
	else
	    docker run \
		--name twocents-reverseproxy-container \
		--rm \
		--detach \
		-p 80:80 \
		-p 443:443 \
		twocents-reverseproxy-image
	fi
elif [[ $OS = "Linux" ]];
then
	echo "Linux System Detected: Running for Linux"
	if [[ $1 == "debug" ]];
	then
	    docker run \
		--name twocents-reverseproxy-container \
		--rm \
		-p 8080:8080 \
		-p 443:443 \
		twocents-reverseproxy-image
	else
	    docker run \
		--name twocents-reverseproxy-container \
		--rm \
		--detach \
		-p 80:80 \
		-p 443:443 \
		twocents-reverseproxy-image
	fi
fi
