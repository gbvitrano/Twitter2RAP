#!/bin/bash
set -x

ogr2ogr -f CSV tagsOutCount.CSV -dialect sqlite quartieri_pa_4326.sqlite -sql "SELECT date('now')as data,QUA_ID, count(*) as nro FROM tags t, quartieri q WHERE st_contains (q.geometry,t.geometry) GROUP BY 2";

