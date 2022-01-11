FROM alpine:3.14

LABEL Maintainer="Luke Zbihlyj"

# Install packages that we need
RUN apk --no-cache add \
    curl \
    nginx \
    php8 \
    php8-curl \
    php8-fpm \
    php8-json \
    php8-mbstring \
    php8-opcache \
    php8-openssl \
    php8-phar \
    php8-simplexml \
    supervisor

# Create symlink so programs depending on `php` still function
RUN ln -s /usr/bin/php8 /usr/bin/php

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Configure nginx
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx-app.conf /etc/nginx/conf.d/app.conf

# Configure PHP-FPM
COPY .docker/php-fpm.conf /etc/php8/php-fpm.d/www.conf
COPY .docker/php.ini /etc/php8/conf.d/custom.ini

# Configure supervisord
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /app

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody:nobody /app && \
    chown -R nobody:nobody /run && \
    chown -R nobody:nobody /var/lib/nginx && \
    chown -R nobody:nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /app

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --interval=10s --timeout=5s \
    CMD curl -s -f -I -X GET http://127.0.0.1/internal/fpm-health-check
