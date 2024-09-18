FROM php:8.2-fpm-bookworm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    lsb-release \
    gnupg \
    curl

# Add repo MySQL
RUN curl -s https://dev.mysql.com/downloads/repo/apt/ | grep mysql-apt-config \
    | grep href | awk -F '=' '{gsub(/&p/, "", $4); print "https://dev.mysql.com/get/"$4}' \
    | xargs wget -O mysql-apt-config.deb \
    && dpkg -i mysql-apt-config.deb && apt update

# Install dependencies
RUN apt-get update && apt-get install -y \
    mariadb-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    nano

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install extensions
RUN install-php-extensions gd pdo_mysql mysqli mbstring zip exif pcntl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 nginx
RUN useradd -u 101 -ms /bin/bash -g nginx nginx

# Copy existing application directory contents
# COPY . /var/www

# Copy existing application directory permissions
# COPY --chown=www:www . /var/www

# Change current user to www
USER nginx

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
