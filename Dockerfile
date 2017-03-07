FROM shurshun/alpine-moscow

LABEL maintainer "4lifenet@gmail.com"

LABEL SERVICE_NAME="beanstalkd"

HEALTHCHECK --interval=30s --timeout=2s \
  CMD nc -zv localhost 11300 || exit 1

ENV VERSION_BEANSTALKD="1.10"

RUN addgroup -S beanstalkd && adduser -S -G beanstalkd beanstalkd

RUN apk --update add --virtual build-dependencies \
  gcc \
  make \
  musl-dev \
  curl \
  && curl -sL https://github.com/kr/beanstalkd/archive/v$VERSION_BEANSTALKD.tar.gz | tar xvz -C /tmp \
  && cd /tmp/beanstalkd-$VERSION_BEANSTALKD \
  && sed -i "s|#include <sys/fcntl.h>|#include <fcntl.h>|g" sd-daemon.c \
  && make \
  && cp beanstalkd /usr/bin \
  && apk del build-dependencies \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/apk/*

RUN mkdir /var/lib/beanstalkd && chown beanstalkd:beanstalkd /var/lib/beanstalkd

VOLUME ["/var/lib/beanstalkd"]

EXPOSE 11300

ENTRYPOINT ["beanstalkd", "-l", "0.0.0.0", "-p", "11300", "-u", "beanstalkd"]
CMD ["-b", "/var/lib/beanstalkd", "-f", "5000"]
