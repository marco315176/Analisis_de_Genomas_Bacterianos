#!/bin/bash

echo -e "#####################################################################"

echo -e Moviendo todos los archivos de resultados obtenidos a una sola carpeta

echo -e "#####################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_all_bacteria

mkdir -p FastQC
mkdir -p FastQC/Lecturas
mkdir -p FastQC/Lecturas_pt
mkdir -p FastQC/Lecturas/multiQC
mkdir -p FastQC/Lecturas_pt/multiQC
#Mover los archivos generados por FastQC a la carpeta FastQC
mv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/*fastqc* ./FastQC/Lecturas
rm -R /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/*fastqc*
mv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias/*fastqc* ./FastQC/Lecturas_pt
rm -R /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias/*fastqc*
rm -R /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/multiqc/multiqc_data
mv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/multiqc/*multiqc* ./FastQC/Lecturas/multiQC
rm -R /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias/multiqc/multiqc_data

mkdir -p Archivos_trimming
#Mover los archivos limpios (trimming) a la carpeta Archivos_trimming
mv /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias/*_trim* ./Archivos_trimming

mkdir -p Ensambles
#Mover todos los ensambles a la carpeta Ensambles
mv /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/*SPAdes* ./Ensambles

#mkdir -p KRAKEN2
#Mover los archivos obtenidos por KRAKEN2 a la carpeta KRAKEN2
#mv /home/secuenciacion_cenasa/Analisis_corridas/kraken2/virus/*kraken* ./KRAKEN2

mkdir -p KmerFinder
#Mover los resultados obtenidos por KmerFinder a la carpeta KmerFinder
mv /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*results* ./KmerFinder

mkdir -p MLST
#Mover los resultados obtenidos por stringMLST a la carpeta MLST
mv /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/*MLST* ./MLST

mkdir -p SeqSero2
#Mover los resultados obtenidos por SeqSero2 a la carpeta nombrada igualmente
mv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/*SeqSero2* ./SeqSero2

mkdir -p SerotypeFinder
#Mover los resultados obtenidos por SF a la carpeta SerotypeFinder
mv /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/*results* ./SerotypeFinder

mkdir -p RAM
#Mover los resultados obtenidos por AMRFinderPlus a la carpeta RAM
mv /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/*AMRF* ./RAM
mv /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/Nucleotide ./RAM

mkdir -p Estadisticos
#Mover archivos con estadisticos
mv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/estadisticos/*stats* ./Estadisticos
mv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias/estadisticos/*stats_pt* ./Estadisticos
mv /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/estadisticos/*global* ./Estadisticos 
