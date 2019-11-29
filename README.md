# eXo Platform Docker image <!-- omit in toc -->

![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo.svg) - ![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo.svg)

| Image                                                       | JDK | eXo Platform             |
| ----------------------------------------------------------- | --- | ------------------------ |
| exoplatform/exo:6.0_latest                                  | 8   | 6.0.x Enterprise edition |
| exoplatform/exo:5.3_latest                                  | 8   | 5.3.x Enterprise edition |
| exoplatform/exo:5.2_latest ([changelog](./CHANGELOG.md))    | 8   | 5.2.x Enterprise edition |
| exoplatform/exo:5.1_latest ([changelog](./CHANGELOG-51.md)) | 8   | 5.1.x Enterprise edition |
| exoplatform/exo:5.0_latest ([changelog](./CHANGELOG-50.md)) | 8   | 5.0.x Enterprise edition |
| exoplatform/exo:4.4_latest ([changelog](./CHANGELOG-44.md)) | 8   | 4.4.x Enterprise edition |
| exoplatform/exo:4.3_latest                                  | 8   | 4.3.x Enterprise edition |

The image is compatible with the following databases system :  `MySQL` (default) / `HSQLDB` / `PostgreSQL`

- [Configuration options](#configuration-options)
  - [Add-ons](#add-ons)
  - [Patches](#patches)
  - [JVM](#jvm)
  - [Frontend proxy](#frontend-proxy)
  - [Tomcat](#tomcat)
  - [Data on disk](#data-on-disk)
  - [Database](#database)
    - [MySQL](#mysql)
  - [eXo Chat](#exo-chat)
    - [embedded](#embedded)
    - [standalone](#standalone)
  - [ElasticSearch](#elasticsearch)
  - [LDAP / Active Directory](#ldap--active-directory)
  - [JOD Converter](#jod-converter)
  - [Mail](#mail)
  - [JMX](#jmx)
  - [Cluster](#cluster)
  - [Reward Wallet](#reward-wallet)
  - [License](#license)
  - [exo.properties](#exoproperties)
- [Testing](#testing)
- [Image build](#image-build)

## Configuration options

All the following options can be defined with standard Docker `-e` parameter

```bash
docker run -e MY_ENV_VARIABLE="value" ... exoplatform/exo
```

or Docker Compose way of defining environment variables

```yaml
version: '2'
services:
...
  exo:
    image: exoplatform/exo
    environment:
...
      EXO_ADDONS_LIST: exo-chat
      EXO_PATCHES_LIST:
      EXO_PATCHES_CATALOG_URL:
      EXO_ES_EMBEDDED: "false"
      EXO_ES_HOST: search
...
```

### Add-ons

Some add-ons are already installed in eXo image but you can install other one or remove some of the pre-installed one :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                   |
| ---------------------- | --------- | ------------- | --------------------------------------------------------------------------------------------- |
| EXO_ADDONS_LIST        | NO        | -             | commas separated list of add-ons to install (ex: exo-answers,exo-skype:1.0.x-SNAPSHOT)        |
| EXO_ADDONS_REMOVE_LIST | NO        | -             | commas separated list of add-ons to uninstall (ex: exo-chat,exo-es-embedded) (since: 4.4.2_3) |
| EXO_ADDONS_CATALOG_URL | NO        | -             | The url of a valid eXo Catalog                                                                |

### Patches

Patches can be deployed in eXo image :

| VARIABLE                | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                      |
| ----------------------- | --------- | ------------- | ------------------------------------------------------------------------------------------------ |
| EXO_PATCHES_LIST        | NO        | -             | commas separated list of patches to install (ex: patch-4.4.4:1,patch-4.4.4:2)                    |
| EXO_PATCHES_CATALOG_URL | YES       | -             | The url of a valid eXo Patches Catalog (mandatory if something is specified in EXO_PATCHES_LIST) |

### JVM

The standard eXo Platform environment variables can be used :

| VARIABLE                   | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                      |
| -------------------------- | --------- | ------------- | ------------------------------------------------------------------------------------------------ |
| EXO_JVM_SIZE_MIN           | NO        | `512m`        | specify the jvm minimum allocated memory size (-Xms parameter)                                   |
| EXO_JVM_SIZE_MAX           | NO        | `3g`          | specify the jvm maximum allocated memory size (-Xmx parameter)                                   |
| EXO_JVM_PERMSIZE_MAX       | NO        | `256m`        | (Java 7) specify the jvm maximum allocated memory to Permgen (-XX:MaxPermSize parameter)         |
| EXO_JVM_METASPACE_SIZE_MAX | NO        | `512m`        | (Java 8+) specify the jvm maximum allocated memory to MetaSpace (-XX:MaxMetaspaceSize parameter) |
| EXO_JVM_USER_LANGUAGE      | NO        | `en`          | specify the jvm locale for langage (-Duser.language parameter)                                   |
| EXO_JVM_USER_REGION        | NO        | `US`          | specify the jvm local for region (-Duser.region parameter)                                       |
| EXO_JVM_LOG_GC_ENABLED     | NO        | `false`       | activate the JVM GC log file generation (location: $EXO_LOG_DIR/platform-gc.log)               |

INFO: This list is not exhaustive (see eXo Platform documentation or {EXO_HOME}/bin/setenv.sh for more parameters)

### Frontend proxy

The following environment variables must be passed to the container to configure Tomcat proxy settings:

| VARIABLE        | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                |
| --------------- | --------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| EXO_PROXY_VHOST | NO        | `localhost`   | specify the virtual host name to reach eXo Platform                                                                                        |
| EXO_PROXY_PORT  | NO        | -             | which port to use on the proxy server ? (if empty it will automatically defined regarding EXO_PROXY_SSL value : true => 443 / false => 80) |
| EXO_PROXY_SSL   | NO        | `true`        | is ssl activated on the proxy server ? (true / false)                                                                                      |

### Tomcat

The following environment variables can be passed to the container to configure Tomcat settings

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                  |
| ---------------------- | --------- | ------------- | ---------------------------------------------------------------------------- |
| EXO_HTTP_THREAD_MAX    | NO        | `200`         | maximum number of threads in the tomcat http connector                       |
| EXO_HTTP_THREAD_MIN    | NO        | `10`          | minimum number of threads ready in the tomcat http connector                 |
| EXO_ACCESS_LOG_ENABLED | NO        | `false`       | activate Tomcat access log with combine format and a daily log file rotation |

#### Valves and Listeners <!-- omit in toc -->

A file containing the list of valves and listeners can be attached to the container in the path {{/etc/exo/host.yml}}. If a file is specified, the default valves and listeners configuration will be overridden.

The file format is :

```yaml
components:
  - type: Valve
    className: org.acme.myvalves.WithoutAttributes
  - type: Valve
    className: org.acme.myvalves.WithAttributes
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

### Data on disk

The following environment variables must be passed to the container in order to work :

| VARIABLE                   | MANDATORY | DEFAULT VALUE                | DESCRIPTION                                                                                  |
| -------------------------- | --------- | ---------------------------- | -------------------------------------------------------------------------------------------- |
| EXO_DATA_DIR               | NO        | `/srv/exo`                   | the directory to store eXo Platform data                                                     |
| EXO_JCR_STORAGE_DIR        | NO        | `${EXO_DATA_DIR}/jcr/values` | the directory to store eXo Platform JCR values data                                          |
| EXO_FILE_STORAGE_DIR       | NO        | `${EXO_DATA_DIR}/files`      | the directory to store eXo Platform data                                                     |
| EXO_FILE_STORAGE_RETENTION | NO        | `30`                         | the number of days to keep deleted files on disk before definitively remove it from the disk |
| EXO_UPLOAD_MAX_FILE_SIZE   | NO        | `200`                        | maximum authorized size for file upload in MB.                                               |
| EXO_FILE_UMASK             | NO        | `0022`                       | the umask used for files generated by eXo                                                    |

### Database

The following environment variables must be passed to the container in order to work :

| VARIABLE                  | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                           |
| ------------------------- | --------- | ------------- | ------------------------------------------------------------------------------------- |
| EXO_DB_TYPE               | NO        | `mysql`       | mysql / hsqldb / pgsql / ora                                                          |
| EXO_DB_HOST               | NO        | `mysql`       | the host to connect to the database server                                            |
| EXO_DB_PORT               | NO        | `3306`        | the port to connect to the database server                                            |
| EXO_DB_NAME               | NO        | `exo`         | the name of the database / schema to use                                              |
| EXO_DB_USER               | NO        | `exo`         | the username to connect to the database                                               |
| EXO_DB_PASSWORD           | YES       | -             | the password to connect to the database                                               |
| EXO_DB_POOL_IDM_INIT_SIZE | NO        | `5`           | the init size of IDM datasource pool                                                  |
| EXO_DB_POOL_IDM_MAX_SIZE  | NO        | `20`          | the max size of IDM datasource pool                                                   |
| EXO_DB_POOL_JCR_INIT_SIZE | NO        | `5`           | the init size of JCR datasource pool                                                  |
| EXO_DB_POOL_JCR_MAX_SIZE  | NO        | `20`          | the max size of JCR datasource pool                                                   |
| EXO_DB_POOL_JPA_INIT_SIZE | NO        | `5`           | the init size of JPA datasource pool                                                  |
| EXO_DB_POOL_JPA_MAX_SIZE  | NO        | `20`          | the max size of JPA datasource pool                                                   |
| EXO_DB_TIMEOUT            | NO        | `60`          | the number of seconds to wait for database availability before cancelling eXo startup |

#### MySQL

| VARIABLE             | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                       |
| -------------------- | --------- | ------------- | ------------------------------------------------------------------------------------------------- |
| EXO_DB_MYSQL_USE_SSL | NO        | `false`       | connecting securely to MySQL using SSL (see MySQL Connector/J documentation for useSSL parameter) |

### eXo Chat

eXo Chat is available in 2 flavors :

- embedded (default) : satisfy to most cases, the simplest to install and need only an external MongoDB instance.
- standalone : if you want to separate eXo and Chat JVM (for high throughput performance or architecture concerns).

A switch is available to enable the standalone mode :

| VARIABLE                   | MANDATORY | DEFAULT VALUE | DESCRIPTION                                           |
| -------------------------- | --------- | ------------- | ----------------------------------------------------- |
| EXO_CHAT_SERVER_STANDALONE | NO        | `false`       | are you using a standalone version of eXo Chat server |

#### embedded

With eXo Chat embedded mode, the client and server part of the chat feature are installed in eXo container.

- add-on to install : `exo-chat:<VERSION>`

The following environment variables should be passed to eXo container to configure eXo Chat :

| VARIABLE           | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                        |
| ------------------ | --------- | ------------- | -------------------------------------------------------------------------------------------------- |
| EXO_MONGO_HOST     | NO        | `mongo`       | the hostname to connect to the mongodb database for eXo Chat                                       |
| EXO_MONGO_PORT     | NO        | `27017`       | the port to connect to the mongodb server                                                          |
| EXO_MONGO_USERNAME | NO        | -             | the username to use to connect to the mongodb database (no authentication configured by default) |
| EXO_MONGO_PASSWORD | NO        | -             | the password to use to connect to the mongodb database (no authentication configured by default) |
| EXO_MONGO_DB_NAME  | NO        | `chat`        | the mongodb database name to use for eXo Chat                                                      |
| EXO_MONGO_TIMEOUT  | NO        | `60`          | the number of seconds to wait for mongodb availability before cancelling eXo startup               |

INFO: an external MongoDB server should be installed

#### standalone

With eXo Chat standalone mode, only the client part of the chat feature is installed in eXo container. The server part must be installed separately in another container ([doc](https://github.com/exo-docker/exo-chat-server)).

- add-on to install : `exo-chat-client:<VERSION>`
- eXo Chat standalone : see [exoplatform/chat-server](https://github.com/exo-docker/exo-chat-server) docker image documentation

The following environment variables should be passed to eXo container to configure eXo Chat client :

| VARIABLE                   | MANDATORY | DEFAULT VALUE           | DESCRIPTION                                                                                                            |
| -------------------------- | --------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| EXO_CHAT_SERVER_URL        | NO        | `http://localhost:8080` | the url of the eXo Chat server (only needed for eXo Chat standalone edition)                                           |
| EXO_CHAT_SERVER_PASSPHRASE | NO        | `something2change`      | the passphrase to secure the communication with eXo Chat standalone server (only used for eXo Chat standalone edition) |

### ElasticSearch

The following environment variables should be passed to the container in order to configure the search feature :

| VARIABLE                | MANDATORY | DEFAULT VALUE  | DESCRIPTION                                                                                                                                                                                                                                                                    |
| ----------------------- | --------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| EXO_ES_EMBEDDED         | NO        | `true`         | do we use an elasticsearch server embedded in the eXo Platform JVM or do we use an external one ? (using an embedded elasticsearch server is not recommended for production purpose) (if set to `false` the add-on `exo-es-embedded` is uninstalled during container creation) |
| EXO_ES_EMBEDDED_DATA    | NO        | `/srv/exo/es/` | The directory to use for storing elasticsearch data (in embedded mode only).                                                                                                                                                                                                   |
| EXO_ES_SCHEME           | NO        | `http`         | the elasticsearch server scheme to use from the eXo Platform server jvm perspective (http / https).                                                                                                                                                                            |
| EXO_ES_HOST             | NO        | `localhost`    | the elasticsearch server hostname to use from the eXo Platform server jvm perspective.                                                                                                                                                                                         |
| EXO_ES_PORT             | NO        | `9200`         | the elasticsearch server port to use from the eXo Platform server jvm perspective.                                                                                                                                                                                             |
| EXO_ES_USERNAME         | NO        | -              | the username to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| EXO_ES_PASSWORD         | NO        | -              | the password to connect to the elasticsearch server (if authentication is activated on the external elasticsearch).                                                                                                                                                            |
| EXO_ES_INDEX_REPLICA_NB | NO        | `0`            | the number of replicat for elasticsearch indexes (leave 0 if you don't have an elasticsearch cluster).                                                                                                                                                                         |
| EXO_ES_INDEX_SHARD_NB   | NO        | `0`            | the number of shard for elasticsearch indexes.                                                                                                                                                                                                                                 |
| EXO_ES_TIMEOUT          | NO        | `60`           | the number of seconds to wait for elasticsearch availability before cancelling eXo startup (only if EXO_ES_EMBEDDED=false)                                                                                                                                                     |

INFO: the default embedded ElasticSearch in not recommended for production purpose.

### LDAP / Active Directory

The following environment variables should be passed to the container in order to configure the ldap connection pool :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                                  |
| ---------------------- | --------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| EXO_LDAP_POOL_DEBUG    | NO        | -             | the level of debug output to produce. Valid values are "fine" (trace connection creation and removal) and "all" (all debugging information). |
| EXO_LDAP_POOL_TIMEOUT  | NO        | `60000`       | the number of milliseconds that an idle connection may remain in the pool without being closed and removed from the pool.                    |
| EXO_LDAP_POOL_MAX_SIZE | NO        | `100`         | the maximum number of connections per connection identity that can be maintained concurrently.                                               |

### JOD Converter

The following environment variables should be passed to the container in order to configure jodconverter :

| VARIABLE               | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                               |
| ---------------------- | --------- | ------------- | ----------------------------------------------------------------------------------------- |
| EXO_JODCONVERTER_PORTS | NO        | `2002`        | comma separated list of ports to allocate to JOD Converter processes (ex: 2002,2003,2004) |

### Mail

The following environment variables should be passed to the container in order to configure the mail server configuration to use :

| VARIABLE               | MANDATORY | DEFAULT VALUE             | DESCRIPTION                                         |
| ---------------------- | --------- | ------------------------- | --------------------------------------------------- |
| EXO_MAIL_FROM          | NO        | `noreply@exoplatform.com` | "from" field of emails sent by eXo platform         |
| EXO_MAIL_SMTP_HOST     | NO        | `localhost`               | SMTP Server hostname                                |
| EXO_MAIL_SMTP_PORT     | NO        | `25`                      | SMTP Server port                                    |
| EXO_MAIL_SMTP_STARTTLS | NO        | `false`                   | true to enable the secure (TLS) SMTP. See RFC 3207. |
| EXO_MAIL_SMTP_USERNAME | NO        | -                         | authentication username for smtp server (if needed) |
| EXO_MAIL_SMTP_PASSWORD | NO        | -                         | authentication password for smtp server (if needed) |

### JMX

The following environment variables should be passed to the container in order to configure JMX :

| VARIABLE                    | MANDATORY | DEFAULT VALUE | DESCRIPTION                                                                                                                               |
| --------------------------- | --------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| EXO_JMX_ENABLED             | NO        | `true`        | activate JMX listener                                                                                                                     |
| EXO_JMX_RMI_REGISTRY_PORT   | NO        | `10001`       | JMX RMI Registry port                                                                                                                     |
| EXO_JMX_RMI_SERVER_PORT     | NO        | `10002`       | JMX RMI Server port                                                                                                                       |
| EXO_JMX_RMI_SERVER_HOSTNAME | NO        | `localhost`   | JMX RMI Server hostname                                                                                                                   |
| EXO_JMX_USERNAME            | NO        | -             | a username for JMX connection (if no username is provided, the JMX access is unprotected)                                                 |
| EXO_JMX_PASSWORD            | NO        | -             | a password for JMX connection (if no password is specified a random one will be generated and stored in /opt/exo/conf/jmxremote.password) |

With the default parameters you can connect to JMX with `service:jmx:rmi://localhost:10002/jndi/rmi://localhost:10001/jmxrmi` without authentication.

### Cluster

The following environment variables should be passed to the container in order to configure the cluster :

| VARIABLE              | MANDATORY | DEFAULT VALUE    | DESCRIPTION                                                                                                    |
| --------------------- | --------- | ---------------- | -------------------------------------------------------------------------------------------------------------- |
| EXO_CLUSTER           | NO        | `false`          | Activate the cluster mode                                                                                      |
| EXO_CLUSTER_NODE_NAME | NO        | the container id | Node name to use in the cluster for this node (ex: node1)                                                      |
| EXO_CLUSTER_HOSTS     | NO        | -                | commas separated list of the nodes names or ips of the cluster (ex: node1,node2,172.16.250.11)                 |
| EXO_JGROUPS_ADDR      | NO        | `GLOBAL`         | IP address used to bind jgroups (ex: 172.16.250.11). By default the first routable address found will be used. |

With the cluster mode active, the `EXO_JCR_STORAGE_DIR` and `EXO_FILE_STORAGE_DIR` properties must be set to a place shared between all the cluster nodes

### Reward Wallet

The following environment variables should be passed to the container in order to configure eXo Rewards wallet:

| VARIABLE                                      | MANDATORY | DEFAULT VALUE                                                    | DESCRIPTION                                                                                                                                                                                                                       |
|-----------------------------------------------|-----------|------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| EXO_REWARDS_WALLET_ADMIN_KEY                  | YES       | `changeThisKey`                                                  | password used to encrypt the Admin wallet’s private key stored in database. If its value is modified after server startup, the private key of admin wallet won’t be decrypted anymore, preventing all administrative operations |
| EXO_REWARDS_WALLET_ACCESS_PERMISSION          | NO        | `/platform/users`                                                | to restrict access to wallet application to a group of users (ex: member:/spaces/internal_space)                                                                                                                                  |
| EXO_REWARDS_WALLET_NETWORK_ID                 | NO        | `1` (mainnet)                                                    | ID of the Ethereum network to use (see: <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md#list-of-chain-ids>)                                                                                                         |
| EXO_REWARDS_WALLET_NETWORK_ENDPOINT_HTTP      | NO        | `https://mainnet.infura.io/v3/a1ac85aea9ce4be88e9e87dad7c01d40`  | https url to access to the Ethereum API for the chosen network id                                                                                                                                                                 |
| EXO_REWARDS_WALLET_NETWORK_ENDPOINT_WEBSOCKET | NO        | `wss://mainnet.infura.io/ws/v3/a1ac85aea9ce4be88e9e87dad7c01d40` | wss url to access to the Ethereum API for the chosen network id                                                                                                                                                                   |
| EXO_REWARDS_WALLET_TOKEN_ADDRESS              | NO        | `0xc76987d43b77c45d51653b6eb110b9174acce8fb`                     | address of the contract for the official rewarding token promoted by eXo                                                                                                                                                          |                                                                                                  |

### License

The eXo Platform license file location must be `/etc/exo/license.xml`

### exo.properties

*(available since `exoplatform/exo:5.1.0` version only)*

As specified in [eXo documentation](https://docs.exoplatform.org/PLF50/PLFAdminGuide.Configuration.Properties_reference.html), an external `exo.properties` file can be used to fine tune some aspect of eXo Platform. In that case you have to create an `exo.properties` file on the host filesystem and bind mount it in the docker image :

- Docker way

```bash
docker run ... -v /absolute/path/to/exo.properties:/etc/exo/exo.properties:ro ... exoplatform/exo
```

- docker-compose.yml way

```yaml
version: '2'
services:
...
  exo:
    image: exoplatform/exo
...
    volumes:
      - /absolute/path/to/exo.properties:/etc/exo/exo.properties:ro
...
```

## Testing

The prerequisites are :

- internet access
- Docker daemon version 12+
- Docker Compose 1.7+
- 4GB of available RAM + 1GB of disk

We provide some docker-compose files for testing various configurations in the test folder

```bash
# eXo Platform 4.4.x + hsqldb + mongodb 3.2
docker-compose -f test/docker-compose-44-hsqldb.yml -p exo44hsqldb up

# eXo Platform 4.4.x + MySQL 5.6 + mongodb 3.2
docker-compose -f test/docker-compose-44-mysql.yml -p exo44mysql up

# eXo Platform 4.4.x + PostgreSQL 9.4 + mongodb 3.2
docker-compose -f test/docker-compose-44-pgsql.yml -p exo44pgsql up
```

When everything is started you can use :

- <http://localhost> for eXo Platform access
- <http://localhost/mail> to see all the mails sent by eXo platform

## Image build

The simplest way to build this image is to use default values :

    docker build -t exoplatform/exo .

This will produce an image with the current eXo Platform enterprise version and 3 bundled add-ons : eXo Chat, eXo Tasks, eXo Remote Edit.

| ARGUMENT NAME    | MANDATORY | DEFAULT VALUE                        | DESCRIPTION                                                   |
| ---------------- | --------- | ------------------------------------ | ------------------------------------------------------------- |
| ADDONS           | NO        | `exo-chat exo-tasks exo-remote-edit` | a space separated list of add-ons to install                  |
| EXO_VERSION      | NO        | latest stable version                | the full version number of the eXo Platform to package        |
| DOWNLOAD_URL     | NO        | public download url                  | the full url where the eXo Platform binary must be downloaded |
| DOWNLOAD_USER    | NO        | -                                    | a username to use for downloading the eXo Platform binary     |
| ARCHIVE_BASE_DIR | NO        | platform-${EXO_VERSION}              | Platform directory in the archive used for the installation   |

If you want to bundle a particular list of add-ons :

```bash
docker build \
  --build-arg ADDONS="exo-chat exo-staging-extension:2.6.0" \
  -t exoplatform/exo:my_version .
```

If you want to build a particular version of eXo Platform just pass the good arguments :

```bash
docker build \
  --build-arg EXO_VERSION=4.3.1 \
  -t exoplatform/exo:4.3.1 .
```

If you want to specify an alternate public download url :

```bash
docker build \
  --build-arg DOWNLOAD_URL=http://my.host/my-own-download-link.zip \
  -t exoplatform/exo:my_version .
```

If you want to specify an alternate authenticated download url :

```bash
docker build \
  --build-arg DOWNLOAD_URL=http://my.host/my-own-download-link.zip \
  --build-arg DOWNLOAD_USER=my-username
  -t exoplatform/exo:my_version .
```

The password will be required during the build at the download step.
