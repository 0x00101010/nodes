ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}
WORKDIR /app

ARG RETH_VERSION

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    jq \
    vim \
    iproute2

RUN wget "https://github.com/paradigmxyz/reth/releases/download/${RETH_VERSION}/reth-${RETH_VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    tar -xvf "reth-${RETH_VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    rm -rf "reth-${RETH_VERSION}-x86_64-unknown-linux-gnu*"

COPY ./entrypoint.sh    /app/
