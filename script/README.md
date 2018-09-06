# Intro

Ecco alcuni script usati in questo progetto.

## rap.sh

Uno script che recupera le segnalazioni inviate a RAP tramite l'app pubblicata dall'azienda. Nota bene: solo quelle a partire dal primo gennaio 2018.

I dati sono estratti da [questa pagina](http://www.rapspaservizi.it/develop1/bastaundito/bastaundito_dev/mappa) e aggiornati settimanalmente.

L'output grezzo dello script è qui [https://query.data.world/s/537rnrly6i5sl6p5itgzlpn4ohi3ul](https://query.data.world/s/537rnrly6i5sl6p5itgzlpn4ohi3ul)

## script_tw2RAP_count.sh

Uno script che calcola il numero di segnalazioni (app tw2RAP) per ogni quartieri di Palermo.

## script_appRAP.sh

Uno script che realizza vari file CSV a partire dai dati di output dello script rap.sh:

* appRAPvalid.CSV - ripulisce le segnalazioni non valide (geograficamente);
* appRAPvalidAperta - estrae tutte le segnalazioni con attributi _stato_ uguale a `aperta`
* appRAPvalidAperta - estrae tutte le segnalazioni con attributi _stato_ uguale a `chiusa`
* appRAPcount_quart - estrae il numero di segnalazioni per ogni quartieri di Palermo;
* appRAPcount_quart_normalizz - estrae il numero di segnalazioni per ogni quartieri di Palermo e li normalizza rispetto alla popolazione;
