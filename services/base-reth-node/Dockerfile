ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS builder
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    ca-certificates \
    bash \
    build-essential \
    make \
    wget \
    pkg-config \
    cmake \
    libclang-dev

# install mise (platform/arch auto-detected)
RUN curl -fsSL https://mise.run | sh
ENV PATH="/root/.local/share/mise/shims:/root/.local/bin:${PATH}"
SHELL ["/bin/bash", "-lc"]
RUN eval "$(mise activate bash)"

ARG RUST_VERSION
RUN mise install rust@${RUST_VERSION}
RUN mise use -g rust@${RUST_VERSION}

# We have to install mold explicitly here because on ubuntu22, the default
# version of mold installed is v1.x.x which has several years of missing
# updates and causes mdbx to panic on opening the db.
RUN wget -qO- https://github.com/rui314/mold/releases/download/v2.40.4/mold-2.40.4-x86_64-linux.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local

# fetch source at the pinned commit
ARG REPO
ARG COMMIT
RUN git init && \
    git remote add origin ${REPO} && \
    git fetch --depth 1 origin ${COMMIT} && \
    git checkout FETCH_HEAD

# build the base-reth-node binary (always release for production builds)
RUN cargo build --release --bin base-reth-node

FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/base-reth-node /app/base-reth-node
COPY ./entrypoint.sh                                   /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
