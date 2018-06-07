#!/bin/bash

REQUIREMENTS_DIR="requirement-files"

function getBehavioralInfos {
	BEHAVIOR_DIR=$REQUIREMENTS_DIR/"behavior-plugins"

	function getFederationIdentityInfos {
		FEDERATION_PLUGINS_DIR=$BEHAVIOR_DIR/"federation-identity"
		DEFAULT_FEDERATION_IDENTITY="default"
	
		federationIdentityRequerimentsFiles=$(ls ./$FEDERATION_PLUGINS_DIR)
		federationIdentityTypes=$(echo "$federationIdentityRequerimentsFiles" | awk -F "-" '{print $1}')
	
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
		
		federationIdentityRequerimentsFile=$(echo "$federationIdentityRequerimentsFiles" | grep "^${federationIdentityProperties[name]}-")
		
		function getRequirements {
			federationIdentityRequeriments=$(cat $FEDERATION_PLUGINS_DIR/$federationIdentityRequerimentsFile | grep "=" | awk -F "=" '{print $1}')
			for requirement in $federationIdentityRequeriments; do
				read -p "$requirement=" federationIdentityProperties[$requirement]
				echo "$requirement=${federationIdentityProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		if [ -n "$federationIdentityRequerimentsFile" ]; then
			echo "Requirements file: $federationIdentityRequerimentsFile"
			getRequirements
			getDefaultValues
		fi
	}
	
	function getLocalUserCredentialsMapperInfos {
		LOCAL_USER_CREDENTIALS_MAPPER_DIR=$BEHAVIOR_DIR/"local-user-credentials-mapper"
		DEFAULT_LOCAL_USER_CREDENTIALS_MAPPER="default_mapper"
	
		localUserCredentialsMapperRequerimentsFiles=$(ls ./$LOCAL_USER_CREDENTIALS_MAPPER_DIR)
		localUserCredentialsMapperTypes=$(echo "$localUserCredentialsMapperRequerimentsFiles" | awk -F "-" '{print $1}')
	
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
		
		localUserCredentialsMapperRequerimentsFile=$(echo "$localUserCredentialsMapperRequerimentsFiles" | grep "^${localUserCredentialsMapperProperties[name]}-")
		
		function getRequirements {
			localUserCredentialsMapperRequeriments=$(cat $LOCAL_USER_CREDENTIALS_MAPPER_DIR/$localUserCredentialsMapperRequerimentsFile | grep "=" | awk -F "=" '{print $1}')
			for requirement in $localUserCredentialsMapperRequeriments; do
				read -p "$requirement=" localUserCredentialsMapperProperties[$requirement]
				echo "$requirement=${localUserCredentialsMapperProperties[$requirement]}"
			done
		}
		
		function getDefaultValues {
			echo "Getting default values"
		}
		
		echo "Requirements file: $localUserCredentialsMapperRequerimentsFile"
		getRequirements
		getDefaultValues
	}

	getFederationIdentityInfos
	getLocalUserCredentialsMapperInfos
}

function getCloudInfos {

}

getBehavioralInfos
