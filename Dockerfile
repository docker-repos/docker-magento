FROM quay.io/alexcheng1982/apache2-php7:7.1.24

ENV MAGENTO_VERSION 1.9.3.8

RUN a2enmod rewrite

ENV INSTALL_DIR /var/www/html

RUN chsh -s /bin/bash www-data
RUN echo "www-data:password" | chpasswd
RUN chown -R www-data:www-data $INSTALL_DIR

RUN mkdir -p /home/www-data/.ssh && chown -R www-data:www-data /home/www-data
RUN su www-data -c "touch /home/www-data/.ssh/authorized_keys && chmod 0644 /home/www-data/.ssh/authorized_keys"

RUN su www-data -c "cd /tmp && \
    curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && \
    tar xvf $MAGENTO_VERSION.tar.gz && \
    mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess $INSTALL_DIR"

# RUN chown -R www-data:www-data $INSTALL_DIR # take too long
RUN chown -R 777 $INSTALL_DIR/media $INSTALL_DIR/var

RUN apt-get update && \
    apt-get install -y mysql-client-5.7 libxml2-dev libmcrypt4 libmcrypt-dev libpng-dev libjpeg-dev libfreetype6 libfreetype6-dev
RUN docker-php-ext-install soap
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib/ --with-freetype-dir=/usr/lib/ && \
    docker-php-ext-install gd

RUN pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug
RUN echo "\nxdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

COPY ./bin/install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

COPY ./sampledata/magento-sample-data-1.9.1.0.tgz /opt/
COPY ./bin/install-sampledata-1.9 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

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

# docker build -t fgct/magento:php7.1 . -f ./Dockerfile
# docker run -it --name=fgc_magento fgct/magento:php7.1 /bin/bash