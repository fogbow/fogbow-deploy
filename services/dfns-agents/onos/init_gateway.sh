#!/bin/bash

atomix_version="3.0.8"
onos_version="1.14.1"
ovs_version="2.11"

# ONOS_SECRET is exported by the sh script that calls this script
echo secret:$ONOS_SECRET > onos.secret.debug

ipsec_psk=$ONOS_SECRET

function install_system_dependencies {
        sudo apt-get update
        sudo apt-get install strongswan openvswitch-common openvswitch-switch -y
    	sudo apt-get install linux-headers-4.4.0-154-generic -y
        sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common python libelf-dev -y
}

function install_docker {
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	sudo apt-get update
	sudo apt-get install docker-ce -y
}

function pull_onos_image {
	sudo docker pull onosproject/onos:$onos_version
}

function run_onos_container {
	folder="config"
	if [ ! -d $folder ]; then
		mkdir $folder
	fi
	python ../utils/onos-gen-config.py $local_node_ip $folder/cluster.json --nodes $nodes_ips
	containerID="$(sudo docker create --name onos_controller  -p 6653:6653 -p 9876:9876 -p 8181:8181 onosproject/onos:$onos_version)"
	sudo docker cp $folder $containerID:/root/onos/$folder
	sudo docker start $containerID
}

function clean_gateway_bridges {
	sudo ovs-vsctl --if-exists del-br br-dc
	sudo ovs-vsctl --if-exists del-br br-interdc
}

function interconnect_gateways {
	i=1
	for ip in $nodes_ips
		do
			if [[ $ip != $local_node_ip ]]; then
				sudo ovs-vsctl add-port br-interdc gre-DC$i -- set interface gre-DC$i type=gre \
				options:remote_ip=$ip options:psk=$ipsec_psk
				((i++))
			fi
		done
}

function configure_gateway {
	ONOS_IP=127.0.0.1
	sudo ovs-vsctl add-br br-dc
	sudo ovs-vsctl add-br br-interdc
	sudo ovs-vsctl set-controller br-interdc tcp:$ONOS_IP:6653

	sudo ovs-vsctl add-port br-dc patch-out 2>/dev/null
	sudo ovs-vsctl set interface patch-out type=patch
	sudo ovs-vsctl set interface patch-out options:peer=patch-in
	sudo ovs-vsctl add-port br-interdc patch-in 2>/dev/null
	sudo ovs-vsctl set interface patch-in type=patch
	sudo ovs-vsctl set interface patch-in options:peer=patch-out
}

function configure_onos_applications {
	sleep 2m
	curl -X POST http://127.0.0.1:8181/onos/v1/applications/org.onosproject.lldpprovider/active --user onos:rocks
	curl -X POST http://127.0.0.1:8181/onos/v1/applications/org.onosproject.openflow-base/active --user onos:rocks
	curl -X POST http://127.0.0.1:8181/onos/v1/applications/org.onosproject.hostprovider/active --user onos:rocks
	curl -X POST http://127.0.0.1:8181/onos/v1/applications/org.onosproject.proxyarp/active --user onos:rocks

	sudo docker cp vlan_app.oar onos_controller:/root/onos/
	sudo docker exec -it onos_controller /bin/sh -c "/root/onos/bin/onos-app 127.0.0.1 install vlan_app.oar"
	curl -X POST http://127.0.0.1:8181/onos/v1/applications/org.onosproject.ifwd/active --user onos:rocks
}

function main {
	#onos app push!
	ubuntu_vers="$(lsb_release -r | awk '{print $2}')"
		if [[ $ubuntu_vers != "16.04" ]]; then
				echo "Distro must be Ubuntu 16.04"
				exit 1
		else
			echo "Distro: Ok!"
		fi

	ovs_vers="$(dpkg -s openvswitch-switch | grep -i version |  awk '{print $2}')"
	install_system_dependencies

	if [[ -z "$(docker -v)" ]]; then
		echo "Docker: Install phase..."
		install_docker
	else
		echo "Docker: Installed!"
	fi

	if [[ -z "$(sudo docker images | grep onos)" ]]; then
		echo "ONOS: Pull image..."
		pull_onos_image
	else
		echo "ONOS: Already pulled!"
	fi

	echo "ONOS: Running container..."
	run_onos_container

	echo "Gateway: Cleaning bridges..."
	clean_gateway_bridges

	echo "Gateway: Starting configuration..."
	configure_gateway

	echo "Gateway: Starting interDC IPsec connection..."
	interconnect_gateways

	echo "Configuring ONOS Applications"
	configure_onos_applications
}

local_node_ip=$1
nodes_ips="$*"
main
