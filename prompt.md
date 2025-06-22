Devo realizzare una app nominata "ProLoco Piazzola" per Android che abbia il seguente workflow:

1. se vuole, l'utente configura il percorso di salvataggio per il file: di default è la cartella predefinita Downloads
   se vuole, l'utente configura il nome predefinito del file: di default è proloco.csv

1. l'app verifica se il file esiste nel percorso predefinito:
    se non esiste, apre il file picker
    se esiste, carica il file

1. l'app carica il file che consiste in un elenco di righe con i seguenti campi:
booth, espositore1, espositore2, flag check (predefinito false)

1. l'utente visualizza l'elenco

1. l'utente sceglie la riga

1. l'utente imposta il flag check a true o false

1. l'utente riscrive l'espositore 2 (se necessario)

1. l'utente salva

1. l'app memorizza le informazioni nel file in locale


L'elenco del punto 2 deve avere le seguenti caratteristiche:
- ricercabile per booth, espositore 1, espositore 2
- ordinabile per booth, espositore 1, espositore 2

Il file potrebbe essere JSON o TXT/CSV