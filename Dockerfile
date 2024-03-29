# Use an official PHP image as the base image
FROM php:7.4-apache as php7.4

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

# Configure vsftpd for anonymous read-only transfers in PASV mode
RUN mkdir /log && \
    sed \
      -e 's/anonymous_enable=NO/anonymous_enable=YES/' \
      -e 's/local_enable=YES/local_enable=NO/' \
      -e 's/#write_enable=YES/write_enable=YES/' \
      -e 's/#anon_upload_enable=YES/anon_upload_enable=YES/' \
      -e 's/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=YES/' \
      -e 's/#nopriv_user=ftpsecure/nopriv_user=ftp/' \
      -e 's@#xferlog_file=/var/log/vsftpd.log@xferlog_file=/log/xfer.log@' \
      -i /etc/vsftpd.conf && \
    echo >> /etc/vsftpd.conf && \
    echo "vsftpd_log_file=/log/vsftpd.log" >> /etc/vsftpd.conf && \
    echo "no_anon_password=YES" >> /etc/vsftpd.conf && \
    echo "pasv_enable=YES" >> /etc/vsftpd.conf && \
    echo "pasv_min_port=20000" >> /etc/vsftpd.conf && \
    echo "pasv_max_port=21000" >> /etc/vsftpd.conf




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
EXPOSE 80 21

# Start Apache in the foreground
CMD ["apache2-foreground"]
