#!/usr/bin/env bash

#build images
docker build -t hive-metastore:latest . -f hive-metastore/Dockerfile &&
  docker build -t spark-with-hadoop-hive:latest . -f spark-hadoop-standalone/Dockerfile || exit 1

#start services
docker-compose up -d &&
  docker exec -it spark bash -c "hdfs namenode -format && start-dfs.sh && hdfs dfs -mkdir -p /tmp && hdfs dfs -mkdir -p /user/hive/warehouse && hdfs dfs -chmod g+w /user/hive/warehouse" &&
  docker exec -d spark bash -c "hive --service metastore && sleep 10 && && hive --service hiveserver2 && sleep 10 && hive -e 'set mapreduce.framework.name=local;'" || exit 1