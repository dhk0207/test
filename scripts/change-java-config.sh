#!/bin/bash
sed -i "s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=0/g" $JAVA_HOME/conf/security/java.security
sed -i "s/networkaddress.cache.negative.ttl=10/networkaddress.cache.negative.ttl=0/g" $JAVA_HOME/conf/security/java.security
