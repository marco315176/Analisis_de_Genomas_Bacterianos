#!/bin/bash

echo -e "#############################################################" "\n"

echo -e ======= Ensamble de genomas bacterianos con metaSPAdes ======= "\n"

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
# Ejecuta SPAdes con función de metagenómica sobre mis lecturas R1 y R2 y genera el archivo de salida ${ID}_metaSPAdes
# --------------------------------------------------------------------------------------------------------------------

spades.py --meta -1 ${R1} \
                 -2 ${R2} \
          -t 20 -o /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_metaSPAdes

# ----------------------------------------------------------------------------------------------------------------------------------------------------------
# Cámbio de nombre del archivo "contigs.fasta" a "${ID}-metaSPAdes-assembly.fasta" y elimina el directorio "${ID}_metaSPAdes" con los archivos no necesarios
# ----------------------------------------------------------------------------------------------------------------------------------------------------------

mv /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_metaSPAdes/contigs.fasta /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_metaSPAdes/${ID}-metaSPAdes-assembly.fasta
mv /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_metaSPAdes/${ID}-metaSPAdes-assembly.fasta /home/admcenasa/Analisis_corridas/SPAdes/bacteria/.
rm -R /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}_metaSPAdes

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Ejecuta seqtk sobre "${ID}-metaSPAdes-assembly.fasta" para eliminar todos los contigs menores a 450 pb y nombra el archivo de salida como "${ID}-metaSPAdes-assembly.fa"
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/SPAdes/bacteria

seqtk seq -L 100 /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-metaSPAdes-assembly.fasta > /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-metaSPAdes-assembly.fa

chmod -R 775 /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-metaSPAdes-assembly.fa

# --------------------------------------------------------------------------------------------------
# Remueve los primeros archivos de contigs a modo de solo conservar los archivos generados por seqtk
# --------------------------------------------------------------------------------------------------

rm /home/admcenasa/Analisis_corridas/SPAdes/bacteria/${ID}-metaSPAdes-assembly.fasta

done #término del ciclo iniciado con "for"


echo -e "##################################################################"
echo -e                   ===== Fin: $(date) =====
echo -e "##################################################################"
