## Infrastructure setup

You will require an installation host, and one or two deployment hosts, depending on
which type of Fogbow instance you are deploying. There are two basic ways to use Fogbow.
You can use your Fogbow instance solely to manage multiple clouds to which you have direct
access (multi-cloud mode), or you might want your Fogbow instance to be part of a federation
of Fogbow instances, in this way, in addition to the clouds to which you have direct access,
you can also access clouds to which other Fogbow instances in the federation have direct
access (federation mode).

In the multi-cloud mode you need just one deployment machine, called the service host,
while in the federation mode you need an extra machine, called the DMZ (demilitarized
zone) host. The DMZ host must have a public IP. The service host need a public IP only
if you want users outside your organization to access your Fogbow instance. Otherwise,
the service host requires only a private IP.

### Installation machine setup

The installation host is a machine running any Unix-like operating system, on which Git and
Ansible can be installed. Additionally, it needs to have ssh access to the deployment hosts.

Log in the installation machine and perform the following steps:

S1. If not already installed, install [Git](https://help.github.com/articles/set-up-git/).

S2. If not already installed, install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

S3. If not already, installed, install pwgen:

```bash
# DEBIAN/UBUNTU
$ sudo apt-get install -y pwgen
# FEDORA
$ sudo dnf install -y pwgen
# CENTOS
$ sudo yum install -y pwgen
# MacOS
$ sudo brew install pwgen
```

S4. Install OpenSSH

```bash
# DEBIAN/UBUNTU
$ sudo apt install openssh-client
# FEDORA
$ sudo dnf install -y openssh-clients
# CENTOS
$ sudo yum install -y openssh-clients
# MacOS
$ sudo brew install openssh-clients
```

S5. Generate ssh keys to allow accessing the deployment machines without having to input
a password:

```bash
$ ssh-keygen -t rsa -f ~/.ssh/fogbow-deploy -q -N ""
```

S6. Download the *fogbow-deploy* project:

```bash
$ git clone https://github.com/fogbow/fogbow-deploy.git
```

S7. Checkout the appropriate branch (the latest version is in branch copacabana):

```bash
$ cd fogbow-deploy
$ git checkout copacabana
```

### Deployment machines setup

#### Service host setup

The service host also runs Linux, and must have at least 4Gbytes of RAM. It will run
all Fogbow services. All software required is automatically installed. Thus, setting up
the service host requires only configuring the firewall (or security groups, in case
you are using a virtual machine) to allow access to Fogbow services, and copy the ssh
public key to allow the installation scripts that run in the installation host to access
the service host.

S8. The following rules must be added to the firewall (security groups)

* **Ingress, Port 22 (SSH), from the IP address of the installation host.**
* **Ingress, Port 80 (HTTP), from the IP addresses that will be allowed to access your Fogbow instance.**
* **Ingress, Port 443 (HTTPS), from the IP addresses that will be allowed to access your Fogbow instance.**

S9. Copy the public ssh key in the service host authorized_keys file; considering the
keys generated in step S5, and assuming that the user running the installation in both
the installation and the service hosts is ubuntu (for example), you should add the
content of the file /home/ubuntu/.ssh/fogbow-deploy.pub in the installation host to
the content of the file /home/ubuntu/.ssh/authorized_keys in the service host.

#### DMZ host setup

The DMZ host is only required in federation mode. It also runs Linux, and must have
at least 2Gbytes of RAM. It runs all the XMPP and IPSEC servers. XMPP is used to allow
the Fogbow instances to communicate with each other. IPSEC is used to allow the creation
of virtual private networks, allowing secure tunnelled communication of virtual machines
running on different cloud providers.

Again, all software required is automatically installed. Thus, setting up the DMZ host
requires only configuring the firewall (or security groups, in case you are using a
virtual machine) to allow access to the XMPP and IPSEC servers, and copy the ssh public
key to allow the installation scripts that run in the installation host to access the
DMZ host.

S10. The following rules must be added to the firewall (security groups)

* **Ingress, Port 22 (SSH), from the IP address of the installation host.**
* **Ingress, Port 5347 (XMPP C2C), from the IP address of the service host.**
* **Ingress, Port 5269 (XMPP S2S), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 500 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 1701 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 4500 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**

S11. Copy the public ssh key in the service host authorized_keys file; considering the
keys generated in step S5, and assuming that the user running the installation in both
the installation and the service hosts is ubuntu (for example), you should add the
content of the file /home/ubuntu/.ssh/fogbow-deploy.pub in the installation host to
the content of the file /home/ubuntu/.ssh/authorized_keys in the service host.

#### DNS configuration

Now that the infrastructure has been created, you need to have the DNS configured, so to
enable the services running in the service host to be accessed by a name, and not an IP.
Also, if you are deploying a Fogbow instance in federation mode, then you must also create
a DNS name for the public IP of the DMZ host. See the example below:

* **service-host-name**          IN  A   **10.11.1.1**
* **dmz-host-name**              IN  A   **100.30.1.1**

Additionally, if deploying in federation mode, then you need to create a CNAME entry, as follows:

* **ras-service-host-name**      CNAME   **dmz-host-name**

####[Back to main installation page](main.md)