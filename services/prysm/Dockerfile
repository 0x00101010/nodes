ARG BASE_IMAGE=ubuntu:24.04
ARG ASDF_VERSION=v0.14.1
ARG GO_VERSION=1.22.9
ARG REPO=https://github.com/prysmaticlabs/prysm.git
ARG VERSION=v1.14.12
ARG COMMIT=293a300d64be3d9a1c2cc92c26fcff4089deadcd

# building binaries
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

# download source code
RUN git init && \
    git remote add origin ${REPO} && \
    git fetch --depth 1 origin ${COMMIT} && \
    git checkout FETCH_HEAD

# build
# The flag below may be needed if blst throws SIGILL, which happens with certain (older) CPUs
# ENV CGO_CFLAGS="-O -D__BLST_PORTABLE__"
# ENV CGO_CFLAGS=$CGO_CFLAGS
RUN go mod tidy
RUN go build -o /build/beacon-node  ./cmd/beacon-chain
RUN go build -o /build/validator    ./cmd/validator

# runtime
FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    vim \
    iproute2

WORKDIR /app

COPY --from=BUILDER /build/beacon-node  /app/
COPY --from=BUILDER /build/validator    /app/
COPY ./beacon-node-entrypoint.sh        /app/
COPY ./validator-entrypoint.sh          /app/
COPY ./validator-import-accounts.sh     /app/