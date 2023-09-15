FROM elixir:1.11.4-alpine

ARG PLEROMA_VER=develop
ARG UID=911
ARG GID=911
ENV MIX_ENV=prod

RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories \
    && apk update \
    && apk add git gcc g++ musl-dev make cmake file-dev \
    exiftool imagemagick libmagic ncurses postgresql-client ffmpeg

ARG DATA=/var/lib/pleroma
RUN mkdir -p /etc/pleroma \
    && mkdir -p ${DATA}/uploads \
    && mkdir -p ${DATA}/static

USER root
WORKDIR /pleroma

RUN git clone -b develop https://git.pleroma.social/pleroma/pleroma.git /pleroma \
    && git checkout ${PLEROMA_VER} 

RUN echo "import Mix.Config" > config/prod.secret.exs \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mkdir release \
    && mix release --path /pleroma

COPY ./config.exs /etc/pleroma/config.exs

RUN chmod o= /etc/pleroma/config.exs

EXPOSE 4000

ENTRYPOINT ["./docker-entrypoint.sh"]
