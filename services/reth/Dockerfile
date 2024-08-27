FROM rust:1.80 AS builder
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
ENV COMMIT=603e39ab74509e0863fc023461a4c760fb2126d1
ENV VERSION=v1.0.5
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN make build-op
RUN make build

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

COPY --from=builder /app/target/release/reth    /app/
COPY --from=builder /app/target/release/op-reth /app/
COPY ./reth-entrypoint.sh                       /app/