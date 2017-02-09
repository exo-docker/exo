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

## eXo Platform version

|    Image                          |  JDK  |   eXo Platform    |  Size
|-----------------------------------|-------|-------------------|----------------
| exoplatform/exo:latest            |   8   | 4.4.0             |[![](https://badge.imagelayers.io/exoplatform/exo:latest.svg)](https://imagelayers.io/?images=exoplatform/exo:latest 'Get your own badge on imagelayers.io')
| exoplatform/exo:develop           |   8   | 4.4.0             |[![](https://badge.imagelayers.io/exoplatform/exo:develop.svg)](https://imagelayers.io/?images=exoplatform/exo:develop 'Get your own badge on imagelayers.io')
| exoplatform/exo:4.3_latest        |   8   | 4.3.x             |[![](https://badge.imagelayers.io/exoplatform/exo:4.3_latest.svg)](https://imagelayers.io/?images=exoplatform/exo:4.3_latest 'Get your own badge on imagelayers.io')

# Configuration

## JVM

The standard eXo Platform environment variables can be used :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_JVM_SIZE_MIN | NO | `512m` | specify the jvm minimum allocated memory size (-Xms parameter)
| EXO_JVM_SIZE_MAX | NO | `3g` | specify the jvm maximum allocated memory size (-Xmx parameter)
| EXO_JVM_PERMSIZE_MAX | NO | `256m` | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)
| EXO_JVM_METASPACE_SIZE_MAX | NO | `512m` | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter)
| EXO_JVM_USER_LANGUAGE | NO | `en` | specify the jvm maximum allocated memory size (-Duser.language parameter)
| EXO_JVM_USER_REGION | NO | `US` | specify the jvm maximum allocated memory size (-Duser.region parameter)

This list is not exhaustive (see eXo Platform documentation or {EXO_HOME}/bin/setenv.sh for more parameters)

## Frontend proxy

The following environment variables must be passed to the container to configure proxy settings:

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_PROXY_VHOST | NO | `localhost` | specify the virtual host name to reach eXo Platform
| EXO_PROXY_SSL | NO | `true` | is ssl activated on the proxy server ? (true / false)

## Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_HTTP_THREAD_MAX | NO | `200` | maximum number of threads in the tomcat http connector
| EXO_HTTP_THREAD_MIN | NO | `10` | minimum number of threads ready in the tomcat http connector

## Data on disk

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DATA_DIR | NO | `/srv/exo` | the directory to store eXo Platform data

## Database

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DB_TYPE | NO | `mysql` | mysql / hsqldb / pgsql / ora
| EXO_DB_NAME | NO | `exo` | the name of the database / schema to use
| EXO_DB_USER | NO | `exo` | the username to connect to the database
| EXO_DB_PASSWORD | YES | - | the password to connect to the database
| EXO_DB_HOST | NO | `mysql` | the host to connect to the database server
| EXO_DB_PORT | NO | `3306` | the port to connect to the database server
| EXO_DB_INSTALL_DRIVER | NO | `true` | automatically install the good jdbc driver add-on (true / false)
| EXO_DB_POOL_IDM_INIT_SIZE | NO | `5` | the init size of IDM datasource pool
| EXO_DB_POOL_IDM_MAX_SIZE | NO | `20` | the max size of IDM datasource pool
| EXO_DB_POOL_JCR_INIT_SIZE | NO | `5` | the init size of JCR datasource pool
| EXO_DB_POOL_JCR_MAX_SIZE | NO | `20` | the max size of JCR datasource pool
| EXO_DB_POOL_JPA_INIT_SIZE | NO | `5` | the init size of JPA datasource pool
| EXO_DB_POOL_JPA_MAX_SIZE | NO | `20` | the max size of JPA datasource pool

## Mongodb

The following environment variables should be passed to the container in order to work if you use eXo Chat :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_MONGO_HOST | NO | `mongo` | the hostname to connect to the mongodb database for eXo Chat 
| EXO_MONGO_PORT | NO | `27017` | the port to connect to the mongodb server
| EXO_MONGO_USERNAME | NO | - | the username to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_PASSWORD | NO | - | the password to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_DB_NAME | NO | `chat` | the mongodb database name to use for eXo Chat 

## ElasticSearch

The following environment variables should be passed to the container in order to configure the search feature :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_ES_EMBEDDED | NO | `true` | do we use an elasticsearch server embedded in the eXo Platform JVM or do we use an external one ? (using an embedded elasticsearch server is not recommanded for production purpose)
| EXO_ES_EMBEDDED_DATA | NO | `/srv/es/` | The directory to use for storing elasticsearch data (in embedded mode only).
| EXO_ES_SCHEME | NO | `http` | the elasticsearch server scheme to use from the eXo Platform server jvm perspective (http / https).
| EXO_ES_HOST | NO | `localhost` | the elasticsearch server hostname to use from the eXo Platform server jvm perspective.
| EXO_ES_PORT | NO | `9200` | the elasticsearch server port to use from the eXo Platform server jvm perspective.
| EXO_ES_USERNAME | NO | - | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).
| EXO_ES_PASSWORD | NO | - | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).


## JMX

The following environment variables should be passed to the container in order to configure JMX :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_JMX_ENABLED | NO | `true` | activate JMX listener
| EXO_JMX_RMI_REGISTRY_PORT | NO | `10001` | JMX RMI Registry port
| EXO_JMX_RMI_SERVER_PORT | NO | `10002` | JMX RMI Server port
| EXO_JMX_RMI_SERVER_HOSTNAME | NO | `localhost` | JMX RMI Server hostname
| EXO_JMX_USERNAME | NO | - | a username for JMX connection (if no username is provided, the JMX access is unprotected)
| EXO_JMX_PASSWORD | NO | - | a password for JMX connection (if no password is specified a random one will be generated and stored in /opt/exo/conf/jmxremote.password)

With the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

## License

The eXo Platform license file location must be `/etc/exo/license.xml`

# Testing

We provide some docker-compose files for testing various configurations in the test folder

    # eXo Platform 4.3.x + hsqldb
    docker-compose -f test/docker-compose-43-hsqldb.yml -p exo43hsqldb up

    # eXo Platform 4.3.x + MySQL 5.5
    docker-compose -f test/docker-compose-43-mysql.yml -p exo43mysql up

    # eXo Platform 4.3.x + Postgresql 9.4
    docker-compose -f test/docker-compose-43-pgsql.yml -p exo43pgsql up

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
