FROM ubuntu:20.04

RUN useradd -m appuser

RUN apt-get update && \
    apt-get install -y python3 python3-pip git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=appuser:appuser . /app
WORKDIR /app

USER appuser

CMD ["python3", "app.py"]
