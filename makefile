AWS_ACCOUNT_ID := 677459762413
AWS_REGION := us-west-2
MIGRATION_DIR := migrations
AWS_ECR_DOMAIN := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
GIT_SHA := $(shell git rev-parse HEAD)
BUILD_IMAGE := $(AWS_ECR_DOMAIN)/fem-fd-service
.DEFAULT_GOAL := build

build:
	go build -o ./goalzi main.go

build-image:
	docker buildx build \
		--platform "linux/amd64" \
		--tag "$(BUILD_IMAGE):$(GIT_SHA)-build" \
		--target "build" \
		.
	docker buildx build \
		--cache-from "$(BUILD_IMAGE):$(GIT_SHA)-build" \
		--platform "linux/amd64" \
		--tag "$(BUILD_IMAGE):$(GIT_SHA)" \
		.

build-image-login:
	aws ecr get-login-password --region us-west-2 | docker login \
		--username AWS \
		--password-stdin \
		$(AWS_ECR_DOMAIN)

build-image-push: build-image-login 
	docker image push $(BUILD_IMAGE):$(GIT_SHA)-build
	docker image push $(BUILD_IMAGE):$(GIT_SHA)

build-image-pull: build-image-login 
	docker image pull $(BUILD_IMAGE):$(GIT_SHA)-build
	docker image pull $(BUILD_IMAGE):$(GIT_SHA)

build-image-migrate:
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA)-build \
		-dir $(MIGRATION_DIR) status
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA)-build \
		-dir $(MIGRATION_DIR) validate
	docker container run \
		--entrypoint "goose" \
		--env "GOOSE_DBSTRING" \
		--env "GOOSE_DRIVER" \
		--network "host" \
		--rm \
		$(BUILD_IMAGE):$(GIT_SHA)-build \
		-dir $(MIGRATION_DIR) up

build-image-promote:
	docker image tag $(BUILD_IMAGE):$(GIT_SHA) $(BUILD_IMAGE):latest
	docker image push $(BUILD_IMAGE):latest

down:
	docker compose down --remove-orphans --volumes

up: down
	docker compose up --detach

migrate:
	goose -dir "$(MIGRATION_DIR)" up

migrate-status:
	goose -dir "$(MIGRATION_DIR)" status

migrate-validate:
	goose -dir "$(MIGRATION_DIR)" validate

start: build
	./goalzi
