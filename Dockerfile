FROM python:3.11-slim-bookworm@sha256:0bee7276f83efd4a1ee05bbbf4281d95ed28e079220a9457f25a93e3f1e3c31b AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    SIGNALGATE_CONFIG_PATH=/app/config/config.json

RUN addgroup --system signalgate \
    && adduser --system --ingroup signalgate --home /app signalgate

WORKDIR /app

COPY docker/requirements.txt /app/requirements.txt
RUN python -m pip install --no-cache-dir --require-hashes -r /app/requirements.txt

COPY signalgate ./signalgate
COPY docs ./docs

RUN mkdir -p /app/config /app/data \
    && chown -R signalgate:signalgate /app

USER signalgate

EXPOSE 8765
VOLUME ["/app/config", "/app/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8765/healthz', timeout=2).read()"

CMD ["python", "-m", "signalgate.cli"]
