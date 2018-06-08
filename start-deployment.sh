#!/bin/bash

REQUIREMENTS_DIR="requirement-files"

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
			requeriments=$(cat $FEDERATION_PLUGINS_DIR/$requerimentsFile | grep "=$" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement: " federationIdentityProperties[$requirement]
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
			requeriments=$(cat $LOCAL_USER_CREDENTIALS_MAPPER_DIR/$requerimentsFile | grep "=$" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement: " localUserCredentialsMapperProperties[$requirement]
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
			requeriments=$(cat $AUTHORIZATION_DIR/$requerimentsFile | grep "=$" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement: " authorizationProperties[$requirement]
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
		
		function getRequirements {
			requeriments=$(cat $LOCAL_PLUGINS_DIR/$requerimentsFile | grep "=" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement: " localIdentityProperties[$requirement]
				echo "$requirement=${localIdentityProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		if [ -n "$requerimentsFile" ]; then
			echo "Requirements file: $requerimentsFile"
			getRequirements
			getDefaultValues
		fi
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
			requirementsFile=$(echo "$cloudTypeFiles" | grep "compute")
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType compute plugin"
				exit 103
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "=" | awk -F "=" '{print $1}')
				for requirement in $requeriments; do
					read -p "$requirement: " computePluginProperties[$requirement]
					echo "$requirement=${computePluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			echo "Requirements file: $requirementsFile"
			getRequirements
			getDefaultValues
		}
		
		function getVolumeInfos {
			echo "Getting volume infos"
			
			declare -gA volumePluginProperties
			volumePluginProperties[name]=$cloudType
			requirementsFile=$(echo "$cloudTypeFiles" | grep "volume")
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType volume plugin"
				exit 104
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "=" | awk -F "=" '{print $1}')
				for requirement in $requeriments; do
					read -p "$requirement: " volumePluginProperties[$requirement]
					echo "$requirement=${volumePluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			echo "Requirements file: $requirementsFile"
			getRequirements
			getDefaultValues
		}
		
		function getNetworkInfos {
			echo "Getting network infos"
			
			declare -gA networkPluginProperties
			networkPluginProperties[name]=$cloudType
			requirementsFile=$(echo "$cloudTypeFiles" | grep "network")
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType network plugin"
				exit 104
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "=" | awk -F "=" '{print $1}')
				for requirement in $requeriments; do
					read -p "$requirement: " networkPluginProperties[$requirement]
					echo "$requirement=${networkPluginProperties[$requirement]}"
				done
			}
		
			function getDefaultValues {
				echo "Getting default values"
			}
			
			echo "Requirements file: $requirementsFile"
			getRequirements
			getDefaultValues
		}
		
		getComputeInfos
		getVolumeInfos
		getNetworkInfos
	}
	
	getLocalIdentityInfos
	getCloudInfos
}

getBehavioralInfos
getCloudInfos
