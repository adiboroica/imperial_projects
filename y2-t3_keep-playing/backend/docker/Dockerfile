FROM python:3.12-slim

# build-essential + libpq-dev are needed to compile psycopg2 from source
# (production-grade, replaces the convenience psycopg2-binary wheel).
# build-essential pulls in gcc, make, and the libc headers (stdlib.h etc.)
# that are stripped from the slim base image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml .
RUN pip install --no-cache-dir ".[test]"

COPY . .

RUN mkdir -p static media/images assets

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
