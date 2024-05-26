cat <<EOL > setup_ml_docker_cuda.sh
#!/bin/bash

# Create project directory if it doesn't exist
mkdir -p ~/shane/repo/machine_learning
cd ~/shane/repo/machine_learning

# Create .env file
cat <<EOF > .env
# .env
# Environment variables for Docker Compose

# Path to the local project directory
LOCAL_PROJECT_DIR=~/shane/repo/machine_learning

# CUDA and cuDNN versions
CUDA_VERSION=11.2.2
CUDNN_VERSION=8
EOF

# Create Dockerfile.base
cat <<EOF > Dockerfile.base
# Dockerfile.base

# Define build arguments for CUDA and cuDNN versions
ARG CUDA_VERSION
ARG CUDNN_VERSION

# Use an official NVIDIA CUDA runtime as a parent image
FROM nvidia/cuda:\${CUDA_VERSION}-cudnn\${CUDNN_VERSION}-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /workspace

# Install common dependencies
RUN apt-get update && apt-get install -y \\
    python3-pip \\
    python3-dev \\
    openjdk-21-jdk \\
    git \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Install Python packages common to all services
COPY requirements-common.txt .
RUN pip3 install --no-cache-dir -r requirements-common.txt

# Make ports 8888 and 8080 available to the world outside this container
EXPOSE 8888 8080

# Define environment variable
ENV NAME BaseDockerImage
EOF

# Create Dockerfile.jupyter
cat <<EOF > Dockerfile.jupyter
# Dockerfile.jupyter

# Use the base Dockerfile as the parent image
FROM base

# Copy Jupyter-specific requirements file and install packages
COPY requirements-jupyter.txt .
RUN pip3 install --no-cache-dir -r requirements-jupyter.txt

# Set the default command to run Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
EOF

# Create Dockerfile.java
cat <<EOF > Dockerfile.java
# Dockerfile.java

# Use the base Dockerfile as the parent image
FROM base

# Copy the Java application code into the container
COPY . /workspace/java

# Compile the Java application
RUN javac Main.java

# Set the default command to run the Java application
CMD ["java", "Main"]
EOF

# Create requirements-common.txt
cat <<EOF > requirements-common.txt
# requirements-common.txt
# Common dependencies for all services

numpy
pandas
scikit-learn
matplotlib
seaborn
scipy
sympy
EOF

# Create requirements-jupyter.txt
cat <<EOF > requirements-jupyter.txt
# requirements-jupyter.txt
# Dependencies specific to the Jupyter service

jupyter
tensorflow-gpu
torch
torchvision
torchaudio
transformers
tqdm
xgboost
lightgbm
catboost
plotly
notebook
jupyterlab
jupyter-contrib-nbextensions
nbformat
nbconvert
EOF

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
# docker-compose.yml

version: '3.8'

services:
  jupyter:
    build:
      context: .
      dockerfile: Dockerfile.jupyter
      args:
        CUDA_VERSION: \${CUDA_VERSION}
        CUDNN_VERSION: \${CUDNN_VERSION}
    ports:
      - "8888:8888"
    volumes:
      - \${LOCAL_PROJECT_DIR}:/workspace
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    runtime: nvidia
    env_file:
      - .env

  java_service:
    build:
      context: .
      dockerfile: Dockerfile.java
    ports:
      - "8080:8080"
    volumes:
      - \${LOCAL_PROJECT_DIR}/java:/workspace/java
    env_file:
      - .env
EOF

# Export the environment variable
echo 'export LOCAL_PROJECT_DIR=~/shane/repo/machine_learning' >> ~/.bashrc
source ~/.bashrc

# Build and run Docker containers
docker-compose build
docker-compose up
EOL

