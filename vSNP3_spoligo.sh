#!/bin/bash

echo -e "######################################################################################" "\n"

echo -e ========== Iniciando espoligotipificación en lecturas de M.Bovis con vSNP3 ========== "\n"

echo -e "\t" =============== Fin: $(date) ===============  "\n"

echo -e "######################################################################################"

cd /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria

for file in /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for R1 in *_R1_*fastq.gz; do
    ID_R1=$(basename ${R1} | cut -d '_' -f '1')
    R2=${R1/_R1_/_R2_}
    ID_R2=$(basename ${R2} | cut -d '_' -f '1')

# -------------------------------------------------------------------------------------------------------
# Control para identificar las muestras que corresponden a Mycobacterium con los resultados de KmerFinder
# -------------------------------------------------------------------------------------------------------

if [[ ${ID_org} == ${ID_R1} && ${ID_R2} ]]; then
        echo -e "If control: Reads: ${ID_R1} ${ID_R2} Ensamble: ${ID_org}"
if [[ ${gene} != "Mycobacterium" ]]; then
        echo -e " ---------- ${ID} encontrado como ${organism}, no encontrado como Mycobacterium ----------"
continue
        else

echo -e "********** ${ID} encontrado como ${organism} **********" "\n"
echo -e "###################################"
echo -e "Corriendo vSNP3 sobre: ${ID}"
echo -e "###################################" "\n"

# ----------------------------------------------------
# Correr vSNP3 sobre las lecturas de M.Bovis obtenidas
# ----------------------------------------------------
dir="/home/admcenasa/Analisis_corridas/vSNP3"

vsnp3_step1.py -r1 ${R1} -r2 ${R2} \
	       -t /home/admcenasa/Programas_bioinformaticos/vSNP3/dependencies/Mycobacterium_AF2122 --spoligo \
	       -o ${dir}/${ID}_spoligo_vsnp3

ssconvert ${dir}/${ID}_spoligo_vsnp3/*.xlsx ${dir}/${ID}_spoligo_vsnp3/${ID}_vSNP_spoligo.csv

mv ${dir}/${ID}_spoligo_vsnp3/${ID}_vSNP_spoligo.csv ${dir}/
mv ${dir}/${ID}_spoligo_vsnp3/*log* ${dir}/
mv ${dir}/${ID}_spoligo_vsnp3/*.pdf ${dir}/

cat ${dir}/${ID}_vSNP_spoligo.csv | awk -v FPAT='([^,]*|"[^"]*")' '{print $1"\t"$25"\t"$26"\t"$27"\t"$28}' > ${dir}/${ID}_vSNP_spoligo.tsv
rm ${dir}/${ID}_vSNP_spoligo.csv

rm -R ${dir}/${ID}_spoligo_vsnp3/

     fi
    fi
 done
done

dir="/home/admcenasa/Analisis_corridas/vSNP3"

mkdir -p ${dir}/vSNP3_log
mv ${dir}/*_log.txt ${dir}/vSNP3_log

mkdir -p ${dir}/PDF_reports
mv ${dir}/*_report.pdf ${dir}/PDF_reports

cat ${dir}/*_spoligo.tsv >> ${dir}/SpoligoPrediction_vSNP3.tsv
rm ${dir}/*_spoligo.tsv

# -----------------------------------------------------------------
# Mover los directorios y archivo de resultados al directorio final
# -----------------------------------------------------------------

cd ${dir}

	if [[ -f ./SpoligoPrediction_vSNP3.tsv ]]; then
	if [[ -d ./PDF_reports ]]; then
	if [[ -d ./vSNP3_log ]]; then
mkdir -p /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3

mv ./SpoligoPrediction_vSNP3.tsv /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3
mv ./PDF_reports /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3
mv ./vSNP3_log /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3

   fi
  fi
 fi

echo -e "################################################################" "\n"

echo -e ========== Espoligotipificación de M.Bovis terminada ========== "\n"

echo -e "\t" =============== Fin: $(date) =============== "\n"

echo -e "################################################################"