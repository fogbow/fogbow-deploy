#!/bin/bash

sudo docker stop atomix_node onos_controller
sudo docker container rm atomix_node onos_controller
sudo docker system prune -af
sudo docker container prune -f
sudo apt-get remove openvswitch-common -y
sudo apt-get remove openvswitch-switch -y
