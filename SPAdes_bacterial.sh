#!/bin/bash

echo -e "#############################################################" "\n"

echo -e ======= Ensamble de genomas bacterianos con SPAdes ======= "\n"

echo -e                 ===== Inicio: $(date) ===== "\n"

echo -e "##############################################################" "\n"

# -------------------------------------------------------------------
# Cámbio de directorio a donde se encuentran las lecturas postrimming
# -------------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria

for R1 in *_R1_* ; do
    R2=${R1/_R1_/_R2_}
    ID="$(basename ${R1} | cut -d '_' -f '1')"

# --------------------------------------------------------------------------------------------------------------------
# Ejecuta SPAdes sobre mis lecturas R1 y R2 y genera el archivo de salida ${ID}_SPAdes
# --------------------------------------------------------------------------------------------------------------------

spades.py   --isolate -1 ${R1} \
                      -2 ${R2} \
           -t 15 -o /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_SPAdes

# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# Cámbio de nombre del archivo "contigs.fasta" a "${ID}-SPAdes-assembly.fasta" y elimina el directorio "${ID}_SPAdes" con los archivos no necesarios
# ----------------------------------------------------------------------------------------------------------------------------------------------------------

mv /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_SPAdes/contigs.fasta /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_SPAdes/${ID}-SPAdes-assembly.fasta
mv /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_SPAdes/${ID}-SPAdes-assembly.fasta /home/admcenasa/Analisis_corridas/SPAdes/bacteria/.
rm -R /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_SPAdes

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Ejecuta seqtk sobre "${ID}-SPAdes-assembly.fasta" para eliminar todos los contigs menores a 450 pb y nombra el archivo de salida como "${ID}-SPAdes-assembly.fa"
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------


seqtk seq -L 100 /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-SPAdes-assembly.fasta > /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-SPAdes-assembly.fa

chmod -R 775 /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-SPAdes-assembly.fa

# --------------------------------------------------------------------------------------------------
# Remueve los primeros archivos de contigs a modo de solo conservar los archivos generados por seqtk
# --------------------------------------------------------------------------------------------------

rm /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-SPAdes-assembly.fasta

done #término del ciclo iniciado con "for"


echo -e "##################################################################"
echo -e                   ===== Fin: $(date) =====
echo -e "##################################################################"
