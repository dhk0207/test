FROM ubuntu:20.04

# install necessary packages
RUN  apt-get update \
    && apt-get install --no-install-recommends -y curl ca-certificates gnupg software-properties-common unzip


# install whatap agent
ARG WHATAP_LICENSE
ARG WHATAP_URL
ARG ETC_MONITORING

ENV WHATAP_LICENSE=${WHATAP_LICENSE}
ENV WHATAP_URL=${WHATAP_URL}
ENV ETC_MONITORING=${ETC_MONITORING}
ENV WHATAP_INSTALL_URL=https://service.whatap.io/agent/whatap.agent.java.tar.gz

COPY /scripts/whatap-configure-agent.sh /usr/local/bin/

# whatap agent
RUN mkdir -p /whatap-agent \
    && curl -SL ${WHATAP_INSTALL_URL} -o whatap.agent.java.tar.gz \
    && gunzip whatap.agent.java.tar.gz \
    && tar -xf whatap.agent.java.tar --strip 1 -C /whatap-agent \
    && chmod a+x /usr/local/bin/whatap-configure-agent.sh \
    && /usr/local/bin/whatap-configure-agent.sh


# install correto 17
RUN  curl -L https://apt.corretto.aws/corretto.key | apt-key add - \
    && add-apt-repository 'deb https://apt.corretto.aws stable main' \
    && apt-get update; apt-get install --no-install-recommends -y java-17-amazon-corretto-jdk

# change java config
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
COPY /scripts/change-java-config.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/change-java-config.sh \
    && /usr/local/bin/change-java-config.sh \
    && rm /usr/local/bin/change-java-config.sh

# install aws cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples

# locale configure
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && localedef -i ko_KR -c -f UTF-8 -A /usr/share/locale/locale.alias ko_KR.UTF-8 \
    && localedef -i ko_KR -c -f CP949 -A /usr/share/locale/locale.alias ko_KR.CP949 \
    && localedef -i ko_KR -c -f EUC-KR -A /usr/share/locale/locale.alias ko_KR.EUCKR

ENV LANGUAGE ko_KR.UTF-8
ENV LANG ko_KR.UTF-8


# timezone configure
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

RUN apt-get install --no-install-recommends -y tzdata

# reconfigure dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# clean up
RUN apt purge -y software-properties-common \
    && rm -rf /var/lib/apt/lists/* 
