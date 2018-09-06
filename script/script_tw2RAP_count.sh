#!/bin/bash
set -x

# source URL csv: https://query.data.world/s/c2a64w2ce4pgyzy6xrfgpneiz3vi4k
ogr2ogr -f CSV tagsOutCount.CSV -dialect sqlite quartieri_pa_4326.sqlite \
-sql "SELECT date('now')as data,QUA_ID, count(*) as nro FROM tags t, quartieri q WHERE st_contains (q.geometry,t.geometry) GROUP BY 2";

