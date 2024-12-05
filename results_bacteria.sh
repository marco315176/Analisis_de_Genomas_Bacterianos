#!/bin/bash

echo -e "################################################################################################################" "\n"

echo -e Moviendo todos los archivos de resultados obtenidos a: /home/admcenasa/Analisis_corridas/Resultados_all_bacteria "\n"

echo -e "################################################################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/Resultados_all_bacteria

mkdir -p FastQC
mkdir -p FastQC/Lecturas
mkdir -p FastQC/Lecturas_pt
mkdir -p FastQC/Lecturas/multiQC
mkdir -p FastQC/Lecturas_pt/multiQC
#Mover los archivos generados por FastQC a la carpeta FastQC
mv /home/admcenasa/Analisis_corridas/fastQC/bacteria/*fastqc* ./FastQC/Lecturas
mv /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria/*fastqc* ./FastQC/Lecturas_pt
rm -R /home/admcenasa/Analisis_corridas/fastQC/bacteria/multiqc/multiqc_data
mv /home/admcenasa/Analisis_corridas/fastQC/bacteria/multiqc/*multiqc* ./FastQC/Lecturas/multiQC
mv /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria/multiqc/postrimm_multiqc* ./FastQC/Lecturas_pt/multiQC
rm -R /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria/multiqc/multiqc_data

#mkdir -p Archivos_trimming
#Mover los archivos limpios (trimming) a la carpeta Archivos_trimming
#mv /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias/*_trim* ./Archivos_trimming

#mkdir -p Ensambles
#Mover todos los ensambles a la carpeta Ensambles
#mv /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/*SPAdes* ./Ensambles

mkdir -p KRAKEN2
#Mover los archivos obtenidos por KRAKEN2 a la carpeta KRAKEN2
mv /home/admcenasa/Analisis_corridas/kraken2/bacteria/*kraken* ./KRAKEN2

mkdir -p KmerFinder
#Mover los resultados obtenidos por KmerFinder a la carpeta KmerFinder
mv /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*results* ./KmerFinder

mkdir -p MLST
#Mover los resultados obtenidos por stringMLST a la carpeta MLST
#mv /home/admcenasa/Analisis_corridas/stringMLST/*MLST* ./MLST
mv /home/admcenasa/Analisis_corridas/MLST/MLST* ./MLST

mkdir -p SeqSero2
#Mover los resultados obtenidos por SeqSero2 a la carpeta nombrada igualmente
mv /home/admcenasa/Analisis_corridas/seqsero2/*SeqSero2* ./SeqSero2

mkdir -p SerotypeFinder
#Mover los resultados obtenidos por SF a la carpeta SerotypeFinder
mv /home/admcenasa/Analisis_corridas/serotypefinder/*results* ./SerotypeFinder

mkdir -p RAM
#Mover los resultados obtenidos por AMRFinderPlus a la carpeta RAM
mv /home/admcenasa/Analisis_corridas/AMRFinder/* ./RAM

mkdir -p Estadisticos
#Mover archivos con estadisticos
mv /home/admcenasa/Analisis_corridas/fastQC/bacteria/estadisticos/*stats* ./Estadisticos
mv /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria/estadisticos/*stats_pt* ./Estadisticos
mv /home/admcenasa/Analisis_corridas/SPAdes/bacteria/estadisticos/*global* ./Estadisticos 

mkdir -p Lecturas_crudas
mv /home/admcenasa/Analisis_corridas/Corrida_bacterias/*fastq.gz ./Lecturas_crudas

rm /home/admcenasa/Analisis_corridas/SPAdes/bacteria/*fa
rm -R /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria/*
