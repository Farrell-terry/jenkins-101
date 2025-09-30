FROM jenkins/jenkins:2.426.3-jdk11

# Switch to root for setup
USER root

# Install latest plugin CLI from GitHub and wrap it
RUN curl -L https://github.com/jenkinsci/plugin-installation-manager-tool/releases/latest/download/jenkins-plugin-cli.jar \
    -o /usr/local/bin/jenkins-plugin-cli.jar && \
    echo '#!/bin/bash\njava -jar /usr/local/bin/jenkins-plugin-cli.jar "$@"' > /usr/local/bin/jenkins-plugin-cli && \
    chmod +x /usr/local/bin/jenkins-plugin-cli

# Confirm Java is available (fixes CLI execution issues)
RUN java -version

# Install system dependencies
RUN apt-get update && apt-get install -y \
    lsb-release \
    python3-pip \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates

# Add Docker CLI repository and install
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli

# Switch back to Jenkins user
USER jenkins

# Copy plugin list and install plugins with verbose output
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt > /tmp/plugin-install.log || cat /tmp/plugin-install.log