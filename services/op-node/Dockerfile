ARG REPO=https://github.com/ethereum-optimism/optimism.git
ARG COMMIT=971c25eb5a5564ce239e3c4a95778abb24ca87d7
ARG VERSION=v1.16.0

FROM golang:1.22 AS builder
WORKDIR /app

RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

# execution environment
FROM ubuntu:24.04
WORKDIR /app

COPY --from=builder /app/op-node/bin/op-node    /app/
COPY ./op-node-entrypoint.sh                    /app/entrypoint.sh