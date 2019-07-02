# docker-nZEDb

![nZEDb master](https://img.shields.io/badge/nZEDb-master-green.svg)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/reijkelenberg/docker-nzedb.svg)
![License unspecified](https://img.shields.io/badge/license-unspecified-blue.svg)

This is a fork of [Grimeton/docker-nzedb](https://github.com/Grimeton/docker-nzedb), which hasn't been updated for a couple of years now. Nevertheless, it's quite a neat image - which is why I forked it. 

The Docker image created by the Dockerfile in this repository contains the following changes:
* Based on Ubuntu 18.04 [old: Ubuntu 16.10],
* Uses PHP7.2 [old: PHP7.0],
* Set default timezone to UTC,
* Does not use GitHub OAuth tokens anymore (switch to branch `token` if you want to use Composer with OAuth tokens),
* YYDecode has been removed for now, as it is not compatible with (the out-of-date) PHP7.0,
* Remove php-mcrypt, as a) it is deprecated in PNP7.2 and b) is, to the extent of my knowledge, not being used by nZEDb,
* Force use of Composer 1.8.x as any future 2.x version of Composer will be incompatible with nZEDb's composer configs,
* Some messages were made more verbose.

The Dockerfile and image are quite small. A lot of stuff will be configured when you run the container for the first time. This may take some time (in particular the installation of Composer modules).

Upon first run, the latest version of nZEDb will be downloaded.

# README

nZEDb container based on nZEDb from https://github.com/nZEDb/nZEDb
This image is able to run under a different web root than "/". E.g. https://your.server/nzedb/

**WARNING**: Not all themes are able to handle a subdomain. So far the best theme is "Omicron". Other themes are poorly implemented and the links don't work when used with https. That's not nZEDb's or Smarty's fault. The problem is in how the themes are written. 

The image is based on Ubuntu Yakkety. Alpine is not an option at the moment as of PHP dependency problems.

Requirements:

- Mysql Database (not included)
- Docker :)

To install and run the container use:

`docker create --name nzedb reijkelenberg/docker-nzedb`

Available environment variables:

* **PATH_CUSTOM_CONFIG** - Default: EMPTY
A path to a directory inside the container that contains custom configuration files that should be copied over instead of using the defaults or a template. It should contain a subdirectory for every supported software that should be configured. So far the following subdirectories are supported:
    * nzedb
        * config.php - Will be copied to nzedb_root/configuration/config.php and nzedb_root/configuration/install.lock will be created.


* **PATH_INSTALL_ROOT** - Default: "/opt/http"
 Where nZEDb should be installed. The Path actually is the top level path of everything nZEDb. It also becomes part of the **PATH_WEB_SERVER_ROOT** variable. 

* **PATH_WEB_RESOURCES** - Default: "/data/resources".
The path inside the container where resources like covers, nzbs and stuff should be stored. It's a good idea to put this **OUTSIDE** the container so that the information isn't lost on update. 

* **PATH_WEB_SERVER_ROOT** - Default: "$PATH_INSTALL_ROOT/www"
The web server's root DIRECTORY. Right now changes to this create unexpected results.

* **TZ** - Timezone to be used. 
Check /usr/share/zoneinfo/ for available timezones.

* **PHP_MAX_EXECUTION_TIME** - Default: "120".
Maximum time PHP scripts execute. Self explaining. If not, check [PHP configuration parameters](http://php.net/manual/en/info.configuration.php#ini.max-execution-time).

* **PHP_MEMORY_LIMIT** - Default: "1G"
Maximum memory a script can consum. Self explaining. If not, check [PHP configuration parameters](http://php.net/manual/en/ini.core.php#ini.memory-limit). Allowed characters after the integer are "k|K|m|M|g|G". 

* **PHP_TIMEZONE** - Default: "$TZ"
The timezone PHP should use. If not set uses the default timezone set via **TZ**. See the description of the **TZ** variable.

* **REFRESH_POSTPROCESS_OPTIONS** - Default: "nfo mov tv ama"
The postprocessing options handed to misc/update/nix/multiprocessing/postprocess.php. Check the help of postprocess.php for more information (run php postprocess.php without any arguments).

 At the time of writing, the allowed options are:
 * ama => Do amazon processing, this does not use multi-processing, because of amazon API restrictions.
 * add => Do additional (rar|zip) processing.
 * mov => Do movie processing.
 * nfo => Do NFO processing.
 * sha => Do sharing processing, this does not using multi-processing.
 * tv  => Do TV processing.


* **RUN_WEB_SERVER** - Default: "1"
Run the webserver?. If you don't want to run the webserver in this container and the updater only, then you can set this to "0" and offer a custom configuration for nZEDb. This will only run the updater and nothing else. Might come in handy to spread the load accross multiple systems.

* **RUN_REFRESH** - Default: "0"
Run the updater in the background? If set to "1" then the update script will run in the background. There is no timeout or anything. It constantly runs and updates the databse with new entries. You can set this to "0" in case you don't want to run the updater inside this container. The refresh only starts after the system has been configured. Either by custom config, see **PATH_CUSTOM_CONFIG** or through the web interface after installation.

* **WEB_ROOT** - Default: "/"
The web server's web root. The URI that the web server responds to. It is important that there is no trailing slash. Can be anything. E.g. "/nzedb" or "/superindexer" or "/some/path/to/the/indexer". Read the warning at the top of the page regarding the themes of nZEDb.

* **WEB_SERVER_HTTP_PORT** - Default: 80
The port to listen on for HTTP requests. Self explaining.

* **WEB_SERVER_HTTPS_PORT** - Default: 443 (NOT IMPLEMENTED YET)
**Not yet implemented.** The port to listen on for HTTPS requests. Will implement Let's Encrypt certificates with automatic update. Working on it...

* **WEB_SERVER_NAME** - Default: "_"
The domain name of the web server. E.g. "hub.docker.com". It is important to note that this name should be set as there are redirects in play which will lead to nowhere if not set correctly. If you don't have a name, set the ip address here.

* *(**Deprecated** - This option is (only) **absolutely mandatory** in the branch `token` (or the `:token` tag when pulling the image).)* GIT_TOKEN - Default: EMPTY
~~It is absoloutly mandatory. No token, no fun!.~~ A GitHUB access token. The token is necessary because during the first start all the parts of the image are pulled directly from github and installed in the image. If this token is not there, then the composer installation of nZEDb and everything else **FAILS**.

**This is a basic setup that should be behind an nginx reverse proxy or something similar.**
The setup is able to detect if https is used on the reverse proxy or not so it automagically uses the correct protocol.

After you started the image for the first time and try to access nZEDb via web you will always be redirected to the setup until nZEDb has been configured. To make this happen, nginx's config file contains an if statement. As [if is evil](https://www.nginx.com/resources/wiki/start/topics/depth/ifisevil/), the nginx configuration will be replaced by one without it and a disabled install directory after the container has been configured and restarted. 

A full blown "installation" would look something like this:

    docker create \
        -e GIT_TOKEN="SOME_GIT_TOKEN_HERE" \
        -e TZ="Europe/Berlin" \
        -e PATH_INSTALL_ROOT="/opt/http" \
        -e PATH_WEB_RESOURCES="/data/resources" \
        -e PATH_WEB_SERVER_ROOT="/opt/http/www" \
        -e PHP_MAX_EXECUTION_TIME="120" \
        -e PHP_MEMORY_LIMIT="1G" \
        -e PHP_TIMEZONE="Europe/Berlin" \
        -e REFRESH_POSTPROCESS_OPTIONS="nfo mov tv ama" \
        -e RUN_WEB_SERVER="1" \
        -e RUN_REFRESH="0" \
        -e WEB_ROOT="/" \
        -e WEB_SERVER_HTTP_PORT="80" \
        -e WEB_SERVER_HTTPS_PORT="443" \
        -e WEB_SERVER_NAME="www.topusenetindexer.com" \
        --hostname "$container_hostname" \
        --ip 1.2.3.4 \
        --name "$container_name" \
        --net "$network_name" \
        -v /etc/ssl/certs:/etc/ssl/certs:ro \
        -v /nzedbresources:/data \
        grimages/nzedb:latest

Usually it's fine to just setup the mandatory options:


    docker create \
        -e GIT_TOKEN="SOME_GIT_TOKEN_HERE" \
        -e TZ="Europe/Berlin" \
        -e PATH_WEB_RESOURCES="/data/resources" \
        -e WEB_SERVER_NAME="www.topusenetindexer.com" \
        --hostname "$container_hostname" \
        --ip 1.2.3.4 \
        --name "$container_name" \
        --net "$network_name" \
        -v /etc/ssl/certs:/etc/ssl/certs:ro \
        -v /nzedbresources:/data \
        grimages/nzedb:latest


If you want to "hide" the setup behind Nginx here's a config snippet that provides a reverse proxy configuration for the container: 

    location /web_root/ {
        proxy_buffering off;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_redirect off;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://container_ip/web_root/;
    }

Next steps:

- Add full HTTPS support

