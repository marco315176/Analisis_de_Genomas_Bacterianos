#!/bin/bash

echo -e "#############################################################"

echo -e ======= Ensamble de genomas bacterianos con SPAdes =======

echo -e                 ===== Inicio: $(date) =====

echo -e "##############################################################"

# -------------------------------------------------------------------
# Cámbio de directorio a donde se encuentran las lecturas postrimming
# -------------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias

for R1 in *_R1_* ; do
    R2=${R1/_R1_/_R2_}
    ID="$(basename ${R1} | cut -d '_' -f '1')"

# --------------------------------------------------------------------------------------------------------------------
# Ejecuta SPAdes sobre mis lecturas R1 y R2 y genera el archivo de salida ${ID}_SPAdes
# --------------------------------------------------------------------------------------------------------------------

spades.py   --isolate -1 ${R1} \
                      -2 ${R2} \
           -t 6 -o /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}_SPAdes

# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# Cámbio de nombre del archivo "contigs.fasta" a "${ID}-SPAdes-assembly.fasta" y elimina el directorio "${ID}_SPAdes" con los archivos no necesarios
# ----------------------------------------------------------------------------------------------------------------------------------------------------------

mv /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}_SPAdes/contigs.fasta /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}_SPAdes/${ID}-SPAdes-assembly.fasta
mv /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}_SPAdes/${ID}-SPAdes-assembly.fasta /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/.
rm -R /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}_SPAdes

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Ejecuta seqtk sobre "${ID}-SPAdes-assembly.fasta" para eliminar todos los contigs menores a 450 pb y nombra el archivo de salida como "${ID}-SPAdes-assembly.fa"
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------


seqtk seq -L 500 /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}-SPAdes-assembly.fasta > /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}-SPAdes-assembly.fa

chmod -R 775 /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}-SPAdes-assembly.fa

# --------------------------------------------------------------------------------------------------
# Remueve los primeros archivos de contigs a modo de solo conservar los archivos generados por seqtk
# --------------------------------------------------------------------------------------------------

rm /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/${ID}-SPAdes-assembly.fasta

done #término del ciclo iniciado con "for"


echo -e "##################################################################"
echo -e                   ===== Fin: $(date) =====
echo -e "##################################################################"
