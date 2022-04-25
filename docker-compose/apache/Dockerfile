ARG PHP_VERSION=8.0
FROM php:${PHP_VERSION}-apache
LABEL Maintainer="Dan Klassen <dan@triplei.ca>"
LABEL Description="Apache / PHP 8 container"
ARG uid=1000
ARG user=elccu
ARG SSH_PRIVATE_KEY

# install our required php extensions - see https://github.com/mlocati/docker-php-extension-installer for usage / details
# mcrypt is included here on the off-chance the default encryption helper is used but it shouldn't be relied upon
# as something like lib_sodium is more modern and maintained
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && /usr/local/bin/install-php-extensions \
    @composer \
    bcmath \
    curl \
    exif \
    gd \
    imagick \
    intl \
    mbstring \
    mcrypt \
    pdo_mysql \
    pcntl \
    zip

# install curl, git, and ghostscript
RUN apt-get update && \
 apt-get install curl git ghostscript -y && \
 apt-get clean && rm -rf /var/lib/apt/lists/*

# web server permissions
RUN useradd -G www-data,root -u $uid -d /home/$user $user

# set composer permissions
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Enable apache modules
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

# copy our PHP.ini file
COPY docker-compose/apache/config/php.ini "$PHP_INI_DIR/php.ini"

# copy our policy.xml which allows for ImageMagic to read PDF files
COPY docker-compose/apache/config/image-magic-policy.xml /etc/ImageMagick-6/policy.xml

#copy our entry point which runs the composer install and any other build scripts
COPY docker-compose/apache/scripts/entrypoint.sh /tmp/entrypoint.sh

# copy our apache config file
COPY docker-compose/apache/config/apache-default.conf /etc/apache2/sites-enabled/000-default.conf

# clear out the /var/www directory so we can clone the project there later
RUN mkdir -p /home/$user/scripts &&  \
    chown -R $user.$user /home/$user/scripts/ && \
    rm -rf /var/www/html && \
    chmod 775 /var/www

# Set working directory
WORKDIR /var/www

# switch to the app user
USER $user

# copy private key which is used for installing composer packages
RUN mkdir ~/.ssh/ &&\
 echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa && \
 chmod 700 ~/.ssh/ && \
 chmod 600 ~/.ssh/id_rsa

# copy a base known_hosts file to allow connecting to gitea.triplei.ca without asking for interactive confirmation
# if the source is to be pulled from a different source this known_hosts file may need updating
COPY docker-compose/apache/config/known_hosts /home/$user/.ssh/known_hosts

COPY .env /var/www

ENTRYPOINT ["/tmp/entrypoint.sh", "docker-php-entrypoint"]
CMD ["apache2-foreground"]
