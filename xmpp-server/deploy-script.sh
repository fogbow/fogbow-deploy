DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/etc/prosody"

CONF_FILE_NAME="prosody.cfg.lua"

IMAGE_NAME="fogbow/xmpp-server:latest"
CONTAINER_NAME="xmpp-server"

C2S_PORT="5222"
S2S_PORT="5269"
C2C_PORT="5347"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $C2S_PORT:$C2S_PORT \
	-p $S2S_PORT:$S2S_PORT \
	-p $C2C_PORT:$C2C_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	$IMAGE_NAME

