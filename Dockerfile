FROM php:7.2-fpm-alpine
ENV BUILD_DEPS="freetype-dev libjpeg-turbo-dev libpng-dev php7-dev alpine-sdk gettext" \
    RUNTIME_DEPS="bash freetype libjpeg-turbo libpng libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    docker-php-ext-configure gd \
            --with-gd \
            --with-freetype-dir=/usr/include/ \
            --with-png-dir=/usr/include/ \
            --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd iconv pdo pdo_mysql && \
    pecl install apcu apcu_bc && docker-php-ext-enable apcu && \
    apk del build_deps

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
RUN echo 'apc.enable_cli = "On"' >> $PHP_INI_DIR/php.ini