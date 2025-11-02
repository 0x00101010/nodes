ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS builder
WORKDIR /app

RUN apt update -y && apt install -y git gpg sudo wget curl apt-utils libclang-dev build-essential
RUN install -dm 755 /etc/apt/keyrings
RUN wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list
RUN apt update
RUN apt install -y mise

ARG REPO=https://github.com/ethereum-optimism/optimism.git
ARG COMMIT=971c25eb5a5564ce239e3c4a95778abb24ca87d7
ARG VERSION=v1.16.0
ARG GOLANG_VERSION=1.23

RUN mise install golang@${GOLANG_VERSION}
RUN mise use -g golang@${GOLANG_VERSION}
RUN mise install just

RUN git init
RUN git remote add origin ${REPO}
RUN git fetch --depth 1 origin ${COMMIT}
RUN git checkout FETCH_HEAD

RUN cd op-node && \
    just VERSION=$VERSION op-node

# execution environment
FROM ${BASE_IMAGE}
WORKDIR /app

COPY --from=builder /app/op-node/bin/op-node    /app/
COPY ./op-node-entrypoint.sh                    /app/entrypoint.sh