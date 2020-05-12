## Software installation

Now, you only need to go back to the fogbow-deploy directory, and run the installation script.

For multi-cloud mode run:

```bash
$ cd ..
$ bash install-multi-cloud.sh
```

For federation site mode run:

```bash
$ cd ..
$ bash install-federation.sh
```

Your Fogbow site should be up now. Open a browser and point it to **service-host-name.mydomain**,
log in using the appropriate credentials, and you are ready to manager resources
in the clouds accessible by your Fogbow instance.

It is a good idea to save a copy of the conf-files directory. This will be useful when
updating you site installation, since most of (if not all) the information in the
configuration files is typically preserved between successive deployments of a
Fogbow instance.