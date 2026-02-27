FROM python:3.12-slim

WORKDIR /app

# Install dependencies first for layer caching
COPY requirements.txt* requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt \
    && if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Copy project source
COPY scripts/ ./scripts/
COPY data/ ./data/

CMD ["python", "-m", "scripts"]
