#!/usr/bin/env bash

typeset TOP_LINES=${1:-10}
typeset PID=${2:-$(pgrep -u $USER java | head -n1)}
typeset TMP_FILE=/tmp/java_${PID}_$$.trace

${JAVA_HOME}/bin/jstack ${PID} > ${TMP_FILE}

ps H -eo pid,tid,%cpu --sort=-%cpu --no-headers \
        | awk -v "PID=${PID}" '$1==PID {print $2"\t"$3}' \
        | head -n${TOP_LINES} \
        | while read line;
do
        typeset nid=$(echo "$line"|awk '{printf("0x%x",$1)}')
        typeset cpu=$(echo "$line"|awk '{print $2}')
        awk -v "cpu=${cpu}" '/nid='"${nid}"'/,/^$/{print $0"\t"(isF++?"":"cpu="cpu"%");}' ${TMP_FILE}
done

rm -f ${TMP_FILE}
