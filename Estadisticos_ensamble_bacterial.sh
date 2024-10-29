#!/bin/bash

echo -e "########################################################################" "\n"

echo -e ===== Evaluación de estadisticos de los ensambles de Bacterias obtenidos ===== "\n"

echo -e                  =========== Inicio: $(date) =========== "\n"

echo -e "#########################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/SPAdes/bacteria

for ensamble in *fa; do
    ID="$(basename ${ensamble} | cut -d '-' -f '1')"
    ensamble_name="$(basename ${ensamble} | cut -d '-' -f '1,2')"

# -----------------
# Correr bwa index
# -----------------

bwa index -p $(basename ${ensamble_name} .fa) ${ensamble}

# ---------------------------------------------
# Declarar cuales son tus archivos de lecturas
# ---------------------------------------------

for R1 in /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria/*_R1_*; do
name_R1="$(basename ${R1} | cut -d '_' -f '1')"
R2="${R1/_R1_/_R2_}"
name_R2="$(basename ${R2} | cut -d '_' -f '1')"

# ----------------------------------------------------------------------------------
# Controles en caso de que el ensamble y el read que se alinearán no se llamen igual
# ----------------------------------------------------------------------------------

echo -e "Nombres Control:\t Ensamble: ${ID} \tReads: ${name_R1} ${name_R2}"

if [[ ${ID} != ${name_R1} && ${name_R2} ]]; then 
   continue 
echo -e "If Control:\t Ensamble: ${ID} \tRead: ${name_R1} ${name_R2}"

   else
echo -e "Else Control:\t Ensamble: ${ID} \tRead: ${name_R1} ${name_R2}"

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

samtools depth -aa $(basename ${ensamble_name} .fa).bam > ./${ID}_depth #Por contig
awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}' ${ID}_depth > ./${ID}-depth.txt
sed -i 's/^//' ./${ID}-depth.txt

# ------------------
# Obtener Cobertura
# ------------------

grep -v \> ${ensamble} | perl -pe 's/\n//' | wc -c > ${ID}_lenght
awk 'BEGIN{FS="\t"}{if($3 > 0){print $0}}' ${ID}_depth | wc -l | awk -v len="$(cat ${ID}_lenght)" '{print $1/len}' > ./${ID}-coverage.txt
sed -i 's/^//' ./${ID}-coverage.txt

rm $(basename ${ensamble_name} .fa).*
rm ${ID}_depth
rm ${ID}_lenght

fi
done
done

# ---------------------------------------------------------------
# Correr assembly-stats sobre ensambles para obtener estadisticos
# ---------------------------------------------------------------

for assembly in *fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1') #ID del ensamble
    assembly-stats ${assembly} > ./${ID}_stats.txt #Correr assembly-stats sobre los ensambles y crear un archivo para cada muestra
done

# ----------------------------------------------------------
# Agregar profundidad al archivo generado por assembly-stats
# ----------------------------------------------------------

for depth in *depth*; do
    dep=$(basename ${depth} | cut -d '-' -f '1') #ID del archivo de profundidad
for stats in *stats*; do
    st=$(basename ${stats} | cut -d '_' -f '1') #ID del archivo de estadisticos
if [[ ${dep} != ${st} ]]; then 
   continue
else
echo -e "Control:\tDepth: ${dep}\tStats: ${st}"
echo $(cat ${depth}) >> ${stats} #Agrega el valor de profundidad al archivo de stats
      fi
   done
done

# --------------------------------------------------------
# Agregar covertura al archivo generado por assembly-stats
# --------------------------------------------------------

for cover in *coverage*; do
    cov=$(basename ${cover} | cut -d '-' -f '1') #ID del archivo de covertura
for stats in *stats*; do
    st=$(basename ${stats} | cut -d '_' -f '1') #ID del archivo de estadisticos
if [[ ${cov} != ${st} ]]; then 
   continue
else
echo -e "Control:\tCoverage: ${cov}\tStats: ${st}"
echo $(cat ${cover}) >> ${stats} #Agrega el valor de covertura al archivo de stats
      fi
   done
done


# -------------------------------------------
# Conjuntar todos los estadisticos en un archivo final
# -------------------------------------------

echo -e "ID\tContigs\tLongitud_ensamble\tLargest_contig\tN50\tN90\tN_count\tGaps\tProfundidad\tCobertura" > ./estadisticos/Estadisticos_totales.tsv

for file in *_stats*; do
    ID=$(basename ${file} | cut -d '_' -f '1')
    contigs=$(cat ${file} | sed -n '2p' | cut -d ',' -f '2' | cut -d ' ' -f '4') # Número de contigs
    longitud=$(cat ${file} | sed -n '2p' | cut -d ',' -f '1' | cut -d ' ' -f '3') # Longitud del ensamble
    largest=$(cat ${file} | sed -n '2p' | cut -d ',' -f '4' | cut -d ' ' -f '4') # Contig más largo
    N50=$(cat ${file} | sed -n '3p' | cut -d ',' -f '1' | cut -d ' ' -f '3') # N50
    N90=$(cat ${file} | sed -n '7p' | cut -d ',' -f '1' | cut -d ' ' -f '3') # N90
    N_count=$(cat ${file} | sed -n '9p' | cut -d ' ' -f '3') # Ns en el ensamble
    gaps=$(cat ${file} | sed -n '10p' | cut -d ' ' -f '3') # Gaps
    depth=$(cat ${file} | sed -n '11p') # Profundidad
    cov=$(cat ${file} | sed -n '12p') # Covertura
echo -e "${ID}\t${contigs}\t${longitud}\t${largest}\t${N50}\t${N90}\t${N_count}\t${gaps}\t${depth}\t${cov}"
done >> ./estadisticos/Estadisticos_totales.tsv

# ------------------------------------------------------------
# Obtener archivo global de estadisticas (lecturas y ensamble)
# ------------------------------------------------------------

paste /home/admcenasa/Analisis_corridas/fastQC/bacteria/estadisticos/lecturas_stats.tsv /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria/estadisticos/lecturas_stats_pt.tsv ./estadisticos/Estadisticos_totales.tsv | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$20"\t"$21"\t"$22"\t"$23"\t"$24"\t"$25"\t"$26"\t"$27"\t"$28}' > ./estadisticos/Estadistico_global.tsv

rm ./estadisticos/Estadisticos_totales.tsv
rm ./*coverage*
rm ./*depth*
rm ./*stats*

echo -e "#####################################################"
echo                   ===== Fin: $(date) =====
echo -e "#####################################################"
