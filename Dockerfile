FROM php:7.4

#===============================================================================
# Adds `automation` user
#===============================================================================

RUN useradd automation --shell /bin/bash --create-home

#===============================================================================
# Initial dependencies
#===============================================================================

RUN apt-get update -yqq \
    && apt-get install \
    # Git
    git \
    # Other required packages
    libmcrypt-dev libpq-dev libcurl4-gnutls-dev \
    libicu-dev libvpx-dev libjpeg-dev libpng-dev \
    libxpm-dev zlib1g-dev libjpeg62-turbo-dev \
    libfreetype6-dev libxml2-dev libzip-dev \
    libexpat1-dev libbz2-dev libgmp3-dev libldap2-dev \
    unixodbc-dev  libaspell-dev \
    libsnmp-dev libpcre3-dev libtidy-dev libonig-dev -yqq \
    # SQLite
    libsqlite3-dev \
    && curl -O https://sqlite.org/2020/sqlite-autoconf-3340000.tar.gz \
    && tar -xvzf sqlite-autoconf-3340000.tar.gz && cd sqlite-autoconf-3340000 \
    && ./configure && make && make install


#===============================================================================
# Set up PHP
#===============================================================================    

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install mbstring \
    pdo pdo_pgsql pdo_mysql mysqli \
    curl json intl gd xml zip bz2 opcache exif bcmath pcntl

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get install -y \
        libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick

#===============================================================================
# Install Node 15.x
#===============================================================================    

RUN apt-get install gnupg2 -yqq \
    && curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install gcc g++ make -yqq \
    && apt-get install -y nodejs -yqq \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install yarn -yqq
