FROM golang:1.22 AS builder
WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV COMMIT=f8143c8cbc4cc0c83922c53f17a1e47280673485
ENV VERSION=v1.7.7
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

# execution environment
FROM ubuntu:24.04
WORKDIR /app

COPY --from=builder /app/op-node/bin/op-node    /app/
COPY ./op-node-entrypoint.sh                    /app/