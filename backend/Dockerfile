FROM python:3.9-alpine AS builder
WORKDIR /app

COPY ./backend/pyproject.toml ./backend/requirements.txt /app/
RUN pip install --no-cache-dir wheel
RUN pip wheel --no-cache-dir -r /app/requirements.txt -w /wheels

FROM python:3.9-alpine AS runner
WORKDIR /app

COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/* && rm -rf /wheels
COPY ./backend/main.py ./backend/omdb.py /app/main.py/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]