#!/bin/bash

echo -e "###################################################################################################"

echo -e ===== Ejecución de SeqSero2 sobre ensambles para la ideantificación de serotipos de Salmonella =====

echo -e                                   ===== Inicio: $(date) =====

echo -e "###################################################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/Salmonella_enterica


for assembly in *.fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')

# ----------------------------------------------------------------------
# Correr SeqSero2 sobre los ensambles de Salmonella obtenidos con SPAdes
# ----------------------------------------------------------------------

SeqSero2_package.py -t 4 \
                    -i ${assembly} \
                    -m k \
                    -d /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out

# -------------------------------------------------------
# Crear la carpeta SeqSero2_log y mover los archivos .log 
# -------------------------------------------------------

mkdir -p /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/SeqSero2_log

mv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/SeqSero_log.txt /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/${ID}_SeqSero_log.txt
mv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/${ID}_SeqSero_log.txt /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/SeqSero2_log/.

# ------------------------------------------
# Renombrar y mover los archivos *result.tsv
# ------------------------------------------

mv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/SeqSero_result.tsv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/${ID}_tmp_result.tsv
mv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_SeqSero2out/${ID}_tmp_result.tsv /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/.
cat /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_result.tsv | sed -e "1d" | tr ' ' '_' > /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_filt.tsv

# -------------------------------------
# Modificar los archivos .tsv de salida
# -------------------------------------

cat /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/${ID}_tmp_filt.tsv >> /home/secuenciacion_cenasa/Analisis_corridas/seqsero2/SeqSero2_tmp_filt.tsv | uniq

done

# ------------------------------------------------------------------
# Añadir títulos de columna e imprimir solo las columnas importantes
# ------------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/seqsero2

sed -i '1i Sample_name\tOutput_directory\tInput_files\tO_antigen_prediction\tH1_antigen_prediction(fliC)\tH2_antigen_prediction(fljB)\tPredicted_identification\tPredicted_antigenic_profile\tPredicted_serotype\tNote' ./SeqSero2_tmp_filt.tsv
awk '{print $1"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10}' ./SeqSero2_tmp_filt.tsv > ./SeqSero2_result_filt.tsv

rm -R *tmp*

echo -e "#######################"

echo -e ===== Fin: $(date) =====

echo -e "#######################"

