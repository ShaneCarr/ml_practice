# Makefile

# Variables
SHELL := /bin/bash
PROJECT_DIR := $(shell pwd)

# Default target
all: build

# Build Docker images
build:
	@echo "Building Docker images..."
	docker-compose build base
	docker-compose build

# Start Docker containers
up:
	@echo "Starting Docker containers..."
	docker-compose up -d

# Stop Docker containers
down:
	@echo "Stopping Docker containers..."
	docker-compose down

# Clean Docker environment (removes containers and images)
clean:
	@echo "Cleaning Docker environment..."
	docker-compose down -v --rmi all
	rm -rf $(PROJECT_DIR)/__pycache__
	rm -rf $(PROJECT_DIR)/*.pyc
	rm -rf $(PROJECT_DIR)/*~

# Remove Docker images
rmi:
	@echo "Removing Docker images..."
	docker rmi -f $(shell docker images -q)

# Show Docker containers
ps:
	@echo "Showing Docker containers..."
	docker-compose ps

# Logs from Docker containers
logs:
	@echo "Showing logs from Docker containers..."
	docker-compose logs -f

# Export environment variables from .env file
export:
	@echo "Exporting environment variables..."
	export $(cat .env | xargs)

# Ensure all necessary directories are created
setup:
	@echo "Setting up project directory..."
	mkdir -p ~/shane/repo/machine_learning
	cd ~/shane/repo/machine_learning

# Initialize the environment
init: setup
	@echo "Initializing the environment..."
	./setup_ml_docker_cuda.sh

# Display Docker system information
info:
	@echo "Displaying Docker system information..."
	docker info

# List Docker images
images:
	@echo "Listing Docker images..."
	docker images

# List Docker networks
networks:
	@echo "Listing Docker networks..."
	docker network ls

# Inspect a specific Docker container (usage: make inspect container=<container_name>)
inspect:
	@echo "Inspecting Docker container..."
	docker inspect $(container)

# Follow logs for a specific container (usage: make logsf container=<container_name>)
logsf:
	@echo "Following logs for Docker container..."
	docker logs -f $(container)

.PHONY: all build up down clean rmi ps logs export setup init info images networks inspect logsf
