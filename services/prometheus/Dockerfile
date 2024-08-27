FROM ubuntu:24.04 AS builder

WORKDIR /app

# install dependencies
RUN apt update && \
    apt install -y \
    curl \
    wget \
    build-essential

ENV OS_ARCH=linux-amd64
ENV VERSION=2.53.1
ENV NAME="prometheus-$VERSION.$OS_ARCH"
ENV URL="https://github.com/prometheus/prometheus/releases/download/v$VERSION/$NAME.tar.gz"

RUN wget $URL
RUN tar -xf $NAME.tar.gz
RUN mv $NAME/prometheus .

# execution environment
FROM ubuntu:24.04

WORKDIR /app

RUN apt update && \
    apt install -y \
    curl \
    jq \
    gettext

COPY --from=builder /app/prometheus     /app/
COPY ./prometheus-entrypoint.sh         /app/
COPY ./ethereum-config-template.yml     /app/
COPY ./base-config-template.yml         /app/
COPY ./host-config-template.yml         /app/