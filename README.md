# eXo Platform Docker image

[![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo.svg)]() - [![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo.svg)]()

|    Image                          |  JDK  |   eXo Platform    
|-----------------------------------|-------|-------------------
| exoplatform/exo:develop           |   8   | 4.4.3 Enterprise edition
| exoplatform/exo:5.0_latest        |   8   | 5.0.x Enterprise edition 
| exoplatform/exo:4.4_latest        |   8   | 4.4.3 Enterprise edition
| exoplatform/exo:4.3_latest        |   8   | 4.3.x Enterprise edition

The image is compatible with the following databases system :

* `MySQL` (default)
* `HSQLDB`
* `Postgresql`
* `Oracle`

# Configuration options

## Add-ons

Some add-ons are already installed in eXo image but you can install other one or remove some of the pre-installed one :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_ADDONS_LIST | NO | - | commas separated list of add-ons to install (ex: exo-answers,exo-skype:1.0.x-SNAPSHOT)
| EXO_ADDONS_REMOVE_LIST | NO | - | commas separated list of add-ons to uninstall (ex: exo-chat,exo-es-embedded) (since: 4.4.2_3)

## JVM

The standard eXo Platform environment variables can be used :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_JVM_SIZE_MIN | NO | `512m` | specify the jvm minimum allocated memory size (-Xms parameter)
| EXO_JVM_SIZE_MAX | NO | `3g` | specify the jvm maximum allocated memory size (-Xmx parameter)
| EXO_JVM_PERMSIZE_MAX | NO | `256m` | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)
| EXO_JVM_METASPACE_SIZE_MAX | NO | `512m` | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter)
| EXO_JVM_USER_LANGUAGE | NO | `en` | specify the jvm locale for langage (-Duser.language parameter)
| EXO_JVM_USER_REGION | NO | `US` | specify the jvm local for region (-Duser.region parameter)

INFO: This list is not exhaustive (see eXo Platform documentation or {EXO_HOME}/bin/setenv.sh for more parameters)

## Frontend proxy

The following environment variables must be passed to the container to configure Tomcat proxy settings:

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_PROXY_VHOST | NO | `localhost` | specify the virtual host name to reach eXo Platform
| EXO_PROXY_PORT | NO | - | which port to use on the proxy server ? (if empty it will automatically defined regarding EXO_PROXY_SSL value : true => 443 / false => 80)
| EXO_PROXY_SSL | NO | `true` | is ssl activated on the proxy server ? (true / false)

## Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_HTTP_THREAD_MAX | NO | `200` | maximum number of threads in the tomcat http connector
| EXO_HTTP_THREAD_MIN | NO | `10` | minimum number of threads ready in the tomcat http connector

### Valves and Listeners

A file containing the list of valves and listeners can be attached to the container in the path {{/etc/exo/host.yml}}. If a file is specified, the default valves and listeners configuraiton will be overriden.

The file format is :
```
components:
  - type: Valve
    className: org.acme.myvalves.WthoutAttributes
  - type: Valve
    className: org.acme.myvalves.WthAttributes
    attributes:
      - name: param1
        value: value1
      - name: param2
        value: value2
  - type: Listener
    className: org.acme.mylistener.WthAttributes
    attributes:
      - name: param1
        value: value1
      - name: param2
        value: value2
```

## Data on disk

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DATA_DIR | NO | `/srv/exo` | the directory to store eXo Platform data
| EXO_JCR_STORAGE_DIR | NO | `${EXO_DATA_DIR}/jcr/values` | the directory to store eXo Platform JCR values data
| EXO_FILE_STORAGE_DIR | NO | `${EXO_DATA_DIR}/files` | the directory to store eXo Platform data
| EXO_FILE_STORAGE_RETENTION | NO | `30` | the number of days to keep deleted files on disk before definitively remove it from the disk
| EXO_UPLOAD_MAX_FILE_SIZE | NO | `200` | maximum authorized size for file upload in MB.

## Database

The following environment variables must be passed to the container in order to work :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DB_TYPE | NO | `mysql` | mysql / hsqldb / pgsql / ora
| EXO_DB_HOST | NO | `mysql` | the host to connect to the database server
| EXO_DB_PORT | NO | `3306` | the port to connect to the database server
| EXO_DB_NAME | NO | `exo` | the name of the database / schema to use
| EXO_DB_USER | NO | `exo` | the username to connect to the database
| EXO_DB_PASSWORD | YES | - | the password to connect to the database
| EXO_DB_INSTALL_DRIVER | NO | `true` | automatically install the good jdbc driver add-on (true / false)
| EXO_DB_POOL_IDM_INIT_SIZE | NO | `5` | the init size of IDM datasource pool
| EXO_DB_POOL_IDM_MAX_SIZE | NO | `20` | the max size of IDM datasource pool
| EXO_DB_POOL_JCR_INIT_SIZE | NO | `5` | the init size of JCR datasource pool
| EXO_DB_POOL_JCR_MAX_SIZE | NO | `20` | the max size of JCR datasource pool
| EXO_DB_POOL_JPA_INIT_SIZE | NO | `5` | the init size of JPA datasource pool
| EXO_DB_POOL_JPA_MAX_SIZE | NO | `20` | the max size of JPA datasource pool

## Mongodb

The following environment variables should be passed to the container in order to work if you have installed eXo Chat :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_MONGO_HOST | NO | `mongo` | the hostname to connect to the mongodb database for eXo Chat 
| EXO_MONGO_PORT | NO | `27017` | the port to connect to the mongodb server
| EXO_MONGO_USERNAME | NO | - | the username to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_PASSWORD | NO | - | the password to use to connect to the mongodb database (no authentification configured by default)
| EXO_MONGO_DB_NAME | NO | `chat` | the mongodb database name to use for eXo Chat 

INFO: you must configure and start an external MongoDB server by yourself

## ElasticSearch

The following environment variables should be passed to the container in order to configure the search feature :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_ES_EMBEDDED | NO | `true` | do we use an elasticsearch server embedded in the eXo Platform JVM or do we use an external one ? (using an embedded elasticsearch server is not recommanded for production purpose)
| EXO_ES_EMBEDDED_DATA | NO | `/srv/exo/es/` | The directory to use for storing elasticsearch data (in embedded mode only).
| EXO_ES_SCHEME | NO | `http` | the elasticsearch server scheme to use from the eXo Platform server jvm perspective (http / https).
| EXO_ES_HOST | NO | `localhost` | the elasticsearch server hostname to use from the eXo Platform server jvm perspective.
| EXO_ES_PORT | NO | `9200` | the elasticsearch server port to use from the eXo Platform server jvm perspective.
| EXO_ES_USERNAME | NO | - | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).
| EXO_ES_PASSWORD | NO | - | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).
| EXO_ES_INDEX_REPLICA_NB | NO | `0` | the number of replicat for elasticsearch indexes (leave 0 if you don't have an elasticsearch cluster).
| EXO_ES_INDEX_SHARD_NB | NO | `0` | the number of shard for elasticsearch indexes.

INFO: the default embedded ElasticSearch in not recommended for production purpose.

## LDAP / Active Directory

The following environment variables should be passed to the container in order to configure the ldap connection pool :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_LDAP_POOL_DEBUG      | NO | - | the level of debug output to produce. Valid values are "fine" (trace connection creation and removal) and "all" (all debugging information).
| EXO_LDAP_POOL_TIMEOUT    | NO | `60000` | the number of milliseconds that an idle connection may remain in the pool without being closed and removed from the pool.
| EXO_LDAP_POOL_MAX_SIZE   | NO | `100` | the maximum number of connections per connection identity that can be maintained concurrently.


## JOD Converter

The following environment variables should be passed to the container in order to configure jodconverter :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE  |  DESCRIPTION
|--------------------------|-------------|------------------|----------------
| EXO_JODCONVERTER_PORTS   | NO          | `2002`           | comma separated list of ports to allocate to JOD Converter processes (ex: 2002,2003,2004)

## Mail

The following environment variables should be passed to the container in order to configure the mail server configuration to use :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_MAIL_FROM | NO | `noreply@exoplatform.com` | "from" field of emails sent by eXo platform
| EXO_MAIL_SMTP_HOST | NO | `localhost` | SMTP Server hostname
| EXO_MAIL_SMTP_PORT | NO | `25` | SMTP Server port
| EXO_MAIL_SMTP_STARTTLS | NO | `false` | true to enable the secure (TLS) SMTP. See RFC 3207.
| EXO_MAIL_SMTP_USERNAME | NO | - | authentication username for smtp server (if needed)
| EXO_MAIL_SMTP_PASSWORD | NO | - | authentication password for smtp server (if needed)

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

## Cluster

The following environment variables should be passed to the container in order to configure the cluster configuration :

|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_CLUSTER | NO | `false` | Activate the cluster mode
| EXO_CLUSTER_NODE_NAME | NO | the container id | Node name to use in the cluster for this node (ex: node1)
| EXO_CLUSTER_HOSTS | NO | - | commas separated list of the nodes names or ips of the cluster (ex: node1,node2,172.16.250.11)
| EXO_JGROUPS_ADDR | NO | `GLOBAL` | IP address used to bind jgroups (ex: 172.16.250.11). By default the first routable address found will be used.

With the cluster mode active, the `EXO_JCR_STORAGE_DIR` and `EXO_FILE_STORAGE_DIR` properties must be set to a place shared between all the cluster nodes

## License

The eXo Platform license file location must be `/etc/exo/license.xml`

# Testing

The prerequisites are :
* internet access
* Docker daemon version 12+
* Docker Compose 1.7+
* 4GB of available RAM + 1GB of disk


We provide some docker-compose files for testing various configurations in the test folder

    # eXo Platform 4.4.x + hsqldb + mongodb 3.2
    docker-compose -f test/docker-compose-44-hsqldb.yml -p exo44hsqldb up

    # eXo Platform 4.4.x + MySQL 5.6 + mongodb 3.2
    docker-compose -f test/docker-compose-44-mysql.yml -p exo44mysql up

    # eXo Platform 4.4.x + Postgresql 9.4 + mongodb 3.2
    docker-compose -f test/docker-compose-44-pgsql.yml -p exo44pgsql up

When everything is started you can use :

* http://localhost for eXo Platform access
* http://localhost/mail to see all the mails sent by eXo platform

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
| ARCHIVE_BASE_DIR | NO | platform-${EXO_VERSION} | Platform directory in the archive used for the installation

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
