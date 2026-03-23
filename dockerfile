FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    curl \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    zlib1g-dev \
    libzip-dev \
    libldap2-dev \
    libbz2-dev \
    libxslt1-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        curl \
        exif \
        gd \
        intl \
        ldap \
        mbstring \
        mysqli \
        opcache \
        xsl \
        zip \
    && pecl install apcu \
    && pecl install xdebug \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable xdebug \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/glpi-project/glpi/releases/download/11.0.6/glpi-11.0.6.tgz \
    | tar xz -C /var/www/html --strip-components=1

RUN a2enmod rewrite headers

RUN cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        Options FollowSymLinks
        AllowOverride None
        Require all granted

        RewriteEngine On

        RewriteCond %{HTTP:Authorization} ^(.+)$
        RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule ^(.*)$ index.php [QSA,L]
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

WORKDIR /var/www/html

COPY glpi_config/ /usr/local/share/glpi-config/
COPY docker-entrypoint-glpi.sh /usr/local/bin/docker-entrypoint-glpi.sh
COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini

RUN chmod +x /usr/local/bin/docker-entrypoint-glpi.sh

ENTRYPOINT ["docker-entrypoint-glpi.sh"]
CMD ["apache2-foreground"]
