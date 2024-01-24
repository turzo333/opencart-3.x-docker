# Use an official PHP image as the base image
FROM php:7.4-apache as php7.4
ARG USER_ID=14
ARG GROUP_ID=50
# Set environment variables for MySQL
RUN apt-get update
# Install required PHP extensions
# Database	On	On	
# GD	Off	On	
# cURL	On	On	
# OpenSSL	On	On	
# ZLIB	On	On	
# ZIP
RUN apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libcurl4-openssl-dev libssl-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql gd curl zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends vsftpd && \
    apt-get install -y zlib1g-dev libpng-dev libjpeg-dev

RUN usermod -u ${USER_ID} ftp
RUN groupmod -g ${GROUP_ID} ftp

ENV FTP_USER micro
ENV FTP_PASS micro
ENV PASV_ADDRESS 45.77.33.213
ENV PASV_ADDR_RESOLVE NO
ENV PASV_ENABLE YES
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV XFERLOG_STD_FORMAT NO
ENV LOG_STDOUT **Boolean**
ENV FILE_OPEN_MODE 0666
ENV LOCAL_UMASK 077
ENV REVERSE_LOOKUP_ENABLE YES
ENV PASV_PROMISCUOUS NO
ENV PORT_PROMISCUOUS NO
COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh
RUN mkdir -p /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install gd

# Enable Apache modules
RUN a2enmod rewrite

COPY app.sh dockerwait.static /var/www

# Set the working directory to /var/www/html
WORKDIR /var/www/html
# add user
RUN usermod -aG www-data www-data

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html


# Download and extract OpenCart

#https://github.com/opencart/opencart/releases/download/3.0.3.8/opencart-3.0.3.8.zip
# download opencart and unzip and move to /var/www/html
#install wget
RUN apt-get install -y wget
RUN apt-get install -y zip
#download opencart with wget

# RUN wget https://github.com/opencart/opencart/releases/download/3.0.3.8/opencart-3.0.3.8.zip
# #unzip opencart


# RUN unzip opencart-3.0.3.8.zip
# RUN mv upload/* ./
# RUN rm -rf upload
# RUN rm opencart-3.0.3.8.zip

# # fix permission
# RUN chown -R www-data:www-data /var/www/html
# RUN chmod -R 755 /var/www/html
#  #rename config-dist.php to config.php
# RUN mv config-dist.php config.php
# #rename admin/config-dist.php to admin/config.php
# RUN mv admin/config-dist.php admin/config.php





# Expose port 80 for Apache
EXPOSE 80 20 21

# Start Apache in the foreground
CMD ["apache2-foreground"]