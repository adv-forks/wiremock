FROM openjdk:8-jre

MAINTAINER Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>

ENV WIREMOCK_VERSION 2.24.1
ENV GOSU_VERSION 1.10

# grab gosu for easy step-down from root
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

WORKDIR /home/wiremock

COPY docker-entrypoint.sh /
COPY java8/build/libs/wiremock-jre8-standalone-$WIREMOCK_VERSION.jar /var/wiremock/lib/wiremock-standalone.jar

VOLUME /home/wiremock
EXPOSE 8080 8443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-cp", "/var/wiremock/lib/*:/var/wiremock/extensions/*", "com.github.tomakehurst.wiremock.standalone.WireMockServerRunner"]
