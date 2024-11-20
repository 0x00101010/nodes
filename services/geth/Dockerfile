ARG BASE_IMAGE=ubuntu:24.04
ARG ASDF_VERSION=v0.14.1
ARG GO_VERSION=1.22.9
ARG GETH_REPO=https://github.com/ethereum/go-ethereum.git
ARG GETH_VERSION=v1.14.12
ARG GETH_COMMIT=293a300d64be3d9a1c2cc92c26fcff4089deadcd

FROM ${BASE_IMAGE} AS BUILDER
WORKDIR /app

# install dependencies
RUN apt update && \
    apt install -y \
    build-essential \
    cmake \
    git \
    wget \
    libssl-dev \
    pkg-config \
    libcurl4-openssl-dev \
    curl \
    autoconf \
    automake \
    libtool \
    inotify-tools \
    unzip \
    tzdata

# install golang
ENV ASDF_ROOT=/root/.asdf
ENV PATH="${ASDF_ROOT}/bin:${ASDF_ROOT}/shims:$PATH"
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_ROOT} --branch ${ASDF_VERSION}
RUN asdf plugin add golang && \
    asdf install golang ${GO_VERSION} && \
    asdf global golang ${GO_VERSION}

# download and build from source code
RUN git init && \
    git remote add origin ${OP_GETH_REPO} && \
    git fetch --depth 1 origin ${OP_GETH_COMMIT} && \
    git checkout FETCH_HEAD && \
    make geth

FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    vim \
    iproute2

WORKDIR /app
COPY --from=builder /app/build/bin/geth  /app/
COPY ./geth-entrypoint.sh /app/