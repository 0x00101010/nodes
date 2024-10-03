FROM ubuntu:24.04 AS builder

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

# install golang using asdf
ENV ASDF_ROOT=/root/.asdf
ENV PATH="${ASDF_ROOT}/bin:${ASDF_ROOT}/shims:$PATH"
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_ROOT} --branch v0.14.0

ENV GO_VERSION=1.22.4
RUN asdf plugin add golang && \
    asdf install golang ${GO_VERSION} && \
    asdf global golang ${GO_VERSION}

# download source code
ENV REPO=https://github.com/0x00101010/op-geth.git
ENV COMMIT=559acc0fde7328f0a8625ae876544115334e068e
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth 1 origin $COMMIT && \
    git checkout FETCH_HEAD

# build
RUN go mod tidy
RUN make geth

FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

WORKDIR /app
COPY --from=builder /app/build/bin/geth  /app/
COPY ./geth-entrypoint.sh /app/