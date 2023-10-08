# Use an official Ubuntu runtime as a parent image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages
#php 7.4 
RUN apt-get update && \
    apt-get install -y apache2 \
                       mysql-server \
                       php7.4 \
                       libapache2-mod-php7.4 \
                       php7.4-mysql \
                       php7.4-cli \
                       php7.4-gd \
                       php7.4-curl \
                       php7.4-zip \
                       unzip \
                       wget

# Download and extract OpenCart
WORKDIR /var/www/html
RUN wget -O opencart.zip https://github.com/opencart/opencart/archive/3.0.3.8.zip && \
    unzip opencart.zip && \
    mv opencart-3.0.3.8 upload && \
    rm opencart.zip

# copy files  from /var/www/html/upload to /var/www/html
RUN cp -r /var/www/html/upload/* /var/www/html && \
    rm -rf /var/www/html/upload
# Set file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# rename config-dist.php to config.php and admin/config-dist.php to admin/config.php
RUN mv /var/www/html/config-dist.php /var/www/html/config.php && \
    mv /var/www/html/admin/config-dist.php /var/www/html/admin/config.php

# rename .htaccess.txt to .htaccess
RUN mv /var/www/html/.htaccess.txt /var/www/html/.htaccess


# Configure Apache
RUN a2enmod rewrite
COPY opencart.conf /etc/apache2/sites-available/opencart.conf
RUN a2ensite opencart.conf

# Expose ports
EXPOSE 80

# Start services
CMD service apache2 start && \
    tail -f /dev/null
