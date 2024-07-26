#!/bin/bash

cd /home/secuenciacion_cenasa/Analisis_corridas

Trimmomatic="java -jar /home/secuenciacion_cenasa/Programas_Bioinformaticos/Trimmomatic/Trimmomatic-0.39/trimmomatic-0.39.jar"

for r1 in *_R1*.fastq.gz; do
r2=${r1/_R1/_R2}
name=$(basename $r1 | cut -d "_" -f "1")
$Trimmomatic PE -phred33 $r1 $r2 \
/home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Trimmomatic/${name}_1P.trim.fastq.gz /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Trimmomatic/U1U2/${name}_1U.trim.fastq.gz \
/home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Trimmomatic/${name}_2P.trim.fastq.gz /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Trimmomatic/U1U2/${name}_2U.trim.fastq.gz \
ILLUMINACLIP:${NexteraPE}:2:30:10 SLIDINGWINDOW:4:20 MINLEN:40
done

cd /home/secuenciacion_cenasa/Pruebas_rabia_2024/Archivos_trimming/Trimmomatic

echo ============= Estadísticos de lecturas de archivos fastQ postrimming de Trimmomatic ================
echo                         ===== Inicio: $(date) =====

fastqc *.gz -o /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Trimmomatic #Ejecutar fastQC sobre lecturas fastqc.gz

echo ===== Fin: $(date)=====
