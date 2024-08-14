#!/bin/bash

# Para descargar las bases de datos de pubMLST: mlst-download_pub_mlst -d . | bash
# Check it downloaded everything ok: find pubmlst | less
# Save the old database folder: mv ../db/pubmlst ../db/pubmlst.old
# Put the new folder there: mv ./pubmlst ../db/
# Regenerate the BLAST database: ./mlst-make_blast_db
# Check schemes are installed: ../bin/mlst --list

echo -e "###########################################################################" "\n"
echo -e   ===== Ejecutar mlst sobre todos los ensambles obtenidos con SPAdes ===== "\n"
echo -e                          ===== Inicio: $(date) ===== "\n"
echo -e "############################################################################" "\n"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial

for assembly in *.fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')
    name=$(basename ${assembly} | cut -d '-' -f '2')

mlst ${assembly} > /home/secuenciacion_cenasa/Analisis_corridas/MLST/${ID}_mlst_results.tsv

done

# --------------------------------
# Conjuntar los archivos de salida
# --------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/MLST

echo -e "Muestra\tDatabase\tST\tAlelos" > ./MLST_assembly_results_all.tsv

for MLST in *_mlst_*; do
    ID=$(basename ${MLST} | cut -d '_' -f '1')
echo -e "\n$(cat ${MLST})"
done >> ./MLST_assembly_results_all.tsv

rm ./*_mlst_*
