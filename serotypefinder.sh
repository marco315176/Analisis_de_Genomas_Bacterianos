#!/bin/bash

echo -e "#######################################################################################################"

echo -e =====  Ejecución de SerotypeFinder sobre ensambles para la ideantificación de serotipos de E. coli =====

echo -e                                      ===== Inicio: $(date) =====

echo -e "#######################################################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial

for assembly in *-SPAdes-assembly*; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')

# -------------------------------------------------------------------------
# Correr SerotypeFinder sobre los ensambles de E. coli obtenidos con SPAdes
# -------------------------------------------------------------------------

dir="/home/secuenciacion_cenasa/Analisis_corridas/serotypefinder"

mkdir -p ${dir}/${ID}_tmp_SFout

serotypefinder.py -i ${assembly} \
                  -o /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_tmp_SFout \
                  -mp blastn \
                  -p $SEROTYPEFINDER_DB \
                  -x

# ------------------------------------
# Renombrar el archivo results_tab.tsv
# ------------------------------------

mv /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_tmp_SFout/results_tab.tsv /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_tmp_SFout/${ID}_results_tmp_SF.tsv 
mv /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_tmp_SFout/${ID}_results_tmp_SF.tsv  /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/.

# -------------------------------------------------------------------------------------------------------
# Imprimir solo las columnas 1,2,3 y 4 de ${ID}_results_tmp_SF.tsv y quitar el encabezado de las columnas
# -------------------------------------------------------------------------------------------------------

cat /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_results_tmp_SF.tsv | awk '{print $1,$2,$3,$4}' | sed -e "1d" > /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_results_tmp.tsv

done

# ---------------------------------------------------
# Concatenar todos los archivos de salida en uno solo
# ---------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/

cat ./${ID}_results_tmp.tsv >> ./SF_tmp_results.tsv
sed -i '1i Database\tGen\tAntigen_prediction\tIdentity' ./SF_tmp_results.tsv > ./SF_results_all.tsv

rm -R *tmp*

echo -e "############################################################"
echo -e ===== Fin: $(date) =====
echo -e "############################################################"
