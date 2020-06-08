# Creating and configuring a VPC
In the AWS Management Console look for the option **VPC** in **Networking & Content Delivery** from all services.

## Creating a VPC
* Click the **Your VPCs** menu and then **Create VPC** button.
* In the **IPv4 CIDR block** field pass a CIDR. The range of IPv4 addresses for your VPC in CIDR block format must be between a */16* netmask and */28* netmask. For example, *10.0.0.0/16*.
* In the **IPv6 CIDR block** field, select the **No IPv6 CIDR Block** option.
* In the **Tenancy** field, select the **Default** option.

And click the **Create** button to finish the creation.

## Creating a Security Group
* Click the **Security Groups** menu and then the **Create security group** button.
* Assign a name to the resource in the **Security group name** field.
* Fill in a description of the group in the **Description** field.
* Select the VPC previously created in the **VPC** field. 

And click the **Create button** to finish the creation.

Use the ID of this security group to place as default it in the cloud.conf file.

## Creating a Subnet
* Click on the **Subnet** menu and then the **Create Subnet** button.
* In the **VPC** field, select the **VPC ID** creating previously.
* In the **Availability Zone** field, preferably select the zone provided by the cloud administrator.
* In the **IPv4 CIDR block** field, pass a CIDR. For example, *10.0.0.0/20*.
* Click on the **Tags** tab, and add the **groupId** in the **key** field, and put the **security group ID** created previously in the **value** field.

And click the **Create button** to finish the creation.

Use the ID of this subnet as a default to place in the cloud.conf file.

## Creating the Internet Gateways
* Click on the **Internet Gateways** menu and then on the **Create internet gateway** button.
* Optionally name this resource in the **Name tag** field.

And click the Create button to finish.

## Creating the Route Tables
* Click on the **Route Tables** menu and then on the **Create route table** button.
* In the **VPC** field, select the **VPC ID** creating previously.

And click the Create button to finish.

## Configuring the Route Tables
* Select the route table created in the list of **Route Tables**.
* On the **Routes** tab, click the **Edit routes** button and then on the **Add route** button.
* In the **Destination** field fill the default CIDR address *0.0.0.0/0* and in the **Target** field select the **Internet Gateway ID** created earlier.
* In the **Subnet Associations** tab, click the **Edit subnet associations** button, select the Subnet created in the list of **subnets**.

And finish by clicking the **Save** button.

####[Back to Configuring an AWS cloud page](aws.md)

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)