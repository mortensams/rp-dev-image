FROM codercom/code-server:latest

USER root

# Install Python 3.11 and system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    python3.11-venv \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Remove externally-managed file to allow pip installs (safe in containers)
RUN rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED

# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip

# Install dbt-core and common adapters
RUN pip3 install --no-cache-dir \
    dbt-core \
    dbt-postgres \
    dbt-sqlserver \
    dbt-duckdb

USER coder

# Pre-install Microsoft Python VSCode extensions
RUN code-server --install-extension ms-python.python \
    && code-server --install-extension ms-python.vscode-pylance \
    && code-server --install-extension ms-python.debugpy

# Pre-install SQLTools and drivers
RUN code-server --install-extension mtxr.sqltools \
    && code-server --install-extension mtxr.sqltools-driver-mssql \
    && code-server --install-extension Evidence.sqltools-duckdb-driver

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/home/coder/.local/bin:${PATH}"

WORKDIR /home/coder

USER coder
