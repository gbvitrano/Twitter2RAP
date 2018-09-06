#!/bin/bash

set -x

cartella="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# leggo la data di oggi
oggi=$(echo $(date +'%d %m %Y') | sed 's/ /%2F/g')
# Prima scarico i dati
# le segnalazioni aperte
curl -sL 'http://www.rapspaservizi.it/develop1/bastaundito/bastaundito_dev/mappa' -H 'Connection: keep-alive' \
-H 'Cache-Control: max-age=0' -H 'Origin: http://www.rapspaservizi.it' -H 'Upgrade-Insecure-Requests: 1' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.40 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
-H 'Referer: http://www.rapspaservizi.it/develop1/bastaundito/bastaundito_dev/mappa' -H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7' \
--data 'giorno_dal=01%2F01%2F2018&giorno_al='"$oggi"'&attivita_id=31&circoscrizione_id=T&stato=A' >"$cartella"/aperte
# le segnalazioni aperte
curl -sL 'http://www.rapspaservizi.it/develop1/bastaundito/bastaundito_dev/mappa' -H 'Connection: keep-alive' \
-H 'Cache-Control: max-age=0' -H 'Origin: http://www.rapspaservizi.it' -H 'Upgrade-Insecure-Requests: 1' \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.40 Safari/537.36' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
-H 'Referer: http://www.rapspaservizi.it/develop1/bastaundito/bastaundito_dev/mappa' -H 'Accept-Encoding: gzip, deflate' \
-H 'Accept-Language: it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7' \
--data 'giorno_dal=01%2F01%2F2018&giorno_al='"$oggi"'&attivita_id=31&circoscrizione_id=T&stato=C' >"$cartella"/chiuse


# Le info anagrafiche su ogni "pallino" (le coordinate sono in un blocco diverso da quello anagrafico)
## creo riga di intestazione
echo "data,indirizzo,foto,stato" >"$cartella"/dati.csv
## estraggo info su segnalazioni aperte
<"$cartella"/aperte grep -P 'marker_[0-9]+.set.*' | \
perl -pe  's|(marker_)([0-9]+)(.*?)(<h[0-9]>)(.*?)(<.h[0-9]>)(<p>)(.*?)(<.p>)(.*?)(src=.")(.*?)(.")(.*)$|$5#$8#$12|g' | \
grep -v 'marker' | csvformat -d "#" | sed -e 's/$/,aperta/g' | sed -r 's/^\s+//' >>"$cartella"/dati.csv
## estraggo info su segnalazioni aperte chiuse
<"$cartella"/chiuse grep -P 'marker_[0-9]+.set.*' | \
perl -pe  's|(marker_)([0-9]+)(.*?)(<h[0-9]>)(.*?)(<.h[0-9]>)(<p>)(.*?)(<.p>)(.*?)(src=.")(.*?)(.")(.*)$|$5#$8#$12|g' | \
grep -v 'marker' | csvformat -d "#" | sed -e 's/$/,chiusa/g' | sed -r 's/^\s+//' >>"$cartella"/dati.csv

## info sulle coordinate
echo "latitude,longitude" >"$cartella"/coords.txt
<"$cartella"/aperte grep -P 'google.maps.LatLng' | tail -n +3 | sed -r 's/^\s+//g' | perl -pe  's/^(.+?\()(.+?)(.;)/$2/g' >>"$cartella"/coords.txt
<"$cartella"/chiuse grep -P 'google.maps.LatLng' | tail -n +3 | sed -r 's/^\s+//g' | perl -pe  's/^(.+?\()(.+?)(.;)/$2/g' >>"$cartella"/coords.txt
# metto insieme le info anagrafiche con quelle spaziali
paste -d , dati.csv "$cartella"/coords.txt >"$cartella"/output.csv


# rimuovo i record che hanno 0 come coordinate e creo geojson
<"$cartella"/output.csv csvgrep -c "latitude,longitude" -r '^.{0,1}0.{0,1}$' -i | csvjson --lat latitude --lon longitude >"$cartella"/output.geojson

mv "$cartella"/output.csv "$cartella"/segnalazioniAppRAP.csv

# aggiungi un colonna con la data formattata in modo standard
mlr -I --csv put '$datetime = strftime(strptime($data, "%d/%m/%Y %H:%M:%S"),"%Y-%m-%dT%H:%M:%SZ")' "$cartella"/segnalazioniAppRAP.csv

# faccio l'upload su data.world (leggo la API KEY da config.txt)
source "$cartella"/config.txt
curl "https://api.data.world/v0/uploads/opendatasicilia/tw2rap/files" -F file=@"$cartella"/segnalazioniAppRAP.csv -H "Authorization: Bearer ${DW_API_TOKEN}"
