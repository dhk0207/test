#!/bin/bash
ACTIVATIONURL='dsm://agents.workload.jp-1.cloudone.trendmicro.com:443/'

/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a $ACTIVATIONURL "tenantID:449388A1-3BD7-96F0-885A-C8E6EDCDC48E" "token:8A0E4DCD-95CF-4A15-8693-D4377DDE7EF7"