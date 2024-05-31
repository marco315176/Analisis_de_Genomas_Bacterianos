#!/bin/bash


echo -e "###############################################################################################"

echo -e ============= Estadísticos de lecturas de archivos fastQ.gz de corridas bacterianas ================

echo -e                              ===== Inicio: $(date) =====

echo -e "###############################################################################################"

cd /home/secuenciacion_cenasa/Analisis_corridas/Corrida_bacterias

# ------------------------------------------------------------------------
# Ejecuta fastQC sobre las lecturas en el directorio que terminen con .gz
# ------------------------------------------------------------------------

fastqc *.gz --extract -o /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria


cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria

# -------------------------------------------------------------------------------------------------
# Ejecuta multiqc sobre los reportes .HTML generados por fastQC para generar un reporte en conjunto
# -------------------------------------------------------------------------------------------------

multiqc . -o ./multiqc 

mv ./multiqc/multiqc_report.html ./multiqc/pretrimm_multiqc_report.html


cd /home/secuenciacion_cenasa/Analisis_corridas/Corrida_bacterias

# ---------------------------------------------------------------------------------------------------
# Ejecuta Trim_Galore para realizar el proceso de trimming sobre lecturas y ejecuta fastqc postrimming
# ---------------------------------------------------------------------------------------------------

trim_galore --quality 30 --length 70 --paired  *.gz --fastqc_args "--extract --outdir /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias" --output_dir /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias



cd /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias

mkdir -p reports_txt

mv  *.txt ./reports_txt

chmod -R 775 *.gz

for R1 in *_R1_*; do 
    R2=${R1/_R1_*val_1.fq.gz/_R2_*val_2.fq.gz}
    nameR1="$(basename ${R1} | cut -d '_' -f '1')"
    nameR2="$(basename ${R2} | cut -d '_' -f '1')"

# --------------------------------------------------------------
# Cámbio de nombre de los archivos trimmiados de salida R1 y R2 
# --------------------------------------------------------------

mv ${R1}  ${nameR1}_R1_trim.fastq.gz 
mv ${R2}  ${nameR2}_R2_trim.fastq.gz 

done #Termino del loop iniciado con "for"


cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias

# ------------------------------------------------------------------------------------------------------------------------------
# Ejecutar multiQC sobre los reportes .HTML generados por fastQC para generar un reporte en conjunto de los reportes postrimming
# ------------------------------------------------------------------------------------------------------------------------------

multiqc . -o ./multiqc 

mv ./multiqc/multiqc_report.html ./multiqc/postrimm_multiqc_report.html 

# ------------------------------------------------------------
# Conjuntar estadisticos de lecturas crudas en un solo archivo
# ------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastQC/Bacteria

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

cd /home/secuenciacion_cenasa/Analisis_corridas/Resultados_fastqc_ptrim/Bacterias

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
