DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/fogbow-membership-service"
PROJECT_RESOURCES_PATH="src/main/resources"

LOG4J_FILE_NAME="log4j.properties"
CONF_FILE_NAME="membership.conf"

IMAGE_NAME="fogbow/membership-service:latest"
CONTAINER_NAME="membership-service"

MEMBERSHIP_HOST_PORT=$1
MEMBERSHIP_CONTAINER_PORT="8080"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt --name $CONTAINER_NAME \
	-p $MEMBERSHIP_HOST_PORT:$MEMBERSHIP_CONTAINER_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME

