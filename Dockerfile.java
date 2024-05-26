# Dockerfile.java

# Use the base Dockerfile as the parent image
FROM base

# Copy the Java application code into the container
COPY java /workspace/java

# Compile the Java application
RUN javac /workspace/java/Main.java

# Set the default command to run the Java application
CMD ["java", "-cp", "/workspace/java", "Main"]
