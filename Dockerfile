#############################################################################
# Dockerfile to build an image with Git, php-cli and composer
# Based on alexwijn/docker-git-php-composer                                         
#############################################################################

ARG UBUNTU_VERSION=${UBUNTU_VERSION}

## Set the base image to Ubuntu
FROM ubuntu:${UBUNTU_VERSION}

ARG PHP_VERSION=${PHP_VERSION}
ARG PHP_UNIT_VERSION=${PHP_UNIT_VERSION}

## File Author / Maintainer
MAINTAINER Logan Lindquist <logan@llbbl.com>

## Tell everyone we are not interactive
ENV DEBIAN_FRONTEND noninteractive

# Set the locale
RUN apt-get clean && apt-get update
RUN apt-get install locales

## Update locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

## Install basic things
RUN apt-get update && apt-get install -y --no-install-recommends \
    gpg-agent \
    libpng-dev \
    apt-utils \
    apt-transport-https \
    software-properties-common \
    openssh-client \
    curl \
    ca-certificates \
    wget \
    git \
    gcc \
    make \
    unzip \
    python3 \
    python3-pip \
    python3-setuptools \
    libxrender1 \
    libxtst6


## Add php repository
RUN add-apt-repository ppa:ondrej/php -y

## Add git repository
RUN add-apt-repository ppa:git-core/ppa -y

## Add chromium repository
# RUN add-apt-repository ppa:chromium-team/stable -y

## Add yarn repository
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list


## Installs PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-mailparse \
    php${PHP_VERSION}-imap
    
## Laravel Dusk support (Chrome)
#RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
#RUN apt-get -y install chromium-browser
#RUN apt-get install chromium

## XVFB for headless applications
#RUN apt-get -y install xvfb gtk2-engines-pixbuf

## Fonts for the browser
#RUN apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable

## Support for screenshot capturing
#RUN apt-get -y install imagemagick x11-apps
    
## Upgrades
#RUN apt-get dist-upgrade -y

## Add SSL support
RUN apt-get -y install libssl-dev openssl

## Install yarn
RUN apt-get -y install npm yarn

## Configure tzdata
RUN ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Disable XDebug on the CLI
RUN phpdismod -s cli xdebug

## Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

## Add composer bin to PATH
ENV PATH "$PATH:$HOME/.composer/vendor/bin:/root/.composer/vendor/bin"

## Install composer plugins
RUN composer global require "hirak/prestissimo:^0.3.10"
RUN composer global require "laravel/envoy:^2.1.0"
RUN composer global require "laravel/dusk"

## Install codesniffer
RUN wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
RUN chmod +x phpcs.phar
RUN mv phpcs.phar /usr/local/bin/phpcs

## Install mess detector
RUN wget https://phpmd.org/static/latest/phpmd.phar
RUN chmod +x phpmd.phar
RUN mv phpmd.phar /usr/local/bin/phpmd

## Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit-$PHP_UNIT_VERSION.phar
RUN chmod +x phpunit-$PHP_UNIT_VERSION.phar
RUN mv phpunit-$PHP_UNIT_VERSION.phar /usr/local/bin/phpunit

## Install Sentry CLI
RUN curl -sL https://sentry.io/get-cli/ | bash

## Install change log generator
RUN pip3 install gitchangelog pystache

## Install Git Subsplit
RUN wget https://raw.githubusercontent.com/dflydev/git-subsplit/master/git-subsplit.sh
RUN chmod +x git-subsplit.sh
RUN mv git-subsplit.sh "$(git --exec-path)"/git-subsplit

# Install deployer
RUN wget https://deployer.org/deployer.phar
RUN chmod +x deployer.phar
RUN mv deployer.phar /usr/local/bin/dep
