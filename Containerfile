FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install curl for the healthcheck
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Copy necessary files from local directory
COPY mcp_server.py .
COPY requirements.txt .
COPY update_components.py .
COPY components/ ./components/
COPY .gitignore .
COPY LICENSE .
COPY README.md .

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt

# Run the update script to fetch the latest components on build
RUN python update_components.py

# Set the default port
ENV PORT=8000

# Expose the default port (for documentation purposes)
EXPOSE $PORT

# Smarter healthcheck: Evaluates the dynamic port.
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -s http://localhost:${PORT}/mcp > /dev/null || exit 1

# Command to run the MCP server over HTTP by default.
# Using shell form so that $PORT is properly evaluated.
CMD fastmcp run mcp_server.py:mcp --transport http --host 0.0.0.0 --port $PORT
