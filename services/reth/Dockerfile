ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS BUILDER
WORKDIR /app

ARG ASDF_VERSION=v0.14.1
ARG RUST_VERSION=1.82
ARG REPO=https://github.com/paradigmxyz/reth.git
ARG VERSION=v1.1.2
ARG COMMIT=496bf0bf715f0a1fafc198f8d72ccd71913d1a40

# install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    git \
    libclang-dev \
    pkg-config \
    curl \
    build-essential

# install asdf and rust
ENV ASDF_ROOT=/root/.asdf
ENV PATH="${ASDF_ROOT}/bin:${ASDF_ROOT}/shims:$PATH"
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_ROOT} --branch ${ASDF_VERSION}
RUN asdf plugin add rust && \
    asdf install rust ${RUST_VERSION} && \
    asdf global rust ${RUST_VERSION}

# download source code
RUN git init && \
    git remote add origin ${REPO} && \
    git fetch --depth 1 origin ${COMMIT} && \
    git checkout FETCH_HEAD

# build
RUN make build

FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    vim \
    iproute2

COPY --from=BUILDER     /app/target/release/reth    /app/
COPY ./entrypoint.sh    /app/
