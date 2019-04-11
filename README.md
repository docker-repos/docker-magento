# Docker image for web development

[![](https://images.microbadger.com/badges/image/alexcheng/magento.svg)](http://microbadger.com/images/alexcheng/magento)

[![Docker build](http://dockeri.co/image/alexcheng/magento)](https://hub.docker.com/r/alexcheng/magento/)

This repo creates a Docker image for web development with php7.1

## How to use

### Use as standalone container

You can use `docker run` to run this image directly.

```bash
docker run -p 80:80 fgct/php:7.1
```

Then finish Magento installation using web UI. You need to have an existing MySQL server.

Magento is installed into `/var/www/html` folder.
