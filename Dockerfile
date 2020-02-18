FROM php:7.2.11-fpm

MAINTAINER A. Gökay Duman <aligokayduman@gmail.com>

ENV NPS_VERSION 1.13.35.2
ENV NGINX_VERSION 1.16.1
ENV CPU_CORE x64

# General Commands
RUN apt update && apt upgrade -y 

# Php-Fpm
RUN apt install -y libcurl4-openssl-dev \
                   libfreetype6-dev \
                   libjpeg62-turbo-dev \
                   libpng-dev \
                   libgd-dev \
                   libmcrypt-dev \
                   libxml2-dev \
                   libxslt-dev \
                   libc-client-dev \
                   libkrb5-dev \
    && rm -r /var/lib/apt/lists/* \               
    && pecl install redis-5.0.2 \
    && pecl install xdebug-2.7.2 \
    && docker-php-ext-enable redis xdebug \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-install bcmath \
                              intl \
                              opcache \
                              mysqli \
                              pdo \
                              pdo_mysql \
                              curl \                           
                              mbstring \
                              hash \
                              simplexml \
                              soap \
                              xml \
                              xsl \
                              zip \
                              json
                              
# Install Nginx
RUN apt install -y nginx 
    
# Tools Install
RUN apt install -y nano htop iputils-ping
    
# Supervisord Install
RUN apt install -y supervisor \
    && mkdir -p /var/log/supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Cron Install
RUN apt install -y cron 
COPY ./jobs /etc/cron.d/jobs

# Composer Install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Entrypoint
CMD ["/usr/bin/supervisord"]
