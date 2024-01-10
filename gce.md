# How to run ?

## Getting started

Weclome to eXo Startup tutorial. Here we will show you how to run eXo in few steps. To get started, click on Start!

## VM Setup
Elasticsearch uses a mmapfs directory by default to store its indices. The default operating system limits on mmap counts is likely to be too low, which may result in out of memory exceptions. See [doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).
```bash
sudo sysctl -w vm.max_map_count=262144
```
## Start eXo
```bash
docker-compose -p demo up -d
docker-compose -p demo logs -f exo
```

Wait for eXo startup. A log message should appear:
```
| INFO  | Server startup in [XXXXX] milliseconds [org.apache.catalina.startup.Catalina<main>]
```
After eXo startup. Click on `Web preview` <walkthrough-web-preview-icon></walkthrough-web-preview-icon> Button and click on `Preview on Port 8080`. Enjoy!

## Stop eXo
Hope you enjoyed eXo Platform. You can tear down the server by following one of these options:
 - To stop eXo without removing docker containers:
    ```bash
    docker-compose -p demo stop
    ```
 - To stop eXo with removing docker containers:
    ```bash
    docker-compose -p demo down
    ```
 - To stop eXo with removing docker containers and volumes:
    ```bash
    docker-compose -p demo down -v
    ```
You can start again eXo by following the previous step.

You can checkout our Github [organisation](https://github.com/exoplatform) and our [community](https://community.exoplatform.com).

That's all :)