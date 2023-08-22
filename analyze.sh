#!/usr/bin/env bash

set -eux
cd `dirname $0`

################################################################################
echo "# Analyze"
################################################################################

# read env
# 計測用自作env
. /tmp/prepared_env

# isucon serviceで使うenv
. /home/isucon/torb/webapp/env.sh

result_dir=$HOME/result
mkdir -p ${result_dir}

# journal log
sudo journalctl --since="${prepared_time}" > "${app_journal_log}"
sudo journalctl --since="${prepared_time}" > "${nginx_journal_log}"

# alp
# ALPM="/int/\d+,/uuid/[A-Za-z0-9_]+,/6digits/[a-z0-9]{6}"
#ALPM="/@.+,/posts/\d+,/image/\d+.(jpg|png|gif),/posts?max_created_at.*$"
#ALPM="/api/courses/[a-zA-Z0-9]+$,/api/courses/[a-zA-Z0-9]+/status,/api/courses/[a-zA-Z0-9]+/classes,/api/courses/[a-zA-Z0-9]+/classes/[a-zA-Z0-9]+/assignments,/api/courses/[a-zA-Z0-9]+/classes/[a-zA-Z0-9]+/assignments/scores,/api/courses/[a-zA-Z0-9]+/classes/[a-zA-Z0-9]+/assignments/export,/api/announcements/[a-zA-Z0-9]+$"
ALPM="/admin/api/reports/events/\d+/sales,/admin/api/events/\d+/actions/edit,/admin/api/events/\d+,/api/events/\d+/sheets/[^/].+[^/]/[^/].+[^/]/reservation,/api/events/[^/].+[^/]/actions/reserve,/api/events/[^/].+[^/],/api/users/[^/].+[^/],"

OUTFORMT=count,1xx,2xx,3xx,4xx,5xx,method,uri,min,max,sum,avg,p95,min_body,max_body,avg_body
touch ${result_dir}/alp.md
cp ${result_dir}/alp.md ${result_dir}/alp.md.prev
alp json --file=${nginx_access_log} \
  --nosave-pos \
  --sort sum \
  --reverse \
  --output ${OUTFORMT} \
  --format markdown \
  --matching-groups ${ALPM}  \
  > ${result_dir}/alp.md
  
OUTFORMT=count,uri_method_status,min,max,sum,avg,p95,trace_id_sample
touch ${result_dir}/alp_trace.md
cp ${result_dir}/alp_trace.md ${result_dir}/alp_trace.md.prev
alp-trace json --file=${nginx_access_log} \
  --nosave-pos \
  --sort sum \
  --reverse \
  --output ${OUTFORMT} \
  --format markdown \
  --matching-groups ${ALPM}  \
  --trace \
  > ${result_dir}/alp_trace.md


# mysqlowquery
# sudo mysqldumpslow -s t ${mysql_slow_log} > ${result_dir}/mysqld-slow.txt

# touch ${result_dir}/pt-query-digest.txt
# cp ${result_dir}/pt-query-digest.txt ${result_dir}/pt-query-digest.txt.prev
# pt-query-digest --explain "h=${DB_HOST},u=${DB_USER},p=${DB_PASS},D=${DB_DATABASE}" ${mysql_slow_log} \
#   > ${result_dir}/pt-query-digest.txt
# pt-query-digest ${mysql_slow_log} > ${result_dir}/pt-query-digest.txt
