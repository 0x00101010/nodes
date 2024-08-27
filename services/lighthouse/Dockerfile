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

ENV REPO=https://github.com/sigp/lighthouse.git
ENV COMMIT=d6ba8c397557f5c977b70f0d822a9228e98ca214
ENV VERSION=v5.3.0
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