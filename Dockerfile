FROM php:7.4-fpm-alpine
ENV BUILD_DEPS="freetype-dev libjpeg-turbo-dev libpng-dev php7-dev alpine-sdk gettext libzip-dev postgresql-dev" \
    RUNTIME_DEPS="bash freetype libjpeg-turbo libpng libintl libzip postgresql"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure exif && \
    docker-php-ext-configure pgsql && \
    docker-php-ext-configure gd \
            --enable-gd \
            --with-freetype \
            --with-jpeg && \
    docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd iconv pdo pdo_mysql pdo_pgsql pgsql zip opcache exif && \
    pecl install apcu apcu_bc && docker-php-ext-enable apcu && \
    apk del build_deps

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
RUN echo 'apc.enable_cli = "On"' >> $PHP_INI_DIR/php.ini
