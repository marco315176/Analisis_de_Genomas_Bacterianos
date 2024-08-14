#!/bin/bash

echo -e "#######################################################################################################" "\n"

echo -e =====  Ejecución de SerotypeFinder sobre ensambles para la ideantificación de serotipos de E. coli ===== "\n"

echo -e                                      ===== Inicio: $(date) ===== "\n"

echo -e "#######################################################################################################" "\n"

cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_all_bacteria/Ensambles/Escherichia_coli

for assembly in *.fa; do
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

cat /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_results_tmp_SF.tsv | awk '{print $1"\t"$2"\t"$3"\t"$4}' | sed -e "1d" > /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_results_tmp.tsv

# ---------------------------------------------------
# Concatenar todos los archivos de salida en uno solo
# ---------------------------------------------------

sed -i '1i Database\tGen\tAntigen_prediction\tIdentity' /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/${ID}_results_tmp.tsv

rm -R /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/*tmp_SFout* /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/*results_tmp_SF*

done

cd /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder

for file in *results_tmp*; do
    ID=$(basename ${file} | cut -d '_' -f '1')

echo -e "\n${ID} \n$(cat ${file})"

done >> ./SF_results_all.tsv 

# ID=$(basename ${file} | cut -d '_' -f '1')
 #   echo "${ID}" >> ./SF_results_all.tsv
  #  cat "${file}" >> ./SF_results_all.tsv
   # echo "" >> ./SF_results_all.tsv

#done
rm /home/secuenciacion_cenasa/Analisis_corridas/serotypefinder/*results_tmp*

echo -e "############################################################"
echo -e ===== Fin: $(date) =====
echo -e "############################################################"
