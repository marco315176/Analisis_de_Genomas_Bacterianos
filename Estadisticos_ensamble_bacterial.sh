#!/bin/bash

echo -e "########################################################################"

echo -e ===== Evaluación de profundidad de los ensambles de Bacterias obtenidos =====

echo -e ===========             Inicio: $(date)               ===========

echo -e "#########################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial

for ensamble in *fa; do
    ensamble_ID="$(basename ${ensamble} | cut -d '-' -f '1')"
    ensamble_name="$(basename ${ensamble} | cut -d '-' -f '1,2')"


# -----------------
# Correr bwa index
# -----------------

bwa index -p $(basename ${ensamble_name} .fa) ${ensamble}

# ---------------------------------------------
# Declarar cuales son tus archivos de lecturas
# ---------------------------------------------

for R1 in /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias/*_R1_*; do
name_R1="$(basename ${R1} | cut -d '_' -f '1')"
R2="${R1/_R1_/_R2_}"
name_R2="$(basename ${R2} | cut -d '_' -f '1')"


# ----------------------------------------------------------------------------------
# Controles en caso de que el ensamble y el read que se alinearán no se llamen igual
# ----------------------------------------------------------------------------------

echo -e "Nombres Control:\t Ensamble: ${ensamble_ID} \tReads: ${name_R1} ${name_R2}"

if [[ ${ensamble_ID} != ${name_R1} && ${name_R2} ]]; then 
   continue 
echo -e "If Control:\t Ensamble: ${ensamble_ID} \tRead: ${name_R1} ${name_R2}"

   else
echo -e "Else Control:\t Ensamble: ${ensamble_ID} \tRead: ${name_R1} ${name_R2}"

# ----------------------------------------------------------------------
# Correr bwa mem para el alineamiento entre ensamble y lecturas R1 y R2
# ----------------------------------------------------------------------

bwa mem -o $(basename ${ensamble_name} .fa).sam -M  $(basename ${ensamble_name} .fa) ${R1} ${R2}

# ----------------------------------------------------------------
# Filtrar los alineamientos para obtener solo los de alta calidad
# ----------------------------------------------------------------

samtools view -b -h -@ 4 -f 3 -q 60 -o $(basename ${ensamble_name} .fa).tmp.bam $(basename ${ensamble_name} .fa).sam
samtools sort -l 9 -@ 4 -o $(basename ${ensamble_name} .fa).bam $(basename ${ensamble_name} .fa).tmp.bam
samtools index $(basename ${ensamble_name} .fa).bam

# -----------------------
# Obtener profundidad
# -----------------------

samtools depth -aa $(basename ${ensamble_name} .fa).bam > ${ensamble_name}_depth #Por contig
awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}' ${ensamble_name}_depth > ./${ensamble_name}-depth.txt
sed -i 's/^//' ./${ensamble_name}-depth.txt

# ------------------
# Obtener Cobertura
# ------------------

grep -v \> ${ensamble} | perl -pe 's/\n//' | wc -c > ${ensamble_name}_lenght
awk 'BEGIN{FS="\t"}{if($3 > 0){print $0}}' ${ensamble_name}_depth | wc -l | awk -v len="$(cat ${ensamble_name}_lenght)" '{print $1/len}' > ./${ensamble_name}-coverage.txt
sed -i 's/^//' ./${ensamble_name}-coverage.txt


rm $(basename ${ensamble_name} .fa).*
rm ${ensamble_name}_depth
rm ${ensamble_name}_lenght

fi
done
done

# -------------------------------------------
# Generar archivo con profundidad y covertura
# -------------------------------------------

echo -e "Coverage,Depth" > ./estadisticos/CovDep.csv
for cover in *coverage*; do
    cov="$(cat ${cover})"
    depth="${cover/-coverage./-depth.}"
    prof="$(cat ${depth})"
    ename="$(basename ${cover} | cut -d '-' -f '1')"
echo -e "${cov},${prof}"
done >> ./estadisticos/CovDep.csv

rm *coverage.txt *depth.txt


# --------------------------------
# Obtener estadisticas de ensamble
# --------------------------------

echo -e "ID,Contigs,Largest_contig,Longitud_ensamble" > ./estadisticos/Estadisticas_ensamble.csv

for estadistic in *fa; do
    ID="$(basename ${estadistic} | cut -d '-' -f '1')" #ID del ensamble
    contigs="$(cat ${estadistic} | grep "^>" | wc -l)" #Número de contigs
    largest="$(cat ${estadistic} | sed -n '1p' | cut -d '_' -f '3,4')" #Contig más largo
    longitud="$(cat ${estadistic} | awk '{seq_length += length($0)} END {print seq_length}')" # Longitud de ensamble
echo -e "${ID},${contigs},${largest},${longitud}"
done >> ./estadisticos/Estadisticas_ensamble.csv

# ------------------------
# Conjuntar estadisticos de ensamble, covertura y longitud
# ------------------------


paste ./estadisticos/Estadisticas_ensamble.csv ./estadisticos/CovDep.csv | sed 's/,/\t/g' > ./estadisticos/Estadisticos_totales.tsv

rm ./estadisticos/CovDep.csv ./estadisticos/Estadisticas_ensamble.csv

# ------------------------------------------------------------
# Obtener archivo global de estadisticas (lecturas y ensamble)
# ------------------------------------------------------------

paste /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria/estadisticos/lecturas_stats.tsv /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias/estadisticos/lecturas_stats_pt.tsv ./estadisticos/Estadisticos_totales.tsv |  awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$20"\t"$21"\t"$22"\t"$23"\t"24}' > ./estadisticos/Estadistico_global.tsv

rm ./estadisticos/Estadisticos_totales.tsv

echo -e "#####################################################"
echo                   ===== Fin: $(date) =====
echo -e "#####################################################"
