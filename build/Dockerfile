FROM ubuntu:latest

LABEL maintainer="workout-app-team"
LABEL description="Build image for workout webapp CI/CD pipeline"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Version and checksum configuration
ARG GRADLE_VERSION=8.11.1
ARG GRADLE_SHA256=f397b287023acdba1e9f6fc5ea72d22dd63669d59ed4a289a29b1a76eee151c6
ARG UV_VERSION=0.5.14
ARG UV_SHA256=c872e0484d02c0d19e524bd4b1f3ee0a8362b363a0793dce8d4fc34a32d42679

# Install base dependencies, add repositories, and install all packages in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common \
    git \
    unzip \
    && \
    # Add NodeSource repository for Node.js LTS
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && \
    # Add deadsnakes PPA for Python 3.9
    add-apt-repository -y ppa:deadsnakes/ppa \
    && \
    # Add Amazon Corretto repository for Java 21
    curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
    && \
    # Install all packages from configured repositories
    apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    java-21-amazon-corretto-jdk \
    jq \
    && \
    # Cleanup apt cache
    rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager) with checksum verification
RUN curl -LsSf "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-installer.sh" -o uv-installer.sh \
    && echo "${UV_SHA256}  uv-installer.sh" | sha256sum -c - \
    && sh uv-installer.sh \
    && rm uv-installer.sh
ENV PATH="/root/.local/bin:${PATH}"

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Gradle with checksum verification
RUN wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O /tmp/gradle.zip \
    && echo "${GRADLE_SHA256}  /tmp/gradle.zip" | sha256sum -c - \
    && unzip -q /tmp/gradle.zip -d /opt \
    && ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle \
    && rm /tmp/gradle.zip

ENV GRADLE_HOME=/opt/gradle
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# Install OpenTofu via package manager (uses GPG-signed packages for verification)
RUN curl -fsSL https://get.opentofu.org/opentofu.gpg | gpg --dearmor -o /usr/share/keyrings/opentofu.gpg \
    && curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --dearmor -o /usr/share/keyrings/opentofu-repo.gpg \
    && chmod a+r /usr/share/keyrings/opentofu.gpg /usr/share/keyrings/opentofu-repo.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opentofu.gpg,/usr/share/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" > /etc/apt/sources.list.d/opentofu.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends tofu \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN echo "=== Verifying installations ===" \
    && node --version \
    && npm --version \
    && python3.9 --version \
    && uv --version \
    && git --version \
    && java --version \
    && gradle --version \
    && tofu --version \
    && jq --version

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
