FROM debian:bullseye AS builder
RUN apt-get update && \
    apt-get install -y cmake g++-mingw-w64-i686-posix
