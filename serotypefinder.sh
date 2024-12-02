#!/bin/bash

echo -e "#####################################################################################################" "\n"

echo -e =====  Ejecutando SerotypeFinder sobre ensambles para la ideantificación de serotipos de E. coli ===== "\n"

echo -e                                      ===== Inicio: $(date) ===== "\n"

echo -e "#####################################################################################################" "\n"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial

for file in /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for assembly in *.fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')

# ------------------------------------------------------------------------------------------------
# Control para identificar las muestras que corresponden a E.coli con los resultados de KmerFinder
# ------------------------------------------------------------------------------------------------

if [[ ${ID} == ${ID_org} ]]; then
        echo -e "If control: ${ID} ${ID_org}"
if [[ ${organism} != "Escherichia_coli" ]]; then
        echo -e "${ID} encontrado como ${organism}, no encontrado como Escherichia_coli"
continue
        else
echo -e "${ID} encontrado como ${organism}" "\n"
echo -e "########################################"
echo -e "Corriendo SerotypeFinder sobre: ${ID}"
echo -e "########################################" "\n"

# -------------------------------------------------------------------------
# Correr SerotypeFinder sobre los ensambles de E. coli obtenidos con SPAdes
# -------------------------------------------------------------------------

dir="/home/secuenciacion_cenasa/Analisis_corridas/serotypefinder"

mkdir -p ${dir}/${ID}_tmp_SFout

serotypefinder.py -i ${assembly} \
                  -o ${dir}/${ID}_tmp_SFout \
                  -mp blastn \
                  -p $SF_DB_PATH \
                  -x

# ------------------------------------
# Renombrar el archivo results_tab.tsv
# ------------------------------------

mv ${dir}/${ID}_tmp_SFout/results_tab.tsv ${dir}/${ID}_tmp_SFout/${ID}_results_tmp_SF.tsv 
mv ${dir}/${ID}_tmp_SFout/${ID}_results_tmp_SF.tsv ${dir}/.

# -------------------------------------------------------------------------------------------------------
# Imprimir solo las columnas 1,2,3 y 4 de ${ID}_results_tmp_SF.tsv y quitar el encabezado de las columnas
# -------------------------------------------------------------------------------------------------------

cat ${dir}/${ID}_results_tmp_SF.tsv | awk '{print $1"\t"$2"\t"$3"\t"$4}' | sed -e "1d" > ${dir}/${ID}_results_tmp.tsv

# ---------------------------------------------------
# Concatenar todos los archivos de salida en uno solo
# ---------------------------------------------------

sed -i '1i Database\tGen\tAntigen_prediction\tIdentity' ${dir}/${ID}_results_tmp.tsv

rm -R ${dir}/*tmp_SFout* ${dir}/*results_tmp_SF*

	  fi
	fi
    done
done

cd ${dir}

for file in *results_tmp*; do
    ID=$(basename ${file} | cut -d '_' -f '1')

echo -e "\n ########## \t${ID}\t ########## \n$(cat ${file})"

done >> ./SF_results_all.tsv 


rm ${dir}/*results_tmp*

echo -e "############################################################"
echo -e                     ===== Fin: $(date) =====
echo -e "############################################################"
