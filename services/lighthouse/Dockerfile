ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}
WORKDIR /app

ARG VERSION=v8.0.0-rc.2

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    jq \
    vim \
    iproute2

RUN wget "https://github.com/sigp/lighthouse/releases/download/${VERSION}/lighthouse-${VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    tar -xvf "lighthouse-${VERSION}-x86_64-unknown-linux-gnu.tar.gz" && \
    rm -rf "lighthouse-${VERSION}-x86_64-unknown-linux-gnu*"

COPY ./beacon-node-entrypoint.sh    /app/
