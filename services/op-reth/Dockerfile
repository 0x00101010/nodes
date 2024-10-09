FROM rust:1.81 AS op-reth-builder
WORKDIR /app

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    git \
    libclang-dev \
    pkg-config \
    curl \
    build-essential

# ENV REPO=https://github.com/paradigmxyz/reth.git
ENV REPO=https://github.com/0x00101010/reth.git
ENV COMMIT=09e2ef238aae6dd666d1b67958014fec81791a5c
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN make build-op

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

COPY --from=op-reth-builder /app/target/release/op-reth /app/
COPY ./reth-entrypoint.sh                               /app/