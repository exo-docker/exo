# Changelog <!-- omit in toc -->

Changelog for `exoplatform/exo:4.4.*_*` Docker image

- [4.4.4_1 [2018-05-22]](#444_1-2018-05-22)
- [4.4.4_0 [2018-01-12]](#444_0-2018-01-12)
- [4.4.3_2 [2017-12-19]](#443_2-2017-12-19)
- [4.4.3_1 [2017-11-20]](#443_1-2017-11-20)
- [4.4.3_0 [2017-09-07]](#443_0-2017-09-07)
- [4.4.2_4 [2017-08-25]](#442_4-2017-08-25)
- [4.4.2_3 [2017-07-31]](#442_3-2017-07-31)
- [4.4.2_2 [2017-06-16]](#442_2-2017-06-16)
- [4.4.2_1 [2017-06-15]](#442_1-2017-06-15)
- [4.4.2_0 [2017-06-15]](#442_0-2017-06-15)
- [4.4.1_2 [2017-06-12]](#441_2-2017-06-12)
- [4.4.1_1 [2017-06-08]](#441_1-2017-06-08)
- [4.4.1_0 [2017-04-18]](#441_0-2017-04-18)
- [4.4.0_2 [2017-04-19]](#440_2-2017-04-19)
- [4.4.0_1 [2017-03-14]](#440_1-2017-03-14)
- [4.4.0_0 [2017-02-15]](#440_0-2017-02-15)

## 4.4.4_1 [2018-05-22]

- **Features**
  - add ability to deploy patches

## 4.4.4_0 [2018-01-12]

- **Features**
  - upgrade to eXo Platform 4.4.4 GA (DOCKER-34)

## 4.4.3_2 [2017-12-19]

- **Features**
  - ability to activate tomcat access log (DOCKER-32)

## 4.4.3_1 [2017-11-20]

- **Bugfixes**
  - define version for exo-jdbc-driver-* add-ons (DOCKER-23)

## 4.4.3_0 [2017-09-07]

- **Features**
  - upgrade to eXo Platform 4.4.3 GA + eXo Chat 1.5.0 (DOCKER-15)

## 4.4.2_4 [2017-08-25]

- **Features**
  - add support of cluster mode (DOCKER-10)
  - support build with custom archives (DOCKER-7)

- **Bugfixes**
  - fix uninstall command when we specify a catalog url (DOCKER-8)

## 4.4.2_3 [2017-07-31]

- **Features**
  - ability to remove default add-ons embedded in the image (DOCKER-8)

## 4.4.2_2 [2017-06-16]

- **Features**
  - add Microsoft Core fonts (DOCKER-6)

## 4.4.2_1 [2017-06-15]

- **Bugfixes**
  - eXo startup must fail if the database driver installation fail.

## 4.4.2_0 [2017-06-15]

- **Features**
  - upgrade to eXo Platform 4.4.2 (DOCKER-5)
  - improve proxy port management (DOCKER-5)

- **Bugfixes**
  - container creation will fail if an add-on installation is failing (DOCKER-5)

- **Samples**
  - upgrade NGinx from 1.10 to 1.12 for eXo 4.4 in sample
  - nginx sample configurations refactoring

- **Documentation**
  - documentation refactoring

## 4.4.1_2 [2017-06-12]

- **Features**
  - allow to configure tomcat valves and listeners

## 4.4.1_1 [2017-06-08]

- **Features**
  - install JAI API + JAI Image I/O Tools + JAI ICC Profiles in the image JDK (without shared libraries) (DOCKER-2)
  - configure the connector proxyPort params even when ssl is off

## 4.4.1_0 [2017-04-18]

- **Features**
  - add some ldap connection pool configuration settings
  - upgrade eXo Platform 4.4.1

## 4.4.0_2 [2017-04-19]

- **Features**
  - add some ldap connection pool configuration settings

## 4.4.0_1 [2017-03-14]

- **Features**
  - add ability to configure the max size for file upload in eXo (EXO_UPLOAD_MAX_FILE_SIZE)

## 4.4.0_0 [2017-02-15]

- **Features**
  - upgrade eXo Platform 4.4.0
  - add embedded and external elasticsearch support
  - add some elasticsearch settings (shard and replication numbers)
  - automatically configure eXo base url parameter
  - add eXo mail settings management
  - add JOD Converter ports configuration
  - add File Storage configuration settings
  - MySQL hostname is now customizable
  - automatically install the required jdbc driver
  - add image compatibility with more databases : Postgresql, Oracle and hsqldb
  - add some proxy configuration
  - eXo container wait for database and mongodb availability before booting
  - ability to configure each datasources (IDM / JCR / JPA) size (init and max size)
  - add JMX configuration
  - remove AJP Connector from server.xml
  - add ability to configure tomcat http thread settings
- **Bugfixes**
  - don’t start te container if 1 add-on installation fail
  - fix chatPassPhrase generation
- **Samples**
  - add sample configuration for eXo 4.3
  - use MailHog to catch all mails sent by eXo Platform
- **Documentation**
  - document some eXo JVM parameters