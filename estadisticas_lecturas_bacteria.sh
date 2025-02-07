#!/bin/bash

echo -e "#############################################################################################" "\n"
echo -e  ============= Analizando estadísticos de lecturas crudas de corrida de bacterias ================ "\n"
echo -e  "\t"                            ===== Inicio: $(date) ===== "\n"
echo -e "#############################################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/Corrida_bacterias

# ------------------------------------------------------------------------
# Ejecuta fastQC sobre las lecturas en el directorio que terminen con .gz
# ------------------------------------------------------------------------

fastqc *.gz --extract -o /home/admcenasa/Analisis_corridas/fastQC/bacteria


cd /home/admcenasa/Analisis_corridas/fastQC/bacteria

# -------------------------------------------------------------------------------------------------
# Ejecuta multiqc sobre los reportes .HTML generados por fastQC para generar un reporte en conjunto
# -------------------------------------------------------------------------------------------------

multiqc . -o ./multiqc

mv ./multiqc/multiqc_report.html ./multiqc/pretrimm_multiqc_report.html


echo -e "####################################################################################################" "\n"
echo -e  =============== Iniciando Trimming de lecturas de genoma bacteriano con Trimmomatic  =============== "\n"
echo -e  "\t" =============== Inicio: $(date) =============== "\n"
echo -e "####################################################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/Corrida_bacterias

Trimmomatic="java -jar /home/admcenasa/Programas_bioinformaticos/Trimmomatic-0.39/trimmomatic-0.39.jar"
NexteraPE="/home/admcenasa/Programas_bioinformaticos/Trimmomatic-0.39/adapters/NexteraPE-PE.fa"
dir="/home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria"
mkdir -p /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria/U1U2

for R1 in *_R1_*; do
    R2=${R1/_R1_/_R2_}
    ID=$(basename ${R1} | cut -d '_' -f '1')
    ID2=$(basename ${R2} | cut -d '_' -f '1')

${Trimmomatic} PE -threads 6 -phred33 ${R1} ${R2} \
${dir}/${ID}_R1_trimm.fastq.gz ${dir}/U1U2/${ID}_U1_trimm.fastq.gz \
${dir}/${ID2}_R2_trimm.fastq.gz ${dir}/U1U2/${ID2}_U2_trimm.fastq.gz \
ILLUMINACLIP:${NexteraPE}:2:30:10 SLIDINGWINDOW:4:25 MINLEN:70

done

rm /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria/U1U2/*gz

echo -e "##################################################################################################" "\n"
echo -e  ============= Analizando estadísticos de lecturas limpias de corrida de bacterias ================ "\n"
echo -e  "\t"                            ===== Inicio: $(date) ===== "\n"
echo -e "##################################################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria

# ------------------------------------------------------------------------
# Ejecuta fastQC sobre las lecturas en el directorio que terminen con .gz
# ------------------------------------------------------------------------

fastqc *.gz --extract -o /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria

cd /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria

# -------------------------------------------------------------------------------------------------
# Ejecuta multiqc sobre los reportes .HTML generados por fastQC para generar un reporte en conjunto
# -------------------------------------------------------------------------------------------------

multiqc . -o ./multiqc

mv ./multiqc/multiqc_report.html ./multiqc/postrimm_multiqc_report.html

# ------------------------------------------------------------
# Conjuntar estadisticos de lecturas crudas en un solo archivo
# ------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/fastQC/bacteria

echo -e "ID,seq,longitud,%GC,PromQ" > ./estadisticos/lecturas.csv

for file in *_fastqc; do
    ID="$(basename ${file} | cut -d '_' -f '1')"
    seq="$(cat ${file}/fastqc_data.txt  | sed -n '7p' | awk '{print $3}')"
    long="$(cat ${file}/fastqc_data.txt | sed -n '10p' | awk '{print $3}')"
    GC="$(cat ${file}/fastqc_data.txt | sed -n '11p' | awk '{print $2}')"
    #Calcular promedio de Q
    inicio="$(cat -n ${file}/fastqc_data.txt | grep '#Base' | awk '{print $1}' | sed -n '1p')"
    fin="$(cat -n ${file}/fastqc_data.txt | grep '>>END_MODULE' | awk '{print $1}' | sed -n '2p')"
    PromQ="$(cat ${file}/fastqc_data.txt | sed -n "$[ $(echo ${inicio}) + 1 ], $[ $(echo ${fin}) - 1] p" | awk '{sum += $2;n++} END {if (n > 0) print sum / n}')"
echo -e "${ID},${seq},${long},${GC},${PromQ}"
done >> ./estadisticos/lecturas.csv

awk 'NR % 2 == 0' ./estadisticos/lecturas.csv | grep -v 'ID' > ./estadisticos/R1_stat_temp.csv
awk 'NR % 2 == 1' ./estadisticos/lecturas.csv | grep -v 'ID' > ./estadisticos/R2_stat_temp.csv

paste ./estadisticos/R1_stat_temp.csv ./estadisticos/R2_stat_temp.csv | sed '1i ID,R1_#seqs,R1_Longitud,R1_%GC,R1_PromQ,ID_R2,R2_#seqs,R2_Longitud,R2_%GC,R2_PromQ' | sed 's/,/\t/g' | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$8"\t"$9"\t"$10}' > ./estadisticos/lecturas_stats.tsv

rm ./estadisticos/*temp*
rm ./estadisticos/lecturas.csv

# -----------------------------------------------------------------
# Conjuntar estadisticos de lecturas postrimming en un solo archivo
# -----------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/fastQC_ptrim/bacteria

echo -e "ID,seq,long,%GC,PromQ" > ./estadisticos/lecturas_pt.csv

for file in *_fastqc; do
    ename="$(basename ${file} | cut -d '_' -f '1')"
    seq="$(cat ${file}/fastqc_data.txt | sed -n '7p' | awk '{print $3}')"
    long="$(cat ${file}/fastqc_data.txt | sed -n '10p' | awk '{print $3}')"
    GC="$(cat ${file}/fastqc_data.txt | sed -n '11p' | awk '{print $2}')"
    #Calcular promedio de Q
    inicio="$(cat -n ${file}/fastqc_data.txt | grep '#Base' | awk '{print $1}' | sed -n '1p')"
    fin="$(cat -n ${file}/fastqc_data.txt | grep '>>END_MODULE' | awk '{print $1}' | sed -n '2p')"
    PromQ="$(cat ${file}/fastqc_data.txt | sed -n "$[ $(echo ${inicio}) + 1 ], $[ $(echo ${fin}) - 1] p" | awk '{sum += $2;n++} END {if (n > 0) print sum / n}')"
echo -e "${ename},${seq},${long},${GC},${PromQ}"
done >> ./estadisticos/lecturas_pt.csv

awk 'NR % 2 == 0' ./estadisticos/lecturas_pt.csv | grep -v 'ID' > ./estadisticos/R1_stat_pt_temp.csv
awk 'NR % 2 == 1' ./estadisticos/lecturas_pt.csv | grep -v 'ID' > ./estadisticos/R2_stat_pt_temp.csv

paste ./estadisticos/R1_stat_pt_temp.csv ./estadisticos/R2_stat_pt_temp.csv | sed '1i ID,R1_#seqs_pt,R1_Longitud_pt,R1_%GC_pt,R1_PromQ_pt,ID_R2_pt,R2_#seqs_pt,R2_Longitud_pt,R2_%GC_pt,R2_PromQ_pt' | sed 's/,/\t/g' | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$8"\t"$9"\t"$10}' > ./estadisticos/lecturas_stats_pt.tsv

rm ./estadisticos/*temp*
rm ./estadisticos/lecturas_pt.csv

echo -e "#####################################################################################" "\n"
echo -e  =============== Analisis de calidad y limpieza de lecturas completado =============== "\n"
echo -e  =============== Fin: $(date) =============== "\n"
echo -e "#####################################################################################" "\n"
