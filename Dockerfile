FROM php:7.4-fpm-alpine
ENV BUILD_DEPS="freetype-dev libjpeg-turbo-dev libpng-dev php7-dev alpine-sdk gettext" \
    RUNTIME_DEPS="bash freetype libjpeg-turbo libpng libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure gd \
            --enable-gd \
            --with-freetype \
            --with-jpeg && \
    docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd iconv pdo pdo_mysql && \
    pecl install apcu apcu_bc && docker-php-ext-enable apcu && \
    apk del build_deps

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php --filename=composer && \
	php -r "unlink('composer-setup.php');"

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
RUN echo 'apc.enable_cli = "On"' >> $PHP_INI_DIR/php.ini