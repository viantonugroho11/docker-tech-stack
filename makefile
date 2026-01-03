up: 
	docker-compose up -d
down: 
	docker-compose down

init_docker_volumes:
	mkdir -p ./docker_volumes/postgre/data
	mkdir -p ./docker_volumes/kafka
	mkdir -p ./docker_volumes/zookeeper/data
	mkdir -p ./docker_volumes/zookeeper/log
	mkdir -p ./docker_volumes/redis/data
	mkdir -p ./docker_volumes/mongo/data
	mkdir -p ./docker_volumes/rabbitmq/data
	mkdir -p ./docker_volumes/rabbitmq/log