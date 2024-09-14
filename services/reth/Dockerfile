FROM rust:1.81 AS reth-builder
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
# ENV COMMIT=f6444b2e704aab725320580104e1f97e68bdf9e1
# RUN git init && \
#     git remote add origin $REPO && \
#     git fetch --depth=1 origin $COMMIT && \
#     git reset --hard FETCH_HEAD

ENV REPO=https://github.com/0x00101010/reth.git
ENV COMMIT=f4a5f2c4b11a879560dd691feac17eb97a650593
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN make build

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
# ENV COMMIT=f6444b2e704aab725320580104e1f97e68bdf9e1
# RUN git init && \
#     git remote add origin $REPO && \
#     git fetch --depth=1 origin $COMMIT && \
#     git reset --hard FETCH_HEAD

ENV REPO=https://github.com/0x00101010/reth.git
ENV COMMIT=f4a5f2c4b11a879560dd691feac17eb97a650593
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

COPY --from=reth-builder    /app/target/release/reth    /app/
COPY --from=op-reth-builder /app/target/release/op-reth /app/
COPY ./reth-entrypoint.sh                               /app/