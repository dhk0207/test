#!/bin/bash

PINPOINT_VERSION=2.4.2
COLLECTOR_IP='${pinpoint_collector_ip}'
WHATAP_LICENSE='${whatap_license}'
ETC_MONITORING='${etc_monitoring}'
WHATAP_URL='${whatap_url}'
HOOK_METHOD='${hook_method}'

ECR_LOGIN_PROFILE=
ECR_URI=185236431346.dkr.ecr.ap-northeast-2.amazonaws.com
IMAGE_NAME=szs-code-build-dev
IMAGE_TAG=jdk-ubuntu-15-with-whatap

if [ -z $ECR_LOGIN_PROFILE ]
then
    aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_URI
else
    aws ecr get-login-password --region ap-northeast-2 --profile $ECR_LOGIN_PROFILE | docker login --username AWS --password-stdin $ECR_URI
fi

docker build --no-cache \
    --platform=linux/amd64 \
    --build-arg PINPOINT_VERSION=$PINPOINT_VERSION \
    --build-arg COLLECTOR_IP=$COLLECTOR_IP \
    --build-arg WHATAP_LICENSE=$WHATAP_LICENSE \
    --build-arg ETC_MONITORING=$ETC_MONITORING \
    --build-arg SLOW_TIME=$SLOW_TIME \
    --build-arg IGNORE_EXCEPTION=$IGNORE_EXCEPTION \
    --build-arg IGNORE_STATUS=$IGNORE_STATUS \
    --build-arg IGNORE_HTTP_STATUS=$IGNORE_HTTP_STATUS \
    --build-arg IGNORE_BUSNISS=$IGNORE_BUSNISS \
    --build-arg IGNORE_TRACE=$IGNORE_TRACE \
    --build-arg IGNORE_TRACE_PREFIX=$IGNORE_TRACE_PREFIX \
    --build-arg HOOK_METHOD=$HOOK_METHOD \
    -t $ECR_URI/$IMAGE_NAME:$IMAGE_TAG .

docker push $ECR_URI/$IMAGE_NAME:$IMAGE_TAG
