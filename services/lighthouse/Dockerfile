FROM rust:1.80 AS builder
WORKDIR /app

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
    git \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    llvm-dev \
    libclang-dev \
    clang

ENV REPO=https://github.com/jimmygchen/lighthouse.git
ENV COMMIT=422fc1b6a5c79873ee179a28a7c4b45b404ac16b
ENV VERSION=das-fetch-blobs
RUN git clone $REPO --branch $VERSION --single-branch .
RUN make

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

COPY --from=builder /usr/local/cargo/bin/lighthouse /app/
COPY ./beacon-node-entrypoint.sh                    /app/