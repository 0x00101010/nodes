FROM ubuntu:24.04 AS builder
WORKDIR /app

RUN apt update && \
    apt install -y \
    adduser \
    libfontconfig1 \
    musl \
    wget

ENV GRAFANA_VERSION=11.1.0
ENV GRAFANA_TAR_NAME="grafana-v${GRAFANA_VERSION}.tar.gz"
ENV GRAFANA_FOLDER="grafana"
ENV GRAFANA_BINARY="https://dl.grafana.com/enterprise/release/grafana-enterprise-${GRAFANA_VERSION}.linux-amd64.tar.gz"

RUN wget -O $GRAFANA_TAR_NAME $GRAFANA_BINARY
RUN mkdir -p $GRAFANA_FOLDER
RUN tar -xf $GRAFANA_TAR_NAME --strip-components=1 -C $GRAFANA_FOLDER

# execution environment
FROM ubuntu:24.04
WORKDIR /app

RUN apt update && \
    apt install -y \
    curl \
    jq \
    gettext

COPY --from=builder /app/grafana    /app/grafana
COPY ./entrypoint.sh        /app/