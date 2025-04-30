build:
	go build -o ./goalzi main.go

build-image:
	docker buildx build \
		--platform "linux/amd64" \
		--tag "fem-fd-service:latest" \
		.

build-image-push: build-image
	docker image tag \
		fem-fd-service:latest \
		677459762413.dkr.ecr.us-west-2.amazonaws.com/fem-fd-service:latest
	aws ecr get-login-password --region us-west-2 | docker login \
		--username AWS \
		--password-stdin \
		677459762413.dkr.ecr.us-west-2.amazonaws.com
	docker image push \
		677459762413.dkr.ecr.us-west-2.amazonaws.com/fem-fd-service:latest

down:
	docker compose down --remove-orphans --volumes

up: down
	docker compose up --detach

migrate:
	docker container run \
		--entrypoint "psql" \
		--env "PGPASSWORD=password" \
		--network "host" \
		--rm \
		--volume "./migration:/data" \
		postgres:alpine \
		--dbname "postgres" \
		--file "/data/base-schema.sql" \
		--host "127.0.0.1" \
		--username "postgres"

start: build
	./goalzi
