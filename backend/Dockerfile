FROM python:3.9-alpine AS builder
LABEL builder=true
WORKDIR /app

COPY pyproject.toml requirements.txt /app/
RUN pip install --no-cache-dir wheel
RUN pip wheel --no-cache-dir -r /app/requirements.txt -w /wheels

FROM python:3.9-alpine AS runner
WORKDIR /app

COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/* && rm -rf /wheels
COPY main.py omdb.py /app/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]