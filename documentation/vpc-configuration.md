# Creating and configuring a VPC
In the AWS Management Console look for the option **VPC** in **Networking & Content Delivery** from the all services menu.

## Creating a VPC
* Click on the **Your VPCs** menu and then on the **Create VPC** button.
* In the **IPv4 CIDR block** field, provide a CIDR. The range of IPv4 addresses for your VPC in
CIDR block format must be between a */16* netmask and */28* netmask. For example, *10.0.0.0/16*.
* In the **IPv6 CIDR block** field, select the **No IPv6 CIDR Block** option.
* In the **Tenancy** field, select the **Default** option.

Click the **Create** button to conclude.

## Creating a Security Group
* Click on the **Security Groups** menu and then on the **Create security group** button.
* Assign a name to the resource in the **Security group name** field.
* Fill in a description of the group in the **Description** field.
* In the **VPC** field, select the **VPC ID** previously created.

Click the **Create button** to conclude.

Use the ID of this security group to place as default it in the **cloudName**.conf file.

## Creating a Subnet
* Click on the **Subnet** menu and then on the **Create Subnet** button.
* In the **VPC** field, select the **VPC ID** previously created.
* In the **Availability Zone** field, select one zone (this is the same set in **cloudName**.conf.
* In the **IPv4 CIDR block** field, provide a CIDR. For example, *10.0.0.0/20*.
* Click on the **Tags** tab, and add the **groupId** in the **key** field, and put in the
**value** field the **security group ID** previously created.

Click on the **Create button** to conclude.

Use the ID of this subnet as the default set in the **cloudName**.conf file.

## Creating the Internet Gateways
* Click on the **Internet Gateways** menu and then on the **Create internet gateway** button.
* Optionally name this resource in the **Name tag** field.

Click the Create button to conclude.

## Creating the Route Tables
* Click on the **Route Tables** menu and then on the **Create route table** button.
* In the **VPC** field, select the **VPC ID** previously created.

Click the Create button to conclude.

## Configuring the Route Tables
* Select the route table created in the list of **Route Tables**.
* On the **Routes** tab, click on the **Edit routes** button and then on the **Add route** button.
* In the **Destination** field fill the default CIDR address *0.0.0.0/0* and in the **Target** field 
select the **Internet Gateway ID** previously created.
* In the **Subnet Associations** tab, click on the **Edit subnet associations** button, 
select the Subnet created in the list of **subnets**.

Conclude by clicking on the **Save** button.

####[Back to Configuring an AWS cloud page](aws.md)

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)