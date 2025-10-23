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
    bsdtar \
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

# Create extensions directory
RUN mkdir -p /home/coder/.local/share/code-server/extensions

# Download and install VSCode extensions manually from marketplace
# Python extension
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/2024.16.1/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/ms-python.python-2024.16.1

# Pylance extension
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/vscode-pylance/2024.10.1/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/ms-python.vscode-pylance-2024.10.1

# Python Debugger extension
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/debugpy/2024.12.0/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/ms-python.debugpy-2024.12.0

# SQLTools extension
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/0.28.3/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/mtxr.sqltools-0.28.3

# SQLTools SQL Server driver
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mssql/0.5.1/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/mtxr.sqltools-driver-mssql-0.5.1

# SQLTools DuckDB driver
RUN curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Evidence/vsextensions/sqltools-duckdb-driver/0.2.1/vspackage | bsdtar -xvf - extension \
    && mv extension /home/coder/.local/share/code-server/extensions/Evidence.sqltools-duckdb-driver-0.2.1

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PATH="/home/coder/.local/bin:${PATH}"

WORKDIR /home/coder

USER coder
