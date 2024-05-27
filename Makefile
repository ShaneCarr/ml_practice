# In a Makefile, .PHONY is a special built-in target that tells make that the targets listed after it are not actual files. Instead, they are just labels for commands to be run. This is useful for targets that do not represent files or directories and should always be executed when requested, regardless of whether there are files with the same names as the targets.
.PHONY: all build build-base up down clean rmi ps logs export setup init info images networks inspect logsf

# Use bash shell
SHELL := /bin/bash

# Set the project directory to the current directory
PROJECT_DIR := $(shell pwd)

# Default target
all: build

# Configuration option to include/exclude Java service
# This variable can be set externally. If not set, it defaults to false.
INCLUDE_JAVA ?= false
# Specify a pattern to identify the Jupyter container (by name or image)
CONTAINER_IMAGE=ml_practice-jupyter

# Determine platform-specific Dockerfile
# uname -s returns the operating system name
ifeq ($(shell uname -s),Linux)
    DOCKERFILE_BASE = Dockerfile.base.linux
    DOCKERFILE_JUPYTER = Dockerfile.jupyter
    DOCKER_COMPOSE_FILE = docker-compose.linux.yml
else ifeq ($(shell uname -s),Darwin)
    DOCKERFILE_BASE = Dockerfile.base.mac
    DOCKERFILE_JUPYTER = Dockerfile.jupyter.mac
    DOCKER_COMPOSE_FILE = docker-compose.mac.yml
endif

# Build Docker images
# The build target depends on the build-base target
build: build-base
	@echo "Building Docker images..."
	# Build all images defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) build
ifneq ($(INCLUDE_JAVA),false)
	@echo "Building Java service image..."
	# Build the Java service image if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml build
endif

# Build the base image
build-base:
	@echo "Building the base Docker image..."
	# Build the base image using the base Dockerfile
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) docker-compose -f docker-compose.yml build base

# Start Docker containers
up:
	@echo "Starting Docker containers..."
	# Start all containers defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) up -d
ifneq ($(INCLUDE_JAVA),false)
	@echo "Starting Java service container..."
	# Start the Java service container if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml up -d
endif

# Target to find the running container ID
find-container:
	@echo "Finding container running image '$(CONTAINER_IMAGE)'..."
	@docker ps --filter "ancestor=$(CONTAINER_IMAGE)" --filter "status=running" --format "{{.ID}}" | head -n 1 > .container_id
	@if [ -s .container_id ]; then \
		echo "Container ID: $$(cat .container_id)"; \
	else \
		echo "No running container found for image '$(CONTAINER_IMAGE)'."; \
	fi

# Target to retrieve the Jupyter token
get-token: find-container
	@CONTAINER_ID=$$(cat .container_id); \
	if [ -z "$$CONTAINER_ID" ]; then \
		echo "No running container found for image '$(CONTAINER_IMAGE)'."; \
	else \
		echo "Retrieving Jupyter token from container $$CONTAINER_ID..."; \
		docker exec -it $$CONTAINER_ID jupyter server list 2>/dev/null | awk -F'token=' '{print $$2}' | awk '{print $$1}' | head -n 1 | xargs -I{} echo "Jupyter token: {}"; \
	fi


# Stop Docker containers
down:
	@echo "Stopping Docker containers..."
	# Stop all containers defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) down
ifneq ($(INCLUDE_JAVA),false)
	@echo "Stopping Java service container..."
	# Stop the Java service container if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml down
endif

# Clean Docker environment (removes containers and images)
clean:
	@echo "Cleaning Docker environment..."
	# Stop and remove all containers, networks, and images defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) down -v --rmi all
ifneq ($(INCLUDE_JAVA),false)
	@echo "Cleaning Java service environment..."
	# Stop and remove the Java service container, network, and image if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml down -v --rmi all
endif
	# Remove Python cache files
	rm -rf $(PROJECT_DIR)/__pycache__
	rm -rf $(PROJECT_DIR)/*.pyc
	rm -rf $(PROJECT_DIR)/*~

# Remove all Docker images
rmi:
	@echo "Removing Docker images..."
	# Force remove all Docker images
	docker rmi -f $(shell docker images -q)

# Show Docker containers
ps:
	@echo "Showing Docker containers..."
	# List all running containers defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) ps
ifneq ($(INCLUDE_JAVA),false)
	@echo "Showing Java service containers..."
	# List the Java service container if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml ps
endif

# Logs from Docker containers
logs:
	@echo "Showing logs from Docker containers..."
	# Show logs from all containers defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) logs -f
ifneq ($(INCLUDE_JAVA),false)
	@echo "Showing logs from Java service containers..."
	# Show logs from the Java service container if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml logs -f
endif

# Export environment variables from .env file
export:
	@echo "Exporting environment variables..."
	# Export all environment variables defined in the .env file
	export $(cat .env | xargs)

# Ensure all necessary directories are created
setup:
	@echo "Setting up project directory..."
	# Create the project directory if it doesn't exist
	mkdir -p ~/shane/repo/machine_learning
	cd ~/shane/repo/machine_learning

# Initialize the environment
init: setup
	@echo "Initializing the environment..."
	# Run the setup script to initialize the environment
	./setup_ml_docker_cuda.sh

# Additional targets for diagnostics

# Show Docker system info
info:
	@echo "Showing Docker system info..."
	docker info

# List Docker images
images:
	@echo "Listing Docker images..."
	docker images

# List Docker networks
networks:
	@echo "Listing Docker networks..."
	docker network ls

# Inspect Docker containers
inspect:
	@echo "Inspecting Docker containers..."
	docker inspect $(shell docker ps -q)

# Show logs from Docker containers with tail
logsf:
	@echo "Showing logs from Docker containers with tail..."
	# Show the last 100 lines of logs from all containers defined in the compose files
	DOCKERFILE_BASE=$(DOCKERFILE_BASE) DOCKERFILE_JUPYTER=$(DOCKERFILE_JUPYTER) docker-compose -f docker-compose.yml -f $(DOCKER_COMPOSE_FILE) logs -f --tail=100
ifneq ($(INCLUDE_JAVA),false)
	@echo "Showing logs from Java service containers with tail..."
	# Show the last 100 lines of logs from the Java service container if INCLUDE_JAVA is set to true
	docker-compose -f docker-compose.java.yml logs -f --tail=100
endif
