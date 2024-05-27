# Machine Learning Development Environment

This project sets up a Dockerized environment for machine learning development with Jupyter Notebook and a Java service. It uses NVIDIA CUDA for GPU acceleration and provides a clean, portable setup for your development needs.

In reality i got tired for setting up python, and jupyter on several differnet os's windows, mac linux
and all the computers. I can clone this and go.

The other project is java, and ubuntu mode includes cuda.  in most cases for me since i have nvidia cards i want cuda for models/infrence. Just follow mac-style if you want jupyter only. 

This  started because I  use linux a lot; I don't like polluting my machine with dependnecies like cuda and various python libraries and whatever else gets pulled in so I use docker.

## Prerequisites

- Docker
- Docker Compose
- NVIDIA Docker (for GPU support)
- Make

## Setup Instructions

### Step 1: Clone the Repository

Clone the repository and navigate to the project directory.

```sh
git clone <your-repo-url>
cd machine_learning
```

### Step 2: Build Docker Images

To build the Docker images, run:

```sh
make build
```

### Step 3: Start Docker Containers

To start the Docker containers, run:

```sh
make up
```

### Step 4: Access Jupyter Notebook

Open your web browser and go to http://localhost:8888. You should see the Jupyter Notebook interface.

## Makefile Targets

The Makefile provides several useful targets for managing and diagnosing the application:

### Build Docker images

```sh
make build
```

### Start Docker containers

```sh
make up
```

### Stop Docker containers

```sh
make down
```

### Clean Docker environment (removes containers and images)

```sh
make clean
```

### Remove Docker images

```sh
make rmi
```

### Show Docker containers

```sh
make ps
```

### Logs from Docker containers

```sh
make logs
```

### Export environment variables from .env file

```sh
make export
```

### Ensure all necessary directories are created

```sh
make setup
```

### Initialize the environment

```sh
make init
```

Folders:
machine_learning/
├── docker-compose.yml
├── docker-compose.linux.yml
├── docker-compose.mac.yml
├── Dockerfile.base
├── Dockerfile.jupyter
├── Dockerfile.jupyter.mac
├── Makefile
├── requirements-common.txt
├── requirements-jupyter.txt
├── requirements-jupyter-mac.txt
├── java/
└── jupyter/
