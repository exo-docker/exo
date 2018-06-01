# Changelog <!-- omit in toc -->

Changelog for `exoplatform/exo:5.0.*_*` Docker image (older version : [4.4](./CHANGELOG-44.md))

- [5.0.0_5 [2018-06-01]](#500_5-2018-06-01)
- [5.0.0_4 [2018-05-22]](#500_4-2018-05-22)
- [5.0.0_3 [2018-04-25]](#500_3-2018-04-25)
- [5.0.0_2 [2018-04-24]](#500_2-2018-04-24)
- [5.0.0_1 [2018-04-16]](#500_1-2018-04-16)
- [5.0.0_0 [2018-04-05]](#500_0-2018-04-05)

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
