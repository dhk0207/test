#!/bin/bash
set -e
set -x

echo "weaving=" >> /whatap-agent/whatap.conf
echo "hooklog_enabled=true" >> /whatap-agent/whatap.conf
echo "logsink_enabled=true" >> /whatap-agent/whatap.conf
echo "logsink_trace_enabled=true" >> /whatap-agent/whatap.conf

sed -i "/license=/ s/=.*/=${WHATAP_LICENSE}/" /whatap-agent/whatap.conf
sed -i "/whatap.server.host=/ s/=.*/=${WHATAP_URL}/" /whatap-agent/whatap.conf
sed -i "/weaving=/ s/=.*/=${ETC_MONITORING}/" /whatap-agent/whatap.conf


exec "$@"
