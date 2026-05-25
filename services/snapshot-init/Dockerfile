ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    aria2 \
    zstd \
    tar \
    curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
