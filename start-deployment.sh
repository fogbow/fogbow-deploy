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

		declare -A federationIdentityProperties
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
			requeriments=$(cat $FEDERATION_PLUGINS_DIR/$requerimentsFile | grep "=" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement=" federationIdentityProperties[$requirement]
				echo "$requirement=${federationIdentityProperties[$requirement]}"
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
	
	function getLocalUserCredentialsMapperInfos {
		LOCAL_USER_CREDENTIALS_MAPPER_DIR=$BEHAVIOR_DIR/"local-user-credentials-mapper"
		DEFAULT_LOCAL_USER_CREDENTIALS_MAPPER="default_mapper"
	
		requerimentsFiles=$(ls ./$LOCAL_USER_CREDENTIALS_MAPPER_DIR)
		localUserCredentialsMapperTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Local user credentials mapper types: $localUserCredentialsMapperTypes"

		declare -A localUserCredentialsMapperProperties
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
			requeriments=$(cat $LOCAL_USER_CREDENTIALS_MAPPER_DIR/$requerimentsFile | grep "=" | awk -F "=" '{print $1}')
			for requirement in $requeriments; do
				read -p "$requirement=" localUserCredentialsMapperProperties[$requirement]
				echo "$requirement=${localUserCredentialsMapperProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		getRequirements
		getDefaultValues
	}

	getFederationIdentityInfos
	getLocalUserCredentialsMapperInfos
}

function getCloudInfos {
	CLOUD_DIR=$REQUIREMENTS_DIR/"cloud-plugins"
	
	function getLocalIdentityInfos {
		LOCAL_PLUGINS_DIR=$CLOUD_DIR/"local-identity"
	
		requerimentsFiles=$(ls ./$LOCAL_PLUGINS_DIR)
		localIdentityTypes=$(echo "$requerimentsFiles" | awk -F "-" '{print $1}')
	
		echo "Federation identity types: $localIdentityTypes"

		declare -A localIdentityProperties
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
				read -p "$requirement=" localIdentityProperties[$requirement]
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
		
		function getComputeInfos {
			echo "Getting compute infos"
			cloudTypeFiles=$(ls ./$CLOUD_TYPE_DIR/$cloudType)
			
			declare -A computePluginProperties
			computePluginProperties[name]=$cloudType
			requirementsFile=$(echo "$cloudTypeFiles" | grep "compute")
			
			if [ -z "$requirementsFile" ]; then
				echo "Cannot identify the $cloudType compute plugin"
				exit 103
			fi
			
			function getRequirements {
				requeriments=$(cat ./$CLOUD_TYPE_DIR/$cloudType/$requirementsFile | grep "=" | awk -F "=" '{print $1}')
				for requirement in $requeriments; do
					read -p "$requirement=" computePluginProperties[$requirement]
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
		
		getComputeInfos
	}
	
	getLocalIdentityInfos
	getCloudInfos
}

getBehavioralInfos
getCloudInfos
