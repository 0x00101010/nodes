ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}
WORKDIR /app

ARG VERSION=v1.8.3

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    jq \
    vim \
    iproute2

RUN wget "https://github.com/paradigmxyz/reth/releases/download/${VERSION}/reth-${VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    tar -xvf "reth-${VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    rm -rf "reth-${VERSION}-x86_64-unknown-linux-gnu*"

COPY ./entrypoint.sh    /app/
