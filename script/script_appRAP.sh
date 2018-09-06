#!/bin/bash
set -x

# source URL csv: https://query.data.world/s/c2zvqyw4d7yrzq3fswaka4t6cktc2q
ogr2ogr -f CSV appRAPvalid.CSV -dialect sqlite db_appRAP.sqlite \
-sql "SELECT g.* FROM (SELECT t.*, MakePoint (CAST (longitude AS float),CAST (latitude AS float)) as geometry FROM segnalazioniAppRAP t) g, (select st_union(q.geometry)as geom from quartieri q group by fid/fid) k WHERE st_contains (k.geom,g.geometry)";

# source URL csv: https://query.data.world/s/c2zvqyw4d7yrzq3fswaka4t6cktc2q
ogr2ogr -f CSV appRAPvalidAperta.CSV -dialect sqlite db_appRAP.sqlite \
-sql "SELECT g.* FROM (SELECT t.*, MakePoint (CAST (longitude AS float),CAST (latitude AS float)) as geometry FROM segnalazioniAppRAP t) g, (select st_union(q.geometry)as geom from quartieri q group by fid/fid) k WHERE st_contains (k.geom,g.geometry) AND stato = 'aperta'";

# source URL csv: https://query.data.world/s/c2zvqyw4d7yrzq3fswaka4t6cktc2q
ogr2ogr -f CSV appRAPvalidChiusa.CSV -dialect sqlite db_appRAP.sqlite \
-sql "SELECT g.* FROM (SELECT t.*, MakePoint (CAST (longitude AS float),CAST (latitude AS float)) as geometry FROM segnalazioniAppRAP t) g, (select st_union(q.geometry)as geom from quartieri q group by fid/fid) k WHERE st_contains (k.geom,g.geometry) AND stato = 'chiusa'";

# source URL csv: https://query.data.world/s/c2zvqyw4d7yrzq3fswaka4t6cktc2q
ogr2ogr -f CSV appRAPcount_quart.CSV -dialect sqlite db_appRAP.sqlite \
-sql "SELECT date('now')as data,denominazi, count(*) as nro FROM (SELECT t.*, MakePoint (CAST (longitude AS float),CAST (latitude AS float)) as geometry FROM segnalazioniAppRAP t) g, quartieri q WHERE st_contains (q.geometry,g.geometry) GROUP BY 2 ORDER BY nro DESC";

# source URL csv: https://query.data.world/s/c2zvqyw4d7yrzq3fswaka4t6cktc2q
ogr2ogr -f CSV appRAPcount_quart_normalizz.CSV -dialect sqlite db_appRAP.sqlite \
-sql "SELECT v.data,v.quartiere,v.nro, CAST (CAST (v.nro as FLOAT)/(CAST (p.F as FLOAT)+CAST (p.M as FLOAT)) AS FLOAT)*100 as percent FROM (SELECT date('now')as data,denominazi AS quartiere, count(*) as nro FROM (SELECT t.*, MakePoint (CAST (longitude AS float),CAST (latitude AS float)) as geometry FROM segnalazioniAppRAP t) g, quartieri q WHERE st_contains (q.geometry,g.geometry) GROUP BY 2 ) v JOIN "popMF_quart_2014" p using (quartiere) order by norma desc";
