#!/bin/bash

echo -e "###########################################################################################################################"

echo -e === Ejecutar kmerfinder sobre ensambles obtenidos con metaSPAdes o SPAdes para la identificación taxonómica de bacterias === 

echo -e                                        ===== Inicio: $(date) =====

echo -e "############################################################################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial

for assembly in *.fa*; do
    ID="$(basename ${assembly} | cut -d '-' -f '1')"
    ename="$(basename ${assembly} | cut -d '_' -f '1,2')"

# -----------------------------------------------------------------------
# Correr kmerfinder sobre los ensambles obtenidos con metaSPAdes o SPAdes
# -----------------------------------------------------------------------

kmerfinder.py -i ${assembly} \
              -db $kmerfinder_db_PATH/bacteria/bacteria.ATG \
              -tax $kmerfinder_db_PATH/bacteria/bacteria.tax \
              -o /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}

# ----------------------------------------------------------------------------------------------------------------------
# Mover los resultados .txt y .spa un directorio atras, añadiendoles el ID de su muestra y eliminar la carpeta /KF_${ID}
# ----------------------------------------------------------------------------------------------------------------------

mv /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}/results.txt /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/${ID}_results.txt
mv /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}/results.spa /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/${ID}_results.spa
rm -R /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}

done

# -----------------------------------------------------
# Conjuntar los archivos .txt en uno solo de resultados
# -----------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria

for file in *.spa; do
    ename="$(basename ${file} | cut -d '_' -f '1')"
    echo -e "\n${ename} \n$(cat ${file})"

done >> ./kmerfinder_results_all.tsv

rm *.txt
rm *.spa
