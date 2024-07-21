FROM rust:1.79 AS builder
WORKDIR /app

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    git \
    libclang-dev \
    pkg-config \
    curl \
    build-essential

ENV REPO=https://github.com/paradigmxyz/reth.git
ENV COMMIT=390f30aadebcdd509e72cc04327c3b854de076a6
ENV VERSION=v1.0.3
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

ARG FEATURES=jemalloc,asm-keccak,optimism
RUN cargo build --bin op-reth --locked --features $FEATURES --profile maxperf

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

COPY --from=builder /app/target/maxperf/op-reth /app/
COPY ./op-reth-entrypoint.sh                    /app/