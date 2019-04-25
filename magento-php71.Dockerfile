FROM fgct/php:7.1

ENV MAGENTO_VERSION 1.9.3.8

RUN a2enmod rewrite
RUN a2enmod headers

ENV INSTALL_DIR /var/www/html

RUN apt-get update && \
    apt-get install -y libxslt-dev

RUN docker-php-ext-install soap
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath # M2
RUN docker-php-ext-install xsl # M2

RUN su www-data -c "cd /tmp && \
    curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && \
    tar xvf $MAGENTO_VERSION.tar.gz && \
    mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess $INSTALL_DIR"

# RUN chown -R www-data:www-data $INSTALL_DIR # take too long
RUN chown -R 777 $INSTALL_DIR/media $INSTALL_DIR/var

RUN echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/memory-limit.ini

COPY ./bin/install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

COPY ./sampledata/magento-sample-data-1.9.1.0.tgz /opt/
COPY ./bin/install-sampledata-1.9 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

#RUN bash -c 'bash < <(curl -s -L https://raw.github.com/colinmollenhour/modman/master/modman-installer)'
#RUN mv ~/bin/modman /usr/local/bin

#COPY redis.conf /var/www/htdocs/app/etc/

WORKDIR $INSTALL_DIR

EXPOSE 80 22

# docker build -t fgct/magento:php7.1 . -f ./magento-php71.Dockerfile
# docker push fgct/magento:php7.1
# docker run -it --name=fgc_magento fgct/magento:php7.1 /bin/bash