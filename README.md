# eXo Docker container

[![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo.svg?maxAge=2592000)]() - [![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo.svg?maxAge=2592000)]()

The aim of this repository is to give the configuration to run eXo Platform in a Docker containers for production purpose.

# Image compatibility
## Databases

The image is now compatible with the following databases system :

* `MySQL` (default)
* `HSQLDB`
* `Postgresql`
* `Oracle`

# Configuration

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DB_TYPE | NO | `mysql` | mysql / hsqldb / pgsql / ora
| EXO_DB_NAME | NO | `exo` | the name of the database / schema to use
| EXO_DB_USER | NO | `exo` | the username to connect to the database
| EXO_DB_PASSWORD | YES | - | the password to connect to the database
| EXO_DB_HOST | NO | `mysql` | the host to connect to the database server
| EXO_DB_PORT | NO | `3306` | the port to connect to the database server
| EXO_DATA_DIR | NO | `/srv/exo` | the directory to store eXo Platform data

## License

The eXo Platform license file location must be `/etc/exo/license.xml`

# Image build

The simplest way to build this image is to use default values :

    docker build -t exoplatform/exo .

This will produce an image with the current eXo Platform enterprise version and 3 bundled add-ons : eXo Chat, eXo Tasks, eXo Remote Edit.

|    ARGUMENT NAME    |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| ADDONS | NO | `exo-chat exo-tasks exo-remote-edit` | a space separated list of add-ons to install
| EXO_VERSION | NO | latest stable version | the full version number of the eXo Platform to package
| DOWNLOAD_URL | NO | public download url | the full url where the eXo Platform binary must be downloaded
| DOWNLOAD_USER | NO | - | a username to use for downloading the eXo Platform binary


If you want to bundle a particular list of add-ons :

    docker build \
        --build-arg ADDONS="exo-chat exo-staging-extension:2.6.0" \
        -t exoplatform/exo:my_version .

If you want to build a particular version of eXo Platform just pass the good arguments :

    docker build \
        --build-arg EXO_VERSION=4.3.1 \
        -t exoplatform/exo:4.3.1 .

If you want to specify an alternate public download url :

    docker build \
        --build-arg DOWNLOAD_URL=http://my.host/my-own-download-link.zip \
        -t exoplatform/exo:my_version .

If you want to specify an alternate authenticated download url :

    docker build \
        --build-arg DOWNLOAD_URL=http://my.host/my-own-download-link.zip \
        --build-arg DOWNLOAD_USER=my-username
        -t exoplatform/exo:my_version .

The password will be required during the build at the download step.
