ARG PROTOBUF_VERSION=v3.12.3
ARG GRPC_VERSION=v1.30.2

FROM ubuntu:devel
ARG PROTOBUF_VERSION
ARG GRPC_VERSION

LABEL maintainer "rinx <rintaro.okamura@gmail.com>"

RUN apt-get update \
    && apt-get install -y \
    git \
    curl \
    gcc \
    g++ \
    make \
    autoconf \
    libtool \
    libprotobuf-dev \
    libprotoc-dev \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $HOME/protobuf \
    && curl -L https://github.com/protocolbuffers/protobuf/archive/${PROTOBUF_VERSION}.tar.gz \
    | tar xvz --strip-components=1 -C $HOME/protobuf \
    && cd $HOME/protobuf \
    && autoreconf -f -i -Wall,no-obsolete \
    && ./configure --prefix=/usr --enable-static=no \
    && make -j2 \
    && make install

RUN mkdir -p $HOME/grpc-java \
    && curl -L https://github.com/grpc/grpc-java/archive/${GRPC_VERSION}.tar.gz \
    | tar xvz --strip-components=1 -C $HOME/grpc-java \
    && cd $HOME/grpc-java/compiler/src/java_plugin/cpp \
    && g++ -I. -I$HOME/protobuf/src \
    *.cpp \
    -L$HOME/protobuf/src/.libs \
    -lprotoc -lprotobuf -lpthread --std=c++0x -s \
    -o protoc-gen-grpc-java \
    && cp protoc-gen-grpc-java /usr/local/bin/protoc-gen-grpc-java
