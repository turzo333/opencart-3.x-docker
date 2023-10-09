# Use an official PHP image as the base image
FROM php:7.4-apache as php7.4

# Set environment variables for MySQL

# Install required PHP extensions
RUN docker-php-ext-install mysqli && \
    docker-php-ext-install opcache && \
    docker-php-ext-install json && \
    docker-php-ext-install zip && \
    docker-php-ext-install gd && \
    docker-php-ext-install bcmath

# Enable Apache modules
RUN a2enmod rewrite

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Download and extract OpenCart
ADD https://github.com/opencart/opencart/archive/3.0.3.8.zip /var/www/html/

RUN apt-get update && \
    apt-get install -y unzip && \
    unzip 3.0.3.8.zip && \
    rm 3.0.3.8.zip && \
    mv opencart-3.0.3.8/upload/* . && \
    rm -rf opencart-3.0.3.8

# change config-dist.php to config and set permissions for config files
RUN mv config-dist.php config.php && \
    mv admin/config-dist.php admin/config.php && \
    chmod 777 config.php && \
    chmod 777 admin/config.php


# Set permissions for storage and image directories
RUN chmod 777 storage/ \
    && chmod 777 image/ \
    && chmod 777 image/cache/ \
    && chmod 777 image/catalog/ \
    && chmod 777 system/ \
    && chmod 777 system/storage/

# Expose port 80 for Apache
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]