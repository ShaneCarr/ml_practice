def format_code_block(code: str, language: str = "sh") -> str:
    return f"```{language}\n{code}\n```"

# Example usage
code_block_1 = format_code_block("git clone <your-repo-url>\ncd machine_learning", "sh")
code_block_2 = format_code_block("make build", "sh")
code_block_3 = format_code_block("make up", "sh")

readme_content = f"""
# Machine Learning Development Environment

This project sets up a Dockerized environment for machine learning development with Jupyter Notebook and a Java service. It uses NVIDIA CUDA for GPU acceleration and provides a clean, portable setup for your development needs.

## Prerequisites

- Docker
- Docker Compose
- NVIDIA Docker (for GPU support)
- Make

## Setup Instructions

### Step 1: Clone the Repository

Clone the repository and navigate to the project directory.

{code_block_1}

### Step 2: Build Docker Images

To build the Docker images, run:

{code_block_2}

### Step 3: Start Docker Containers

To start the Docker containers, run:

{code_block_3}

### Step 4: Access Jupyter Notebook

Open your web browser and go to http://localhost:8888. You should see the Jupyter Notebook interface.

## Makefile Targets

The Makefile provides several useful targets for managing and diagnosing the application:

### Build Docker images

{format_code_block("make build", "sh")}

### Start Docker containers

{format_code_block("make up", "sh")}

### Stop Docker containers

{format_code_block("make down", "sh")}

### Clean Docker environment (removes containers and images)

{format_code_block("make clean", "sh")}

### Remove Docker images

{format_code_block("make rmi", "sh")}

### Show Docker containers

{format_code_block("make ps", "sh")}

### Logs from Docker containers

{format_code_block("make logs", "sh")}

### Export environment variables from .env file

{format_code_block("make export", "sh")}

### Ensure all necessary directories are created

{format_code_block("make setup", "sh")}

### Initialize the environment

{format_code_block("make init", "sh")}
"""

print(readme_content)
