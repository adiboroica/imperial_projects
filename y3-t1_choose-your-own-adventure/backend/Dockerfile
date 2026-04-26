# Multi-stage build:
#   `base`     — system deps + torch (CPU). Heaviest layer, cached.
#   `runtime`  — adds the editable install of runtime deps + the
#                sentence-transformers model. Shared by dev and prod.
#   `prod`     — runtime as-is. The default `docker build` target.
#   `dev`      — runtime + the `[dev]` optional dependencies (pytest,
#                ruff, mypy, …). Used by `docker-compose.dev.yml`.

FROM python:3.10-slim AS base

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install torch first from the CPU-only index. Quoted so the shell does not
# parse `>=` as redirection (which silently drops the version pin).
COPY pyproject.toml .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        --index-url https://download.pytorch.org/whl/cpu \
        --extra-index-url https://pypi.org/simple \
        "torch>=2.0.0"

COPY . .


FROM base AS runtime

# Install runtime deps via editable install — pyproject `[project.dependencies]`.
RUN pip install --no-cache-dir -e .

# Pre-download the sentence-transformers model used for duplicate detection.
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]


FROM runtime AS prod
# `prod` inherits `runtime` unchanged — runtime deps only, no dev tooling.


FROM runtime AS dev
RUN pip install --no-cache-dir -e ".[dev]"
