FROM "debian:bookworm"

ARG apt_proxy

USER root

# apt sources
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# apt proxy
RUN test -n "$apt_proxy" && echo "Acquire::http { Proxy \"$apt_proxy\"; };" >/etc/apt/apt.conf.d/31proxy || :

# install deb list
COPY deb-list.txt /tmp/deb-list.txt

RUN apt-get update && \
    cat /tmp/deb-list.txt | DEBIAN_FRONTEND="noninteractive" xargs \
        apt-get install -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# install pre-commit
RUN PIPX_HOME=/usr/local/pipx PIPX_BIN_DIR=/usr/local/bin pipx install pre-commit

# Allow this repository's configuration to serve as a default which can be
# overwritten by the target repo:
WORKDIR /tmp/build
COPY .pre-commit-config.yaml .
RUN git init && pre-commit install-hooks && rm -rf /tmp/build

RUN git config --global --add safe.directory /code
COPY --chmod=755 run-pre-commit /usr/local/bin

VOLUME /code
WORKDIR /code

ENTRYPOINT ["/usr/local/bin/run-pre-commit"]
