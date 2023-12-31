#!/bin/bash

echo "clean up docker"
#echo "docker system prune -f ; docker network prune -f ; docker volume prune -f ; docker rm -f -v $(docker ps -q -a)"
docker system prune -f ; docker network prune -f ; docker volume prune -f ; docker rm -f -v $(docker ps -q -a)

echo "create keys"
./create-keys.sh

echo "docker up"
docker-compose up -d

sleep 30

#
echo "$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server=localhost:29092 --command-config ssl.properties --create --if-not-exists --topic test-topic --partitions 1 --replication-factor 1"
$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server=localhost:29092 --command-config ssl.properties --create --if-not-exists --topic test-topic --partitions 1 --replication-factor 1

#
#echo "$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server=localhost:29092 --command-config ssl.properties --describe"
#$KAFKA_HOME/bin/kafka-topics.sh --bootstrap-server=localhost:29092 --command-config ssl.properties --describe
