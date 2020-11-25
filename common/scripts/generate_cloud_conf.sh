#!/bin/bash

CONF_FILE_PATH=$1
CONF_FILE_DIR_PATH=`dirname $1`
CLOUDS_DIR_PATH=$2/"clouds"
COMMON_TEMPLATES=$3
CLOUD_NAME=`basename $1 .conf`
CLOUD_CONF_FILE_PATH=$CLOUDS_DIR_PATH/$CLOUD_NAME/"cloud.conf"
MAPPER_CONF_FILE_PATH=$CLOUDS_DIR_PATH/$CLOUD_NAME/"mapper.conf"
PLUGINS_CONF_FILE_PATH=$CLOUDS_DIR_PATH/$CLOUD_NAME/"plugins.conf"

# AWS properties
RS_PATTERN=aws_region_selection_key
RS=""
AZ_PATTERN=aws_availability_zone_key
AZ=""
DSUB_PATTERN=aws_default_subnet_id_key
DSUB=""
DSEC_PATTERN=aws_default_security_group_id_key
DSEC=""
STGQ_PATTERN=aws_storage_quota_key
STGQ=""
EIP_PATTERN=aws_elastic_ip_addresses_quota_key
EIP=""
VPCQ_PATTERN=aws_vpc_quota_key
VPCQ=""
CUCA_PATTERN=cloud_user_credentials_access_key
CUCA=""
CUCSA_PATTERN=cloud_user_credentials_secret_access_key
CUCSA=""

# Azure properties
VN_PATTERN=default_virtual_network_name
VN=""
RG_PATTERN=default_resource_group_name
RG=""
RN_PATTERN=default_region_name
RN=""
VMP_PATTERN=virtual_machine_images_publishers
VMP=""
CS_PATTERN=cloud_user_credentials_subscription_id
CS=""
CC_PATTERN=cloud_user_credentials_client_id
CC=""
CCK_PATTERN=cloud_user_credentials_client_key
CCK=""
CTI_PATTERN=cloud_user_credentials_tenant_id
CTI=""

# OpenStack properties
NOVA_PATTERN=openstack_nova_url
NOVA=""
NEUTRON_PATTERN=openstack_neutron_url
NEUTRON=""
OSDN_PATTERN=default_network_id
OSDN=""
EG_PATTERN=external_gateway_info
EG=""
CINDER_PATTERN=openstack_cinder_url
CINDER=""
GLANCE_PATTERN=openstack_glance_url
GLANCE=""
OSPN_PATTERN=cloud_user_credentials_projectname
OSPN=""
OSPASS_PATTERN=cloud_user_credentials_password
OSPASS=""
OSUN_PATTERN=cloud_user_credentials_username
OSUN=""
OSCD_PATTERN=cloud_user_credentials_domain
OSCD=""
OSCIPU_PATTERN=cloud_identity_provider_url
OSCIPU=""

# CloudStack properties
CSAPI_PATTERN=cloudstack_api_url
CSAPI=""
ZONE_PATTERN=zone_id
ZONE=""
CSDN_PATTERN=default_network_id
CSDN=""
NO_PATTERN=network_offering_id
NO=""
CSPASS_PATTERN=cloud_user_credentials_password
CSPASS=
CSUN_PATTERN=cloud_user_credentials_username
CSUN=""
CSCD_PATTERN=cloud_user_credentials_domain
CSCD=""
CSCIPU_PATTERN=cloud_identity_provider_url
CSCIPU=""

# OpenNebula properties
ONERPC_PATTERN=opennebula_rpc_endpoint
ONERPC=""
ONEDD_PATTERN=default_datastore_id
ONEDD=""
ONEDN_PATTERN=default_network_id
ONEDN=""
ONEPN_PATTERN=default_public_network_id
ONEPN=""
ONEDRN_PATTERN=default_reservations_network_id
ONEDRN=""
ONEDSG_PATTERN=default_security_group_id
ONEDSG=""
ONEPASS_PATTERN=cloud_user_credentials_password
ONEPASS=""
ONEUN_PATTERN=cloud_user_credentials_username
ONEUN=""
ONECIPU_PATTERN=cloud_identity_provider_url
ONECIPU=""

# GoogleCloud properties
GOCZONE_PATTERN=zone
GOCZONE=""
GOCEMAIL_PATTERN=cloud_user_credentials_email
GOCEMAIL=""
GOCPID_PATTERN=cloud_user_credentials_project_id
GOCPID=""
GOCPRIVKEY_PATTERN=cloud_user_credentials_private_key_path
GOCPRIVKEY=""
GOCCIPU_PATTERN=cloud_identity_provider_url
GOCCIPU=""

read_aws() {
  # Reading cloud properties
  RS=$(grep $RS_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  AZ=$(grep $AZ_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  DSUB=$(grep $DSUB_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  DSEC=$(grep $DSEC_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  STGQ=$(grep $STGQ_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  EIP=$(grep $EIP_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  VPCQ=$(grep $VPCQ_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  CUCA=$(grep $CUCA_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CUCSA=$(grep $CUCSA_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_aws() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $RS_PATTERN=$RS > $CLOUD_CONF_FILE_PATH
  echo $AZ_PATTERN=$AZ >> $CLOUD_CONF_FILE_PATH
  echo $DSUB_PATTERN=$DSUB >> $CLOUD_CONF_FILE_PATH
  echo $DSEC_PATTERN=$DSEC >> $CLOUD_CONF_FILE_PATH
  echo $STGQ_PATTERN=$STGQ >> $CLOUD_CONF_FILE_PATH
  echo $EIP_PATTERN=$EIP >> $CLOUD_CONF_FILE_PATH
  echo $VPCQ_PATTERN=$VPCQ >> $CLOUD_CONF_FILE_PATH
  echo "aws_flavors_types_file_path_key=src/main/resources/private/clouds/aws/flavors.csv" >> $CLOUD_CONF_FILE_PATH
  yes | cp -f $COMMON_TEMPLATES/aws/flavors.csv $CLOUDS_DIR_PATH/$CLOUD_NAME
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $CUCA_PATTERN=$CUCA > $MAPPER_CONF_FILE_PATH
  echo $CUCSA_PATTERN=$CUCSA >> $MAPPER_CONF_FILE_PATH
  echo "cloud_identity_provider_url=" >> $MAPPER_CONF_FILE_PATH
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.AwsV2AllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.compute.v2.AwsComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.volume.v2.AwsVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.network.v2.AwsNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.attachment.v2.AwsAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.image.v2.AwsImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.publicip.v2.AwsPublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.securityrule.v2.AwsSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.aws.quota.v2.AwsQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

read_azure() {
  # Reading cloud properties
  VN=$(grep $VN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  RG=$(grep $RG_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  RN=$(grep $RN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  VMP=$(grep $VMP_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  CS=$(grep $CS_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CC=$(grep $CC_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CCK=$(grep $CCK_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CTI=$(grep $CTI_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_azure() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $VN_PATTERN=$VN > $CLOUD_CONF_FILE_PATH
  echo $RG_PATTERN=$RG >> $CLOUD_CONF_FILE_PATH
  echo $RN_PATTERN=$RN >> $CLOUD_CONF_FILE_PATH
  echo $VMP_PATTERN=$VMP >> $CLOUD_CONF_FILE_PATH
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $CS_PATTERN=$CS > $MAPPER_CONF_FILE_PATH
  echo $CC_PATTERN=$CC >> $MAPPER_CONF_FILE_PATH
  echo $CCK_PATTERN=$CCK >> $MAPPER_CONF_FILE_PATH
  echo $CTI_PATTERN=$CTI >> $MAPPER_CONF_FILE_PATH
  echo "cloud_identity_provider_url=" >> $MAPPER_CONF_FILE_PATH
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.AzureAllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.compute.AzureComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.volume.AzureVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.network.AzureNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.attachment.AzureAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.image.AzureImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.publicip.AzurePublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.securityrule.AzureSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.azure.quota.AzureQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

read_openstack() {
  # Reading cloud properties
  NOVA=$(grep $NOVA_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  NEUTRON=$(grep $NEUTRON_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  OSDN=$(grep $OSDN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  EG=$(grep $EG_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CINDER=$(grep $CINDER_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  GLANCE=$(grep $GLANCE_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  OSPN=$(grep $OSPN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  OSPASS=$(grep $OSPASS_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  OSUN=$(grep $OSUN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  OSCD=$(grep $OSCD_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  OSCIPU=$(grep $OSCIPU_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_openstack() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $NOVA_PATTERN=$NOVA > $CLOUD_CONF_FILE_PATH
  echo $NEUTRON_PATTERN=$NEUTRON >> $CLOUD_CONF_FILE_PATH
  echo $OSDN_PATTERN=$OSDN >> $CLOUD_CONF_FILE_PATH
  echo $EG_PATTERN=$EG >> $CLOUD_CONF_FILE_PATH
  echo $CINDER_PATTERN=$CINDER >> $CLOUD_CONF_FILE_PATH
  echo $GLANCE_PATTERN=$GLANCE >> $CLOUD_CONF_FILE_PATH
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $OSPN_PATTERN=$OSPN > $MAPPER_CONF_FILE_PATH
  echo $OSPASS_PATTERN=$OSPASS >> $MAPPER_CONF_FILE_PATH
  echo $OSUN_PATTERN=$OSUN >> $MAPPER_CONF_FILE_PATH
  echo $OSCD_PATTERN=$OSCD >> $MAPPER_CONF_FILE_PATH
  echo $OSCIPU_PATTERN=$OSCIPU >> $MAPPER_CONF_FILE_PATH
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.OpenStackAllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.compute.v2.OpenStackComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.volume.v2.OpenStackVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.network.v2.OpenStackNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.attachment.v2.OpenStackAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.image.v2.OpenStackImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.publicip.v2.OpenStackPublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.securityrule.v2.OpenStackSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.openstack.quota.v2.OpenStackQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

read_cloudstack() {
  # Reading cloud properties
  CSAPI=$(grep $CSAPI_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ZONE=$(grep $ZONE_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CSDN=$(grep $CSDN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  NO=$(grep $NO_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  CSPASS=$(grep $CSPASS_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CSUN=$(grep $CSUN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CSCD=$(grep $CSCD_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  CSCIPU=$(grep $CSCIPU_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_cloudstack() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $CSAPI_PATTERN=$CSAPI > $CLOUD_CONF_FILE_PATH
  echo $ZONE_PATTERN=$ZONE >> $CLOUD_CONF_FILE_PATH
  echo $CSDN_PATTERN=$CSDN >> $CLOUD_CONF_FILE_PATH
  echo $NO_PATTERN=$NO>> $CLOUD_CONF_FILE_PATH
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $CSPASS_PATTERN=$CSPASS > $MAPPER_CONF_FILE_PATH
  echo $CSUN_PATTERN=$CSUN >> $MAPPER_CONF_FILE_PATH
  echo $CSCD_PATTERN=$CSCD >> $MAPPER_CONF_FILE_PATH
  echo $CSCIPU_PATTERN=$CSCIPU >> $MAPPER_CONF_FILE_PATH
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.CloudStackAllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.compute.v4_9.CloudStackComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.volume.v4_9.CloudStackVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.network.v4_9.CloudStackNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.attachment.v4_9.CloudStackAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.image.v4_9.CloudStackImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.publicip.v4_9.CloudStackPublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.securityrule.v4_9.CloudStackSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.cloudstack.quota.v4_9.CloudStackQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

read_opennebula() {
  # Reading cloud properties
  ONERPC=$(grep $ONERPC_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEDD=$(grep $ONEDD_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEDN=$(grep $ONEDN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEPN=$(grep $ONEPN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEDRN=$(grep $ONEDRN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEDSG=$(grep $ONEDSG_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  ONEPASS=$(grep $ONEPASS_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONEUN=$(grep $ONEUN_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  ONECIPU=$(grep $ONECIPU_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_opennebula() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $ONERPC_PATTERN=$ONERPC > $CLOUD_CONF_FILE_PATH
  echo $ONEDD_PATTERN=$ONEDD >> $CLOUD_CONF_FILE_PATH
  echo $ONEDN_PATTERN=$ONEDN >> $CLOUD_CONF_FILE_PATH
  echo $ONEPN_PATTERN=$ONEPN >> $CLOUD_CONF_FILE_PATH
  echo $ONEDRN_PATTERN=$ONEDRN >> $CLOUD_CONF_FILE_PATH
  echo $ONEDSG_PATTERN=$ONEDSG >> $CLOUD_CONF_FILE_PATH
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $ONEPASS_PATTERN=$ONEPASS > $MAPPER_CONF_FILE_PATH
  echo $ONEUN_PATTERN=$ONEUN >> $MAPPER_CONF_FILE_PATH
  echo $ONECIPU_PATTERN=$ONECIPU >> $MAPPER_CONF_FILE_PATH
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.OpenNebulaAllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.compute.v5_4.OpenNebulaComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.volume.v5_4.OpenNebulaVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.network.v5_4.OpenNebulaNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.attachment.v5_4.OpenNebulaAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.image.v5_4.OpenNebulaImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.publicip.v5_4.OpenNebulaPublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.securityrule.v5_4.OpenNebulaSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.opennebula.quota.v5_4.OpenNebulaQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

read_googlecloud() {
  # Reading cloud properties
  GOCZONE=$(grep $GOCZONE_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  # Reading mapper properties
  GOCEMAIL=$(grep $GOCEMAIL_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  GOCPID=$(grep $GOCPID_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  GOCPRIVKEY=$(grep $GOCPRIVKEY_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
  GOCCIPU=$(grep $GOCCIPU_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)
}

write_googlecloud() {
  # Writing cloud.conf
  mkdir -p $CLOUDS_DIR_PATH/$CLOUD_NAME
  touch $CLOUD_CONF_FILE_PATH
  echo $GOCZONE_PATTERN=$GOCZONE >> $CLOUD_CONF_FILE_PATH
  # Writing mapper.conf
  touch $MAPPER_CONF_FILE_PATH
  echo $GOCEMAIL_PATTERN=$GOCEMAIL > $MAPPER_CONF_FILE_PATH
  echo $GOCPID_PATTERN=$GOCPID >> $MAPPER_CONF_FILE_PATH
  echo $GOCPRIVKEY_PATTERN=$GOCPRIVKEY >> $MAPPER_CONF_FILE_PATH
  echo $GOCCIPU_PATTERN=$GOCCIPU >> $MAPPER_CONF_FILE_PATH
  # Copying PrivateKey of mapper user
  yes | cp -f $CONF_FILE_DIR_PATH/$CLOUD_NAME/private.key $CLOUDS_DIR_PATH/$CLOUD_NAME
  # Writing plugins.conf
  touch $PLUGINS_CONF_FILE_PATH
  echo "system_to_cloud_mapper_plugin_class=cloud.fogbow.ras.core.plugins.mapper.all2one.GoogleCloudAllToOneMapper" > $PLUGINS_CONF_FILE_PATH
  echo "compute_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.compute.v1.GoogleCloudComputePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "volume_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.volume.v1.GoogleCloudVolumePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "network_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.network.v1.GoogleCloudNetworkPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "attachment_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.attachment.v1.GoogleCloudAttachmentPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "image_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.image.v1.GoogleCloudImagePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "public_ip_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.publicip.v1.GoogleCloudPublicIpPlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "security_rule_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.securityrule.v1.GoogleCloudSecurityRulePlugin" >> $PLUGINS_CONF_FILE_PATH
  echo "quota_plugin_class=cloud.fogbow.ras.core.plugins.interoperability.googlecloud.quota.v1.GoogleCloudQuotaPlugin" >> $PLUGINS_CONF_FILE_PATH
}

CLOUD_TYPE_PATTERN="cloud_type"
CLOUD_TYPE=$(grep $CLOUD_TYPE_PATTERN $CONF_FILE_PATH | cut -d"=" -f2-)

case $CLOUD_TYPE in
  "aws")
    read_aws
    write_aws
    ;;
  "azure")
    read_azure
    write_azure
    ;;
  "openstack")
    read_openstack
    write_openstack
    ;;
  "cloudstack")
    read_cloudstack
    write_cloudstack
    ;;
  "opennebula")
    read_opennebula
    write_opennebula
    ;;
  "googlecloud")
    read_googlecloud
    write_googlecloud
    ;;
  *)
    echo "Fatal error: invalid cloud type: [$CLOUD_TYPE]"
    exit 1
    ;;
esac