FROM ubuntu:24.04 AS builder

WORKDIR /app

# install dependencies
RUN apt update && \
    apt install -y \
    build-essential \
    cmake \
    git \
    wget \
    libssl-dev \
    pkg-config \
    libcurl4-openssl-dev \
    curl \
    autoconf \
    automake \
    libtool \
    inotify-tools \
    unzip \
    tzdata

# install golang using asdf
ENV ASDF_ROOT=/root/.asdf
ENV PATH="${ASDF_ROOT}/bin:${ASDF_ROOT}/shims:$PATH"
RUN git clone https://github.com/asdf-vm/asdf.git ${ASDF_ROOT} --branch v0.14.0

ENV GO_VERSION=1.22.4
RUN asdf plugin add golang && \
    asdf install golang ${GO_VERSION} && \
    asdf global golang ${GO_VERSION}

# install bazel
# ENV BAZEL_VERSION=7.2.1
# RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
# RUN mv bazel-archive-keyring.gpg /usr/share/keyrings
# RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
# RUN apt update && apt install -y bazel-$BAZEL_VERSION
# RUN ln -s /usr/bin/baezel-$BAZEL_VERSION /usr/bin/bazel

# download source code
ENV REPO=https://github.com/prysmaticlabs/prysm.git
ENV VERSION=v5.0.3
ENV COMMIT=38f208d70dc95b12c08403f5c72009aaa10dfe2f
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

# build
# The flag below may be needed if blst throws SIGILL, which happens with certain (older) CPUs
# ENV CGO_CFLAGS="-O -D__BLST_PORTABLE__"
# ENV CGO_CFLAGS=$CGO_CFLAGS
RUN go mod tidy
RUN go build -o /build/beacon-node  ./cmd/beacon-chain
RUN go build -o /build/validator    ./cmd/validator

FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    iproute2

WORKDIR /app

COPY --from=builder /build/beacon-node  /app/
COPY --from=builder /build/validator    /app/