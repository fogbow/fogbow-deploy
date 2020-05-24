## Software installation

Now, you only need to go back to the fogbow-deploy directory, and run the installation script.

For multi-cloud mode run:

```bash
$ cd ..
$ bash install-multi-cloud.sh
```

For federation mode run:

```bash
$ cd ..
$ bash install-federation.sh
```

After the installation successfully completes, your Fogbow node should be up. Open a browser and point
it to your Fogbow node FQDN (for example, **https://fogbow-node.mydomain/**). Then, log in using the
appropriate credentials, and you should be ready to manager resources in the clouds accessible through
your Fogbow node. Fogbow has also a Command Line Interface (CLI) and a RESTful API. You can download and
install the CLI from **http://github.com/fogbow/fogbow-cli.git** (see documentation in that repository).
Documentation of the RESTful API is accessible online from the Fogbow node service that you have just
deployed. Simply access the "/doc" endpoint (for example, **https://fogbow-node.mydomain/doc**).

It is a good idea to save a copy of the conf-files directory. This will be useful when
updating you node installation, since most of the information in the configuration files
(if not all) is typically preserved between successive deployments of a Fogbow node.

####[Back to main installation page](main.md)