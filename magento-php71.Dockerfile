FROM fgct/php:7.1

ENV MAGENTO_VERSION 1.9.3.8

RUN a2enmod rewrite
RUN a2enmod headers

ENV INSTALL_DIR /var/www/html

RUN su www-data -c "cd /tmp && \
    curl https://codeload.github.com/OpenMage/magento-mirror/tar.gz/$MAGENTO_VERSION -o $MAGENTO_VERSION.tar.gz && \
    tar xvf $MAGENTO_VERSION.tar.gz && \
    mv magento-mirror-$MAGENTO_VERSION/* magento-mirror-$MAGENTO_VERSION/.htaccess $INSTALL_DIR"

# RUN chown -R www-data:www-data $INSTALL_DIR # take too long
RUN chown -R 777 $INSTALL_DIR/media $INSTALL_DIR/var

RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

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

#COPY docker-entrypoint.sh /
#RUN chmod +x /docker-entrypoint.sh
#ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["init"]

# docker build -t fgct/magento:php7.1 . -f ./magento-php71.Dockerfile
# docker run -it --name=fgc_magento fgct/magento:php7.1 /bin/bash