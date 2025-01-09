#!/bin/bash

cd /home/secuenciacion_cenasa/MBovis_seq

for R1 in *_R1_*fastq.gz; do
    R2=${R1/_R1_/_R2_}
    ID=$(basename ${R1} | cut -d '_' -f '1')

spoligotyper.py -r1 ${R1} -r2 ${R2} -m 5 -o /home/secuenciacion_cenasa/MBovis_seq/Spoligotyper

done

cd /home/secuenciacion_cenasa/MBovis_seq/Spoligotyper

cat ./*.txt >> ./Spoligotyper_prediction.tsv

rm /home/secuenciacion_cenasa/MBovis_seq/Spoligotyper/*.txt
