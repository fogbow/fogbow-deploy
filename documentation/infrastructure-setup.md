## Infrastructure setup

You will require an installation host, and one or two deployment hosts, depending on
which type of Fogbow node you are deploying. There are two basic ways to use Fogbow.
You can use your Fogbow node solely to manage multiple clouds to which you have direct
access (multi-cloud mode), or you might want your Fogbow node to be part of a federation
of Fogbow nodes, in this way, in addition to the clouds to which you have direct access,
you can also indirectly access clouds to which other Fogbow nodes in the federation have
direct access (federation mode).

In the multi-cloud mode you need just one deployment host, called the service host,
while in the federation mode you need an extra host, called the DMZ (demilitarized
zone) host. The DMZ host must have a public IP and a FQDN (Fully Qualified Domain Name)
that resolves to this IP. The service host need a public IP, only if you want users outside
your organization to access your Fogbow node. Otherwise, the service host requires only a
private IP. Whether the service host uses public or private IP, you will also need to have
a DNS entry that resolves to this IP. For example:

* **<service-host-name>**          IN  A   **10.11.1.1**
* **<dmz-host-name>**              IN  A   **100.30.1.1**

where <service-host-name>  and <dmz-host-name> are, respectively, the DNS names that 
you have chosen for the service and the DMZ hosts. For example, **fogbow-node** and
**dmz-host**.

Additionally, if deploying in federation mode, then you need to create a CNAME entry, as follows:

* **ras-<service-host-name>**      CNAME   **<dmz-host-name>**

### Installation host setup

The installation host is a machine running any Unix-like operating system.
Additionally, it needs to have ssh access to the deployment hosts.

Log in the installation machine and perform the following steps:

S1. If not already installed, install [Git](https://help.github.com/articles/set-up-git/).

S2. If not already installed, install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

S3. If not already installed, install pwgen:

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

S4. If not already installed, install OpenSSH

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

### Deployment hosts setup

#### Service host setup

The service host also runs Linux, and must have at least 4Gbytes of RAM. It will run
all Fogbow services. All software required is automatically installed. Thus, setting up
the service host requires only configuring the firewall (or security groups, in case
you are using a virtual machine) to allow access to Fogbow services, and copy the ssh
public key to allow the installation scripts that run in the installation host to access
the service host.

S6. The following rules must be added to the firewall (security groups)

* **Ingress, Port 22 (SSH), from the IP address of the installation host.**
* **Ingress, Port 80 (HTTP), from the IP addresses that will be allowed to access your Fogbow node.**
* **Ingress, Port 443 (HTTPS), from the IP addresses that will be allowed to access your Fogbow node.**

S7. Copy the public ssh key in the service host authorized_keys file; considering the
keys generated in step S5, and assuming that the user running the installation in both
the installation and the service hosts is ubuntu (for example), you should edit the
file /home/ubuntu/.ssh/authorized_keys in the service host and add to it the content
of the file /home/ubuntu/.ssh/fogbow-deploy.pub in the installation host.

S8. Enable the user that will run the installation scripts at the service host to run
sudo without the need to enter a password. Open the /etc/sudoers file (as root, of course!) by running:
                                           
```
$ sudo visudo
```
                                           
 At the end of the /etc/sudoers file add this line (where username is the name of the user, eg. ubuntu):
                                           
 username     ALL=(ALL) NOPASSWD:ALL

#### DMZ host setup

The DMZ host is only required in federation mode. It also runs Linux, and must have
at least 2Gbytes of RAM. It runs the XMPP and IPSEC servers. XMPP is used to allow
the Fogbow node to communicate with other nodes in the federation. IPSEC is used to
allow the creation of virtual private networks across different cloud providers, allowing
secure tunnelled communication of virtual machines running on these providers.

Again, all software required is automatically installed. Thus, setting up the DMZ host
requires only configuring the firewall (or security groups) to allow access to the XMPP
and IPSEC servers, and copy the ssh public key to allow the installation scripts that
run in the installation host to access the DMZ host.

S9. The following rules must be added to the firewall (security groups)

* **Ingress, Port 22 (SSH), from the IP address of the installation host.**
* **Ingress, Port 5347 (XMPP C2C), from the IP address of the service host.**
* **Ingress, Port 5269 (XMPP S2S), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 500 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 1701 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**
* **Ingress, Port 4500 (IPSEC), from the IP addresses of the DMZ hosts of the other federation members.**

S10. Copy the public ssh key in the service host authorized_keys file; considering the
keys generated in step S5, and assuming that the user running the installation in both
the installation and the service hosts is ubuntu (for example), you should edit the
file /home/ubuntu/.ssh/authorized_keys in the DMZ host and add to it the content
of the file /home/ubuntu/.ssh/fogbow-deploy.pub in the installation host.

S11. Enable the user that will run the installation scripts at the service host to run sudo without the
need to enter a password. Open the /etc/sudoers file (as root, of course!) by running:

```
$ sudo visudo
```

At the end of the /etc/sudoers file add this line (where username is the name of the user, eg. ubuntu):

username     ALL=(ALL) NOPASSWD:ALL

####[Back to main installation page](main.md)