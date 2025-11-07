ARG BASE_IMAGE=ubuntu:24.04

FROM ${BASE_IMAGE} AS builder
WORKDIR /app

RUN apt update
RUN apt install -y \
    curl \
    git \
    ca-certificates \
    bash \
    build-essential \
    make \
    wget \
    libclang-dev \
    ca-certificates

# install mise (platform/arch auto-detected)
RUN curl -fsSL https://mise.run | sh
ENV PATH="/root/.local/share/mise/shims:/root/.local/bin:${PATH}"
SHELL ["/bin/bash", "-lc"]
RUN eval "$(mise activate bash)"

ARG REPO=https://github.com/ethereum-optimism/optimism.git
ARG COMMIT=971c25eb5a5564ce239e3c4a95778abb24ca87d7
ARG VERSION=v1.16.0

RUN git init
RUN git remote add origin ${REPO}
RUN git fetch --depth 1 origin ${COMMIT}
RUN git checkout FETCH_HEAD

# remove fake dependencies that make mise break
RUN sed -i.bak '/^asterisc = /d; /^kontrol = /d; /^binary_signer = /d' mise.toml
RUN mise trust && mise install golang just

RUN make op-node

# execution environment
FROM ${BASE_IMAGE}
WORKDIR /app

COPY --from=builder /app/op-node/bin/op-node    /app/
COPY ./op-node-entrypoint.sh                    /app/entrypoint.sh