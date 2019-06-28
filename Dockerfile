FROM ubuntu:18.04
LABEL maintainer "REijkelenberg <https://github.com/REijkelenberg>"

ARG S6_VERSION="v1.22.1.0"
ARG S6_ARCH="amd64"
ARG DEBIAN_FRONTEND="noninteractive"
ARG LANG="en_US.UTF-8"
ARG LC_ALL="C.UTF-8"
ARG LANGUAGE="en_US.UTF-8"
ARG TERM="xterm-256color"
ARG COMPOSER_VERSION="1.8.6"

# Use an up to date version of PHP
RUN apt-get update && \ 
    apt-get install software-properties-common -y && \
    apt-add-repository ppa:ondrej/php && \
    apt-add-repository multiverse && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils locales\
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        curl \
        ffmpeg \
        gettext-base \
        git \
        libtext-micromason-perl \
        mediainfo \
        nginx-extras \
        p7zip-full \
        php7.2 \
        php7.2-cgi \
        php7.2-cli \
        php7.2-common \
        php7.2-curl \
        php7.2-gd \
        php7.2-json \
        php7.2-mysql \
        php7.2-readline \
        php7.2-recode \
        php7.2-tidy \
        php7.2-xml \
        php7.2-xmlrpc \
        php7.2-bcmath \
        php7.2-bz2 \
        php7.2-dba \
        php7.2-fpm \
        php7.2-intl \
        php7.2-mbstring \
        php7.2-soap \
        php7.2-xsl \
        php7.2-zip \
        php-imagick \
        php-pear \
        tzdata \
        unrar \
    && locale-gen $LANG

ADD "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" "/tmp/s6.tar.gz"
RUN tar xfz /tmp/s6.tar.gz -C /
RUN apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
    

EXPOSE 80 443
HEALTHCHECK NONE
COPY rootfs/ /
ENTRYPOINT ["/init"]

