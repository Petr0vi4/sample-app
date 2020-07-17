ARG PHP_VERSION="7.4.8"
ARG NGINX_VERSION="1.18.0"
ARG COMPOSER_VERSION="1.10.9"

# ------------------------------------------------------ FPM -----------------------------------------------------------

FROM php:${PHP_VERSION}-fpm-alpine AS php-fpm-base

RUN docker-php-ext-install opcache && \
    docker-php-source delete
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
RUN mkdir /var/www/app && \
    chown www-data:www-data /var/www/app
USER www-data
RUN composer global require hirak/prestissimo
USER root
COPY .docker/php-fpm/www.conf /usr/local/etc/php/conf.d/www.conf
WORKDIR /var/www/app
EXPOSE 9000

FROM php-fpm-base AS php-fpm

ENV APP_ENV prod
ENV APP_DEBUG 0

USER www-data
COPY --chown=www-data:www-data composer.json composer.lock symfony.lock .env ./
RUN composer install --no-dev --no-ansi --no-interaction --no-progress --no-suggest --no-scripts --optimize-autoloader
COPY --chown=www-data:www-data public ./public
COPY --chown=www-data:www-data bin/console ./bin/console
COPY --chown=www-data:www-data config ./config
COPY --chown=www-data:www-data src ./src
RUN composer run-script post-install-cmd && composer clear-cache
USER root

# ----------------------------------------------------- NGINX ----------------------------------------------------------

FROM nginx:${NGINX_VERSION}-alpine AS nginx-base

COPY .docker/nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

FROM nginx-base AS nginx

COPY --from=php-fpm --chown=nginx:nginx /var/www/app/public /var/www/app/public
