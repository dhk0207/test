#!/bin/bash
set -e
set -x

#고정값
#profile , trace는 이름만 다를뿐 동일옵션
echo "logsink_enabled=true" >> /whatap-agent/whatap.conf
echo "logsink_trace_enabled=true" >> /whatap-agent/whatap.conf
echo "profile_basetime=0" >> /whatap-agent/whatap.conf
echo "hook_method_access_private_enabled=true" >> /whatap-agent/whatap.conf
echo "trace_auto_transaction_enabled=true" >> /whatap-agent/whatap.conf
echo "trace_auto_transaction_backstack_enabled=true" >> /whatap-agent/whatap.conf
echo "tx_caller_meter_enabled=true" >> /whatap-agent/whatap.conf
echo "sql_dbc_meter_enabled=true" >> /whatap-agent/whatap.conf
echo "httpc_host_meter_enabled=true" >> /whatap-agent/whatap.conf
echo "actx_meter_enabled=true" >> /whatap-agent/whatap.conf
echo "profile_sql_param_enabled=true" >> /whatap-agent/whatap.conf
echo "hook_method_patterns=co.jobis.*.*" >> /whatap-agent/whatap.conf
echo "aws_ecs_enabled=true" >> /whatap-agent/whatap.conf
echo "aws_ecs_metadata_uri_recent_enabled=true" >> /whatap-agent/whatap.conf
echo "profile_error_httpc_time_max=60000" >> /whatap-agent/whatap.conf
echo "trace_kafka_header_enabled=true" >> /whatap-agent/whatap.conf
echo "trace_http_header_enabled=true" >> /whatap-agent/whatap.conf
echo "license=x2lgglr2mvaqk-x4oiapshp72lmf-z4ps9feelpbim6" >> /whatap-agent/whatap.conf
echo "whatap.server.host=10.0.100.231" >> /whatap-agent/whatap.conf
echo "SZSKEY" >> /whatap-agent/paramkey.txt

exec "$@"