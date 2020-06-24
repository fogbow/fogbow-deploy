## Configuring an AWS cloud

Firstly, you need to define which resources in the AWS cloud you will make available
through Fogbow. It is necessary to create an Identity and Access Management User, called 
**IAM user** with administrator permissions. Associated to this user there will be an
**access key** ID and a **secret access key**. These values should be assigned, respectively,
to the properties **cloud_user_credentials_access_key** and
**cloud_user_credentials_secret_access_key**.

You must also set the **region** and **availability zone** for the user account created.
For example, **aws_region_selection_key**=*sa-east-1* and
**aws_availability_zone_key**=*sa-east-1a*.

Additionally, include the quota values for the following resource properties, related to
the selected region:

* **Storage quota**: the maximum aggregate amount of storage that can be provisioned in this
Region. For example, **aws_storage_quota_key**=*300*;
* **Elastic IP Addresses quota**: the number of Elastic IP addresses to use with a VPC.
For example, **aws_elastic_ip_addresses_quota_key**=*5*;
* **Virtual Private Cloud quota**: the total number of VPCs by Region.
For example, **aws_vpc_quota_key**=*5*;

You will need to create and configure a **VPC** with a default subnet that provides access
to a shared private network and a default security group for that network, as
explained in this [tutorial](vpc-configuration.md).

After creating the VPC, use its **default subnet ID** and its **default security group ID**
to define, respectively, properties **aws_default_subnet_id_key** and **aws_default_security_group_id_key**.

The conf-files/clouds/**cloudName**.conf will look like this:

```
$ cat clouds/cloudName.conf
cloud_type=aws

aws_region_selection_key=sa-east-1
aws_availability_zone_key=sa-east-1a
aws_default_subnet_id_key=subnet-045038cd60e372274
aws_default_security_group_id_key=sg-00bb52aad68c8dadb
aws_storage_quota_key=300
aws_elastic_ip_addresses_quota_key=5
aws_vpc_quota_key=5

cloud_user_credentials_access_key=AJIAHJY672RDMW7P6UCW 
cloud_user_credentials_secret_access_key=aBVS5Wdrk76pfccJkr/kMlpraNkB6d9GUAWEdjyH 
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)