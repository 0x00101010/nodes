ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS BUILDER
WORKDIR /app

ARG ASDF_VERSION=v0.14.1
ARG RUST_VERSION=1.82
ARG REPO=https://github.com/sigp/lighthouse.git
ARG VERSION=v5.3.0
ARG COMMIT=d6ba8c397557f5c977b70f0d822a9228e98ca214

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
RUN make

FROM ${BASE_IMAGE}
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    vim \
    iproute2

COPY --from=BUILDER /usr/local/cargo/bin/lighthouse /app/
COPY ./beacon-node-entrypoint.sh                    /app/
