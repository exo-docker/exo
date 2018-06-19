# Changelog <!-- omit in toc -->

Changelog for `exoplatform/exo:5.0.*_*` Docker image (older version : [4.4](./CHANGELOG-44.md))

- [5.0.1_2 [2018-06-19]](#501_2-2018-06-19)
- [5.0.1_1 [2018-06-14]](#501_1-2018-06-14)
- [5.0.1_0 [2018-06-14]](#501_0-2018-06-14)
- [5.0.0_6 [2018-06-07]](#500_6-2018-06-07)
- [5.0.0_5 [2018-06-01]](#500_5-2018-06-01)
- [5.0.0_4 [2018-05-22]](#500_4-2018-05-22)
- [5.0.0_3 [2018-04-25]](#500_3-2018-04-25)
- [5.0.0_2 [2018-04-24]](#500_2-2018-04-24)
- [5.0.0_1 [2018-04-16]](#500_1-2018-04-16)
- [5.0.0_0 [2018-04-05]](#500_0-2018-04-05)

## 5.0.1_2 [2018-06-19]

- **Features**
  - working directory is now `/var/log/exo`instead of `/tmp`

## 5.0.1_1 [2018-06-14]

- **Features**

  - don't start eXo container if timeout is reached for database / mongodb / elasticsearch (DOCKER-49)

- **Upgrades**
  - parent image : `exoplatform/jdk:8` => `exoplatform/jdk:8-ubuntu-1604` (DOCKER-45)

## 5.0.1_0 [2018-06-14]

- **Upgrades**
  - upgrade to eXo Platform 5.0.1 GA (DOCKER-50)

## 5.0.0_6 [2018-06-07]

- **Features**
  - ability to override umask in eXo container (DOCKER-47)
  - ability to override availability timeout delay for database / mongodb / elasticsearch (DOCKER-48)
  - use Tini to start eXo process

- **Upgrades**
  - parent image : `exoplatform/base-jdk:jdk8` => `exoplatform/jdk:8` (DOCKER-45)
    - upgrade JDK `8u151` => `8u171`
    - upgrade Ubuntu `14.04` => `16.04`
  - upgrade Libre Office 4.2 to 5.4 (ITOP-3747)
  - upgrade yaml tool from `1.10` => `1.15.0`

- **Bugfixes**
  - fix umask for file produced by eXo container (DOCKER-47)
  - starting the container fails if the service it depends on is not available before timeout (DOCKER-49)
    - database
    - elasticsearch (if not embedded mode)
    - mongo (if chat add-on installed)

## 5.0.0_5 [2018-06-01]

- **Features**
  - remove exo-es-embedded add-on is using an external ElasticSearch instance (DOCKER-43)

## 5.0.0_4 [2018-05-22]

- **Features**
  - add ability to deploy patches

- **Samples**
  - upgrade to nginx 1.14 for eXo 5.0 stack

## 5.0.0_3 [2018-04-25]

- **Features**
  - add a EXO_DB_MYSQL_USE_SSL variable to configure useSSL parameter of each datasource (DOCKER-41)

## 5.0.0_2 [2018-04-24]

- **Bugfixes**
  - fix datasource max connections configuration for tomcat 8.5 (DOCKER-40)

## 5.0.0_1 [2018-04-16]

- **Bugfixes**
  - fix add-on manager uninstall command (DOCKER-38)

## 5.0.0_0 [2018-04-05]

- **Features**
  - upgrade to eXo Platform 5.0.0 GA (DOCKER-37)
  - Support chat standalone deployment (DOCKER-18)
  - Pre-install mysql jdbc driver add-on with the good version for eXo Platform 5.0 (DOCKER-23)
  - upgrade postgresql jdbc driver add-on version to install (DOCKER-36)
  - upgrade oracle jdbc driver add-on version to install (DOCKER-36)

- **Bugfixes**
  - fix eXo Chat standalone configuration management

- **Samples**
  - add sample docker-compose files for eXo 5.0 stack

- **Documentation**
  - improve documentation for eXo Chat install
