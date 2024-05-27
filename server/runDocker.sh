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
