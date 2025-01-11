ARG PYTHON_VERSION=3.9-alpine
FROM python:${PYTHON_VERSION} AS builder
LABEL builder=true

WORKDIR /app

COPY pyproject.toml requirements.txt /app/
RUN pip install --no-cache-dir wheel
RUN pip wheel --no-cache-dir -r /app/requirements.txt -w /wheels

FROM python:${PYTHON_VERSION} AS runner
WORKDIR /app
ENV CACHE_TTL=600
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/* && rm -rf /wheels
COPY main.py omdb.py /app/

ENTRYPOINT ["uvicorn", "omdb:app"]
CMD ["--host", "0.0.0.0", "--port", "8000"]