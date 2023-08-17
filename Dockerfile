FROM ubuntu:20.04

# install necessary packages
RUN  apt-get update \
    && apt-get install --no-install-recommends -y curl ca-certificates gnupg software-properties-common unzip


# install pinpoint agent
ARG PINPOINT_VERSION
ARG COLLECTOR_IP
ARG ETC_MONITORING
ARG HOOK_METHOD

ENV PINPOINT_VERSION=${PINPOINT_VERSION}
ENV COLLECTOR_IP=${COLLECTOR_IP}
ENV WHATAP_LICENSE=${WHATAP_LICENSE}
ENV WHATAP_URL=${WHATAP_URL}
ENV ETC_MONITORING=${ETC_MONITORING}
ENV HOOK_METHOD=${HOOK_METHOD}
ENV WHATAP_INSTALL_URL=https://service.whatap.io/agent/whatap.agent.java.tar.gz


ENV INSTALL_URL=https://github.com/naver/pinpoint/releases/download/v${PINPOINT_VERSION}/pinpoint-agent-${PINPOINT_VERSION}.tar.gz
ENV SPRING_PROFILES=release
ENV PROFILER_TRANSPORT_MODULE=GRPC
ENV PROFILER_TRANSPORT_AGENT_COLLECTOR_PORT=9991
ENV PROFILER_TRANSPORT_METADATA_COLLECTOR_PORT=9991
ENV PROFILER_TRANSPORT_STAT_COLLECTOR_PORT=9992
ENV PROFILER_TRANSPORT_SPAN_COLLECTOR_PORT=9993
ENV COLLECTOR_TCP_PORT=9994
ENV COLLECTOR_STAT_PORT=9995
ENV COLLECTOR_SPAN_PORT=9996
ENV PROFILER_SAMPLING_RATE=100
ENV AGENT_DEBUG_LEVEL=DEBUG

COPY /scripts/pinpoint-configure-agent.sh /usr/local/bin/

RUN mkdir -p /pinpoint-agent \
    && curl -SL ${INSTALL_URL} -o pinpoint-agent.tar.gz \
    && gunzip pinpoint-agent.tar.gz \
    && tar -xf pinpoint-agent.tar --strip 1 -C /pinpoint-agent \
    && ln -s /pinpoint-agent/pinpoint-bootstrap-${PINPOINT_VERSION}.jar /pinpoint-agent/pinpoint-bootstrap-current.jar \
    && rm pinpoint-agent.tar \
    && chmod a+x /usr/local/bin/pinpoint-configure-agent.sh \
    && /usr/local/bin/pinpoint-configure-agent.sh

#install whatap
RUN mkdir -p /whatap-agent

COPY /scripts/whatap-configure-agent.sh /usr/local/bin/
COPY /file/whatap.agent.java.tar.gz /whatap-agent/

RUN gunzip /whatap-agent/whatap.agent.java.tar.gz \
   && tar -xf /whatap-agent/whatap.agent.java.tar --strip 1 -C /whatap-agent \
   && chmod a+x /usr/local/bin/whatap-configure-agent.sh \
   && /usr/local/bin/whatap-configure-agent.sh

# install correto 15
RUN  curl -L https://apt.corretto.aws/corretto.key | apt-key add - \
    && add-apt-repository 'deb https://apt.corretto.aws stable main' \
    && apt-get update; apt-get install --no-install-recommends -y java-15-amazon-corretto-jdk

# change java config
ENV JAVA_HOME=/usr/lib/jvm/java-15-amazon-corretto
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


# install security agent
COPY /scripts/agent-install.sh /usr/local/bin/
COPY /scripts/agent-activate.sh /usr/local/bin/

RUN chmod a+x /usr/local/bin/agent-install.sh \
    && chmod a+x /usr/local/bin/agent-activate.sh \
    && /usr/local/bin/agent-install.sh \
    && rm /usr/local/bin/agent-install.sh

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
