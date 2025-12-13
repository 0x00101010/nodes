ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE}
WORKDIR /app

ARG TEMPO_VERSION
ARG TARGETARCH
ARG TARGETOS

RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    jq \
    vim \
    iproute2 \
    ca-certificates

RUN case "${TARGETARCH}" in \
        amd64) TEMPO_ARCH="x86_64" ;; \
        arm64) TEMPO_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    case "${TARGETOS}" in \
        linux) TEMPO_OS="unknown-linux-gnu" ;; \
        darwin) TEMPO_OS="apple-darwin" ;; \
        *) echo "Unsupported OS: ${TARGETOS}" && exit 1 ;; \
    esac && \
    wget "https://github.com/tempoxyz/tempo/releases/download/${TEMPO_VERSION}/tempo-${TEMPO_VERSION}-${TEMPO_ARCH}-${TEMPO_OS}.tar.gz" && \
    tar -xvf "tempo-${TEMPO_VERSION}-${TEMPO_ARCH}-${TEMPO_OS}.tar.gz" && \
    rm -rf "tempo-${TEMPO_VERSION}-${TEMPO_ARCH}-${TEMPO_OS}*"

COPY ./entrypoint.sh    /app/
