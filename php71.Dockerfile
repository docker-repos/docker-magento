FROM quay.io/alexcheng1982/apache2-php7:7.1.24

ENV PHP_VERSION 7.1.24

RUN a2enmod rewrite

ENV INSTALL_DIR /var/www/html

RUN usermod -aG sudo www-data
RUN chsh -s /bin/bash www-data
RUN echo "www-data:password" | chpasswd

COPY src/phpinfo.php $INSTALL_DIR/index.php
COPY src/phpinfo.php $INSTALL_DIR/info.php

RUN chown -R www-data:www-data $INSTALL_DIR

RUN mkdir -p /root/.ssh
RUN mkdir -p /home/www-data/.ssh && chown -R www-data:www-data /home/www-data

COPY private.pem.pub /private.pem.pub
RUN cat /private.pem.pub >> /root/.ssh/authorized_keys
RUN cat /private.pem.pub >> /home/www-data/.ssh/authorized_keys
RUN chown www-data:www-data /home/www-data/.ssh/authorized_keys

RUN apt-get update && \
    apt-get install -y sudo mysql-client-5.7 libxml2-dev libmcrypt4 libmcrypt-dev libpng-dev libjpeg-dev libfreetype6 libfreetype6-dev

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib/ --with-freetype-dir=/usr/lib/ && \
    docker-php-ext-install gd

RUN pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug
RUN echo "\nxdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "max_execution_time=120\nmemory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN bash -c 'bash < <(curl -s -L https://raw.github.com/colinmollenhour/modman/master/modman-installer)'
RUN mv ~/bin/modman /usr/local/bin

#COPY redis.conf /var/www/htdocs/app/etc/

WORKDIR $INSTALL_DIR

EXPOSE 80 22

RUN rm -rf /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["init"]

# docker build -t fgct/php:7.1 . -f ./php71.Dockerfile
# docker push fgct/php:7.1
# docker run -it --rm --name=fgc_php71 fgct/php:7.1 /bin/bash
# docker run -it --rm --name=fgc_php71 -p 32222:22 fgct/php:7.1 /bin/bash
# ssh root@localhost -p 32222 -i private.pem
