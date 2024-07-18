FROM ubuntu:24.04 AS builder

WORKDIR /app

# install dependencies
RUN apt update && \
    apt install -y \
    curl \
    wget \
    build-essential

ENV PROMETHEUS_VERSION=2.53.1
ENV NAME="prometheus-$PROMETHEUS_VERSION.linux-amd64"
ENV URL="https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/$NAME.tar.gz"

RUN wget $URL
RUN tar -xf $NAME.tar.gz
RUN mv $NAME/prometheus .

FROM ubuntu:24.04

WORKDIR /app

RUN apt update && \
    apt install -y \
    curl \
    jq \
    gettext

COPY --from=builder /app/prometheus     /app/
COPY ./prometheus-entrypoint.sh         /app/
COPY ./prometheus-config-template.yml   /app/