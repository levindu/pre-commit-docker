FROM python:3.8

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -qqy update && apt-get -qqy dist-upgrade && apt-get install -qqy git shellcheck unzip && apt-get -qqy autoremove && apt-get -qqy autoclean

RUN pip install --quiet --upgrade pip
RUN pip install --quiet pre-commit

RUN adduser --system pre-commit

RUN install -d -o pre-commit /pre-install-temp /code

WORKDIR /pre-install-temp
COPY .pre-commit-config.yaml /pre-install-temp/
RUN git init
RUN pre-commit install-hooks

VOLUME /code

WORKDIR /code

ENTRYPOINT pre-commit install-hooks && pre-commit run --all-files
