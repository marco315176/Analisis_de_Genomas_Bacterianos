#!/bin/bash

echo -e "######################################################################################" "\n"

echo -e ========== Iniciando espoligotipificación en lecturas de M.Bovis con vSNP3 ========== "\n"

echo -e "\t" =============== Inicio: $(date) ===============  "\n"

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
        echo -e " ---------- ${ID_R1} encontrado como ${organism}, no encontrado como Mycobacterium ----------"
continue
        else

echo -e "\t" "********** ${ID_R1} encontrado como ${organism} **********" "\n"
echo -e "###################################"
echo -e "Corriendo vSNP3 sobre: ${ID_R1}"
echo -e "###################################" "\n"

# ----------------------------------------------------
# Correr vSNP3 sobre las lecturas de M.Bovis obtenidas
# ----------------------------------------------------
dir="/home/admcenasa/Analisis_corridas/vSNP3"

vsnp3_step1.py -r1 ${R1} -r2 ${R2} -t /home/admcenasa/Programas_bioinformaticos/vSNP3/dependencies/Mycobacterium_AF2122 --spoligo -o ${dir}/${ID_R1}_spoligo_vsnp3

xlsx2csv -d "\t" ${dir}/${ID_R1}_spoligo_vsnp3/*.xlsx  ${dir}/${ID_R1}_spoligo_vsnp3/${ID_R1}_spoligo_vSNP3_tmp.tsv
cat ${dir}/${ID_R1}_spoligo_vsnp3/${ID_R1}_spoligo_vSNP3_tmp.tsv | tr " " "_" | awk '{print $1"\t"$25"\t"$26"\t"$27"\t"$28}' > ${dir}/${ID_R1}_spoligo_vsnp3/${ID_R1}_spoligo_vSNP3.tsv

mv ${dir}/${ID_R1}_spoligo_vsnp3/*_spoligo_vSNP3.tsv ${dir}/
mv ${dir}/${ID_R1}_spoligo_vsnp3/*log* ${dir}/
mv ${dir}/${ID_R1}_spoligo_vsnp3/*.pdf ${dir}/

#cat ${dir}/${ID}_vSNP_spoligo.csv | awk -v FPAT='([^,]*|"[^"]*")' '{print $1"\t"$25"\t"$26"\t"$27"\t"$28}' > ${dir}/${ID}_vSNP_spoligo.tsv

#rm ${dir}/${ID_R1}_spoligo_vsnp3/${ID_R1}_spoligo_vSNP3.tsv
rm -R ${dir}/${ID_R1}_spoligo_vsnp3/

     fi
    fi
 done
done

dir="/home/admcenasa/Analisis_corridas/vSNP3"

if compgen -G "${dir}/*_log.txt" > /dev/null; then
    mkdir -p "${dir}/vSNP3_log"
    mv "${dir}"/*_log.txt "${dir}/vSNP3_log"
	fi

if compgen -G "${dir}/*_report.pdf" > /dev/null; then
    mkdir -p "${dir}/PDF_reports"
    mv "${dir}"/*_report.pdf "${dir}/PDF_reports"
	fi

if compgen -G "${dir}/*_spoligo_vSNP3.tsv" > /dev/null; then
    cat "${dir}"/*_spoligo_vSNP3.tsv >> "${dir}/vSNP3_Spoligo_Prediction.tsv"
    rm "${dir}"/*_spoligo_vSNP3.tsv
	fi

# -----------------------------------------------------------------
# Mover los directorios y archivo de resultados al directorio final
# -----------------------------------------------------------------

cd ${dir}

	if [[ -f ./vSNP3_Spoligo_Prediction.tsv ]]; then
	if [[ -d ./PDF_reports ]]; then
	if [[ -d ./vSNP3_log ]]; then
mkdir -p /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3

mv ./vSNP3_Spoligo_Prediction.tsv /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3
mv ./PDF_reports /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3
mv ./vSNP3_log /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/vSNP3

   fi
  fi
 fi

echo -e "################################################################" "\n"

echo -e ========== Espoligotipificación de M.Bovis terminada ========== "\n"

echo -e "\t" =============== Fin: $(date) =============== "\n"

echo -e "################################################################"
