#!/bin/bash

echo -e "##########################################################################################" "\n"

echo -e ===== Script para obtener el MLST sobre lecturas de diferentes géneros bacterianos ===== "\n"

echo -e                                ===== Inicio: $(date) ===== "\n"

echo -e "##########################################################################################" "\n"

cd /home/secuenciacion_cenasa/Analisis_corridas/Archivos_postrim/Bacterias

ln -s /home/secuenciacion_cenasa/Programas_Bioinformaticos/stringMLST/stringMLST_DB/* $(pwd)


# ------------------------------------------------------------------
# Definir especie y género de las bacterias de interés para análisis
# ------------------------------------------------------------------

for especie in Salmonella_enterica Escherichia_coli Enterococcus_spp Campylobacter_spp; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

# -------------------------------------------------------
# Loop para cada archivo en la carpeta donde nos ubicamos
# -------------------------------------------------------

for R1 in *R1_trim.fastq.gz; do
    R2=${R1/_R1_/_R2_}
    ID=$(basename ${R1} | cut -d '_' -f '1')


case ${especie} in Salmonella_enterica)
    if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then 
         stringMLST.py --predict -1 ${R1} \
                                 -2 ${R2} \
                       -P ${especie}/${genero} \
                       -o /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/${ID}_stringMLST_tmp_${genero}.tsv
cat /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/${ID}_stringMLST_tmp_${genero}.tsv >> /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/stringMLST_${genero}.tsv | sort -r | uniq

else
   continue
fi
  ;;
                  Escherichia_coli)
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} \
                                  -2 ${R2} \
                        -P ${especie}/${genero} \
                        -o /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/${ID}_stringMLST_tmp_${genero}.tsv
cat /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/${ID}_stringMLST_tmp_${genero}.tsv >> /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/stringMLST_${genero}.tsv | sort -r | uniq

#else
   #continue
#fi
# ;;
#     Siguiente genero bacteriano

fi
esac
done
done


rm Salmonella_enterica Escherichia_coli Enterococcus_spp Campylobacter_spp
rm /home/secuenciacion_cenasa/Analisis_corridas/stringMLST/*_tmp_*
