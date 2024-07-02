#!/bin/bash

echo -e "###################################################################################################"

echo -e ===== Ejecutar kraken2 sobre lecturas posttrimming para identificación taxonómica de bacterias =====

echo -e                              ===== Inicio: $(date) =====

echo -e "###################################################################################################"


cd /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias

for R1 in *_R1_*; do
    R2=${R1/_R1_/_R2_}
    ID="$(basename ${R1} | cut -d '_' -f '1')"

# -------------------------------------------
# Ejecutar kraken2 sobre las lecturas postrim
# -------------------------------------------

kraken2 --paired ${R1} ${R2} \
        --gzip-compressed \
        --db $KRAKEN2_DB_PATH \
        --use-names \
        --threads 5 \
        --report /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_${ID}_temp.txt

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Filtra los resultados si en la columna 4 del reporte .txt tiene caracteres G o S (genero o especie) y la columna 3 (fragmentos asignados al taxón) tiene un valor mayor a 1
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

awk '$4 ~ "[GS]" && $1 >= 0.01' /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_${ID}_temp.txt > /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_species_${ID}.txt
awk '$1 >= 0.01' /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_${ID}_temp.txt > /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_final_${ID}.txt 
# Añadir títulos de columna al reporte .txt
sed -i '1i coverage%\tcoverage#\tasigned\trank_especie\tNCBItaxonomicID\ttaxonomic_name' /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_species_${ID}.txt 
sed -i '1i coverage%\tcoverage#\tasigned\trank_especie\tNCBItaxonomicID\ttaxonomic_name' /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria/kraken_final_${ID}.txt 

done

# ----------------------------------------------------------------
# Generar un solo archivo con los resultados de todas las muestras
# ----------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/kraken2/bacteria

for file in *_species_*; do
    ename="$(basename ${file} | cut -d '_' -f '3')"
    echo -e "\n${ename} \n$(cat ${file})"

done >> ./kraken_results_all.tsv

for file in *_final_*; do
    ename="$(basename ${file} | cut -d '_' -f '3')"
    echo -e "\n${ename} \n$(cat ${file})"

done >> ./kraken_results_all_shrt.tsv

rm *_temp*
rm *species*
rm *final*

echo -e "############################"
echo -e ===== Fin: $(date) =====
echo -e "############################"
