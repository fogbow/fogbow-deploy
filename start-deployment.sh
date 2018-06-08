#!/bin/bash

IFS=$'\n'

REQUIREMENTS_DIR="requirement-files"

DMZ_HOST_IP=$1
DMZ_HOST_PUBLIC_IP=$2
INTERNAL_HOST_IP=$3

if [ -z "$DMZ_HOST_IP" ]; then
	echo "Please, specify the DMZ host internal ip"
	exit 1
fi
if [ -z "$DMZ_HOST_PUBLIC_IP" ]; then
	echo "Please, specify the DMZ host public ip"
	exit 1
fi 
if [ -z "$INTERNAL_HOST_IP" ]; then
	echo "Please, specify the internal host ip"
	exit 1
fi

function getBehavioralInfos {
	BEHAVIOR_DIR=$REQUIREMENTS_DIR/"behavior-plugins"

	function getFederationIdentityInfos {
		FEDERATION_PLUGINS_DIR=$BEHAVIOR_DIR/"federation-identity"
		DEFAULT_FEDERATION_IDENTITY="default"
	
		requerimentsFiles=$(ls ./$FEDERATION_PLUGINS_DIR)
		federationIdentityTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Federation identity types: $federationIdentityTypes"

		declare -gA federationIdentityProperties
		read -p 'Federation identity: ' federationIdentity
	
		federationIdentityProperties[name]=$(echo "$federationIdentityTypes" | fgrep -wx "$federationIdentity")
		if [ -z "${federationIdentityProperties[name]}" ]; then
			echo "Cannot identify federation identity type"
			echo "Using default type"
			federationIdentityProperties[name]=$DEFAULT_FEDERATION_IDENTITY
		fi
		
		echo "Federation identity type: ${federationIdentityProperties[name]}"
		
		requerimentsFile=$(echo "$requerimentsFiles" | grep "^${federationIdentityProperties[name]}-")
		
		function getRequirements {
			requeriments=$(cat $FEDERATION_PLUGINS_DIR/$requerimentsFile | grep ")=" | awk -F ")" '{print $1}')
			for requirement in $requeriments; do
				isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
				requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
				read -p "$requirement ($isRequired): " federationIdentityProperties[$requirement]
				echo "$requirement=${federationIdentityProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		echo "Requirements file: $requerimentsFile"
		federationIdentityProperties[classname]=$(cat $FEDERATION_PLUGINS_DIR/$requerimentsFile | grep "class" | awk -F "=" '{print $2}')
		echo "Federation identity plugin class name: ${federationIdentityProperties[classname]}"
		getRequirements
		getDefaultValues
	}
	
	function getLocalUserCredentialsMapperInfos {
		LOCAL_USER_CREDENTIALS_MAPPER_DIR=$BEHAVIOR_DIR/"local-user-credentials-mapper"
		DEFAULT_LOCAL_USER_CREDENTIALS_MAPPER="default_mapper"
	
		requerimentsFiles=$(ls ./$LOCAL_USER_CREDENTIALS_MAPPER_DIR)
		localUserCredentialsMapperTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Local user credentials mapper types: $localUserCredentialsMapperTypes"

		declare -gA localUserCredentialsMapperProperties
		read -p 'Local user credentials mapper: ' localUserCredentialsMapper
	
		localUserCredentialsMapperProperties[name]=$(echo "$localUserCredentialsMapperTypes" | fgrep -wx "$localUserCredentialsMapper")
		if [ -z "${localUserCredentialsMapperProperties[name]}" ]; then
			echo "Cannot identify local user credentials mapper type"
			echo "Using default type"
			localUserCredentialsMapperProperties[name]=$DEFAULT_LOCAL_USER_CREDENTIALS_MAPPER
		fi
		
		echo "Local user credentials mapper type: ${localUserCredentialsMapperProperties[name]}"
		
		requerimentsFile=$(echo "$requerimentsFiles" | grep "^${localUserCredentialsMapperProperties[name]}-")
		
		echo "Requirements file: $requerimentsFile"
		
		function getRequirements {
			requeriments=$(cat $LOCAL_USER_CREDENTIALS_MAPPER_DIR/$requerimentsFile | grep ")=" | awk -F ")" '{print $1}')
			for requirement in $requeriments; do
				isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
				requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
				read -p "$requirement ($isRequired): " localUserCredentialsMapperProperties[$requirement]
				echo "$requirement=${localUserCredentialsMapperProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		localUserCredentialsMapperProperties[classname]=$(cat $LOCAL_USER_CREDENTIALS_MAPPER_DIR/$requerimentsFile | grep "class" | awk -F "=" '{print $2}')
		echo "Local user credentials mapper plugin class name: ${localUserCredentialsMapperProperties[classname]}"
		getRequirements
		getDefaultValues
	}
	
	function getAuthorizationInfos {
		AUTHORIZATION_DIR=$BEHAVIOR_DIR/"authorization"
		DEFAULT_AUTHORIZATION="default"
	
		requerimentsFiles=$(ls ./$AUTHORIZATION_DIR)
		authorizationTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Authorization types: $authorizationTypes"

		declare -gA authorizationProperties
		read -p 'Authorization: ' authorization
	
		authorizationProperties[name]=$(echo "$authorizationTypes" | fgrep -wx "$authorization")
		
		if [ -z "${authorizationProperties[name]}" ]; then
			echo "Cannot identify authorization type"
			echo "Using default type"
			authorizationProperties[name]=$DEFAULT_AUTHORIZATION
		fi
		
		echo "Authorization type: ${authorizationProperties[name]}"
		requerimentsFile=$(echo "$requerimentsFiles" | grep "^${authorizationProperties[name]}-")
	
		echo "Requirements file: $requerimentsFile"
	
		function getRequirements {
			requeriments=$(cat $AUTHORIZATION_DIR/$requerimentsFile | grep ")=" | awk -F ")" '{print $1}')
			for requirement in $requeriments; do
				isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
				requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
				read -p "$requirement ($isRequired): " authorizationProperties[$requirement]
				echo "$requirement=${authorizationProperties[$requirement]}"
			done
		}
	
		function getDefaultValues {
			echo "Getting default values"
		}
	
		authorizationProperties[classname]=$(cat $AUTHORIZATION_DIR/$requerimentsFile | grep "class" | awk -F "=" '{print $2}')
		echo "Authorization plugin class name: ${authorizationProperties[classname]}"
		getRequirements
		getDefaultValues
	}

	getFederationIdentityInfos
	getLocalUserCredentialsMapperInfos
	getAuthorizationInfos
}

function getCloudInfos {
	CLOUD_DIR=$REQUIREMENTS_DIR/"cloud-plugins"
	
	function getLocalIdentityInfos {
		LOCAL_PLUGINS_DIR=$CLOUD_DIR/"local-identity"
	
		requerimentsFiles=$(ls ./$LOCAL_PLUGINS_DIR)
		localIdentityTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Local identity types: $localIdentityTypes"

		declare -gA localIdentityProperties
		read -p 'Local identity: ' localIdentity
	
		localIdentityProperties[name]=$(echo "$localIdentityTypes" | fgrep -wx "$localIdentity")
		if [ -z "${localIdentityProperties[name]}" ]; then
			echo "Cannot identify local identity type, exiting..."
			exit 101
		fi
		
		echo "Local identity type: ${localIdentityProperties[name]}"
		
		requerimentsFile=$(echo "$requerimentsFiles" | grep "^${localIdentityProperties[name]}-")
		echo "Requirements file: $requerimentsFile"

		function getRequirements {
			requeriments=$(cat $LOCAL_PLUGINS_DIR/$requerimentsFile | grep ")=" | awk -F ")" '{print $1}')
			for requirement in $requeriments; do
				isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
				requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
				read -p "$requirement ($isRequired): " localIdentityProperties[$requirement]
				echo "$requirement=${localIdentityProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		localIdentityProperties[classname]=$(cat $LOCAL_PLUGINS_DIR/$requerimentsFile | grep "class" | awk -F "=" '{print $2}')
		echo "Local identity plugin class name: ${localIdentityProperties[classname]}"
		
		getRequirements
		getDefaultValues
	}
	
	function getCloudInfos {
		CLOUD_TYPE_DIR=$CLOUD_DIR/"resources"
	
		cloudTypes=$(ls ./$CLOUD_TYPE_DIR)
	
		echo "Cloud types: $cloudTypes"
		read -p 'Cloud type: ' cloudType
	
		cloudType=$(echo "$cloudTypes" | fgrep -wx "$cloudType")
		if [ -z "$cloudType" ]; then
			echo "Cannot identify cloud type, exiting..."
			exit 102
		fi
		
		echo "Cloud Type: $cloudType"
		
		cloudTypeFiles=$(ls ./$CLOUD_TYPE_DIR/$cloudType)
		
		function getComputeInfos {
			echo "Getting compute infos"
			
			declare -gA computePluginProperties
			computePluginProperties[name]=$cloudType
			
			requirementsFile=$(echo "$cloudTypeFiles" | grep "compute-")
			echo "Requirements file: $requirementsFile"

			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType compute plugin"
				exit 103
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep ")=" | awk -F ")" '{print $1}')
				for requirement in $requeriments; do
					isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
					requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
					read -p "$requirement ($isRequired): " computePluginProperties[$requirement]
					echo "$requirement=${computePluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}

			computePluginProperties[classname]=$(cat $CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "class" | awk -F "=" '{print $2}')
			echo "Compute plugin class name: ${computePluginProperties[classname]}"
			
			getRequirements
			getDefaultValues
		}
		
		function getVolumeInfos {
			echo "Getting volume infos"
			
			declare -gA volumePluginProperties
			volumePluginProperties[name]=$cloudType
			
			requirementsFile=$(echo "$cloudTypeFiles" | grep "volume-")
			echo "Requirements file: $requirementsFile"

			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType volume plugin"
				exit 104
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep ")=" | awk -F ")" '{print $1}')
				for requirement in $requeriments; do
					isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
					requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
					read -p "$requirement ($isRequired): " volumePluginProperties[$requirement]
					echo "$requirement=${volumePluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			volumePluginProperties[classname]=$(cat $CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "class" | awk -F "=" '{print $2}')
			echo "Volume plugin class name: ${volumePluginProperties[classname]}"
			
			getRequirements
			getDefaultValues
		}
		
		function getNetworkInfos {
			echo "Getting network infos"
			
			declare -gA networkPluginProperties
			networkPluginProperties[name]=$cloudType
			
			requirementsFile=$(echo "$cloudTypeFiles" | grep "network-")
			echo "Requirements file: $requirementsFile"
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType network plugin"
				exit 105
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep ")=" | awk -F ")" '{print $1}')
				for requirement in $requeriments; do
					isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
					requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
					read -p "$requirement ($isRequired): " networkPluginProperties[$requirement]
					echo "$requirement=${networkPluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			networkPluginProperties[classname]=$(cat $CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "class" | awk -F "=" '{print $2}')
			echo "Network plugin class name: ${networkPluginProperties[classname]}"
			
			getRequirements
			getDefaultValues
		}

		function getAttachmentInfos {
			echo "Getting attachment infos"
			
			declare -gA attachmentPluginProperties
			attachmentPluginProperties[name]=$cloudType
			
			requirementsFile=$(echo "$cloudTypeFiles" | grep "attachment-")
			echo "Requirements file: $requirementsFile"
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType attachment plugin"
				exit 106
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep ")=" | awk -F ")" '{print $1}')
				for requirement in $requeriments; do
					isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
					requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
					read -p "$requirement ($isRequired): " attachmentPluginProperties[$requirement]
					echo "$requirement=${attachmentPluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			attachmentPluginProperties[classname]=$(cat $CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "class" | awk -F "=" '{print $2}')
			echo "Attachment plugin class name: ${attachmentPluginProperties[classname]}"
			
			getRequirements
			getDefaultValues
		}

		function getComputeQuotaInfos {
			echo "Getting compute quota infos"
			
			declare -gA computeQuotaPluginProperties
			computeQuotaPluginProperties[name]=$cloudType
			
			requirementsFile=$(echo "$cloudTypeFiles" | grep "computequota-")
			echo "Requirements file: $requirementsFile"
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType compute quota plugin"
				exit 107
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep ")=" | awk -F ")" '{print $1}')
				for requirement in $requeriments; do
					isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
					requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
					read -p "$requirement ($isRequired): " computeQuotaPluginProperties[$requirement]
					echo "$requirement=${computeQuotaPluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			computeQuotaPluginProperties[classname]=$(cat $CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "class" | awk -F "=" '{print $2}')
			echo "Compute quota plugin class name: ${computeQuotaPluginProperties[classname]}"
			
			getRequirements
			getDefaultValues
		}
		
		getComputeInfos
		getVolumeInfos
		getNetworkInfos
		getAttachmentInfos
		getComputeQuotaInfos
	}
	
	getLocalIdentityInfos
	getCloudInfos
}

function getIntercomponentInfos {
	echo "Getting intercomponent infos"
	
	requirementsFile=$REQUIREMENTS_DIR/"intercomponent.conf"
	echo "Requirements file: $requirementsFile"

	declare -gA intercomponentProperties
	
	function getRequirements {
		requeriments=$(cat $requirementsFile | grep ")=" | awk -F ")" '{print $1}')
		for requirement in $requeriments; do
			isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
			requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
			read -p "$requirement ($isRequired): " intercomponentProperties[$requirement]

			if [ -z "${intercomponentProperties[$requirement]}" ]; then
				intercomponentProperties[$requirement]=$(cat $requirementsFile | grep '(*)=.' | grep "$requirement" | awk -F '=' '{print $2}')
				if [ -n "${intercomponentProperties[$requirement]}" ]; then
					echo "Using default value"
				fi
			fi

			echo "$requirement=${intercomponentProperties[$requirement]}"
		done
	}

	function getDefaultValues {
		echo "Getting default values"
		if [ -z "${intercomponentProperties[xmpp_server_ip]}" ]; then
			intercomponentProperties[xmpp_server_ip]=$DMZ_HOST_IP
			echo "xmpp_server_ip=${intercomponentProperties[xmpp_server_ip]}"
		fi
	}
	
	getRequirements
	getDefaultValues
}

function getManagerInfos {
	echo "Getting manager infos"
	
	requirementsFile=$REQUIREMENTS_DIR/"manager.conf"
	echo "Requirements file: $requirementsFile"

	declare -gA managerProperties
	
	function getRequirements {
		requeriments=$(cat $requirementsFile | grep ")=" | awk -F ")" '{print $1}')
		for requirement in $requeriments; do
			isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
			requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
			read -p "$requirement ($isRequired): " managerProperties[$requirement]

			if [ -z "${managerProperties[$requirement]}" ]; then
				managerProperties[$requirement]=$(cat $requirementsFile | grep '(*)=.' | grep "$requirement" | awk -F '=' '{print $2}')
				if [ -n "${managerProperties[$requirement]}" ]; then
					echo "Using default value"
				fi
			fi

			echo "$requirement=${managerProperties[$requirement]}"
		done
	}

	function getDefaultValues {
		echo "Getting default values"
		if [ -z "${managerProperties[manager_ssh_private_key_file_path]}" ] || [ ! -f "${managerProperties[manager_ssh_private_key_file_path]}" ]; then
			echo "Cannot identify the manager ssh private key"
			echo "Generating manager ssh private key"

			managerProperties[manager_ssh_private_key_file_path]=$(pwd)/"manager-id_rsa"
			managerProperties[manager_ssh_public_key_file_path]=$(pwd)/"manager-id_rsa.pub"
			ssh-keygen -f ${managerProperties[manager_ssh_private_key_file_path]} -t rsa -b 4096 -C "manager@${intercomponentProperties[xmpp_jid]}}" -N ""
			
			echo "manager_ssh_private_key_file_path=${managerProperties[manager_ssh_private_key_file_path]}"
			echo "manager_ssh_public_key_file_path=${managerProperties[manager_ssh_public_key_file_path]}"
		fi
	}
	
	getRequirements
	getDefaultValues
}

function getReverseTunnelInfos {
	echo "Getting reverse tunnel infos"
	
	requirementsFile=$REQUIREMENTS_DIR/"reverse-tunnel.conf"
	echo "Requirements file: $requirementsFile"

	declare -gA reverseTunnelProperties
	
	function getRequirements {
		requeriments=$(cat $requirementsFile | grep ")=" | awk -F ")" '{print $1}')
		for requirement in $requeriments; do
			isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
			requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
			read -p "$requirement ($isRequired): " reverseTunnelProperties[$requirement]
			
			if [ -z "${reverseTunnelProperties[$requirement]}" ]; then
				reverseTunnelProperties[$requirement]=$(cat $requirementsFile | grep '(*)=.' | grep "$requirement" | awk -F '=' '{print $2}')
				if [ -n "${reverseTunnelProperties[$requirement]}" ]; then
					echo "Using default value"
				fi
			fi

			echo "$requirement=${reverseTunnelProperties[$requirement]}"

		done
	}

	function getDefaultValues {
		echo "Getting default values"
		if [ -z "${reverseTunnelProperties[host_key_path]}" ] || [ ! -f "${reverseTunnelProperties[host_key_path]}" ]; then
			echo "Cannot identify the reverse tunnel host key"
			echo "Using manager private key"

			reverseTunnelProperties[host_key_path]=${managerProperties[manager_ssh_private_key_file_path]}
			echo "host_key_path=${reverseTunnelProperties[host_key_path]}"
		fi

		if [ -z "${reverseTunnelProperties[reverse_tunnel_public_address]}" ]; then
			echo "Cannot identify the reverse tunnel public address, using DMZ host public ip"
			
			reverseTunnelProperties[reverse_tunnel_public_address]=$DMZ_HOST_PUBLIC_IP
			echo "reverse_tunnel_public_address=${reverseTunnelProperties[reverse_tunnel_public_address]}"
		fi

		if [ -z "${reverseTunnelProperties[reverse_tunnel_private_address]}" ]; then
			echo "Cannot identify the reverse tunnel private address, using DMZ host internal ip"
			
			reverseTunnelProperties[reverse_tunnel_private_address]=$DMZ_HOST_IP
			echo "reverse_tunnel_private_address=${reverseTunnelProperties[reverse_tunnel_private_address]}"
		fi
	}
	
	getRequirements
	getDefaultValues
}

function getMembershipInfos {
	echo "Getting membership infos"
	
	requirementsFile=$REQUIREMENTS_DIR/"membership.conf"
	echo "Requirements file: $requirementsFile"

	declare -gA membershipProperties
	
	function getRequirements {
		requeriments=$(cat $requirementsFile | grep ")=" | awk -F ")" '{print $1}')
		for requirement in $requeriments; do
			isRequired=$(echo "$requirement" | awk -F "(" '{print $2}')
			requirement=$(echo "$requirement" | awk -F "(" '{print $1}')
			read -p "$requirement ($isRequired): " membershipProperties[$requirement]

			if [ -z "${membershipProperties[$requirement]}" ]; then
				membershipProperties[$requirement]=$(cat $requirementsFile | grep '(*)=.' | grep "$requirement" | awk -F '=' '{print $2}')
				if [ -n "${membershipProperties[$requirement]}" ]; then
					echo "Using default value"
				fi
			fi

			echo "$requirement=${membershipProperties[$requirement]}"
		done
	}
	
	getRequirements
}

getCloudInfos
getBehavioralInfos
getIntercomponentInfos
getManagerInfos
getReverseTunnelInfos
getMembershipInfos


