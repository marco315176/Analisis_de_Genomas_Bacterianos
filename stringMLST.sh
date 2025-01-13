#!/bin/bash

echo -e "##########################################################################################" "\n"

echo -e ===== Ejecutando stringMLST sobre lecturas de diferentes géneros bacterianos ===== "\n"

echo -e                                ===== Inicio: $(date) ===== "\n"

echo -e "##########################################################################################" "\n"

#Creación de db de otra especie que no este en la db de stringMLST: stringMLST.py --buildDB -c mlst_dbs/Avibacterium_paragallinarum/Avibacterium_config.txt -P Avibacterium
#Nota: Se necesita un archivo fasta (.tfa) para cada uno de los alelos y un archivo config.txt
#Para descargar otro organismo: https://pubmlst.org/organisms
#Para mostrar los esquemas disponibles de especies: stringMLST.py --getMLST --species list

#ln -s /home/secuenciacion_cenasa/Programas_Bioinformaticos/stringMLST/mlst_dbs/* $(pwd)

# ------------------------------------------------------------------
# Definir especie y género de las bacterias de interés para análisis
# ------------------------------------------------------------------
cd /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria

for especie in Avibacterium_paragallinarum Brucella_spp Salmonella_enterica Enterococcus_faecalis Enterococcus_faecium Mycobacteria_spp Staphylococcus_aureus; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "\t ########## Genero: ${genero} ##########"

for file in /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for R1 in *R1_trimm.fastq.gz; do
    R2=${R1/_R1_/_R2_}
    ID=$(basename ${R1} | cut -d '_' -f '1')

dirdb="/home/admcenasa/Programas_bioinformaticos/stringMLST/mlst_dbs"
dirout="/home/admcenasa/Analisis_corridas/stringMLST"

#---------- Tipificación para Avibacterium ----------#

case ${especie} in Avibacterium_paragallinarum)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${organism} != "Avibacterium_paragallinarum" ]]; then
continue
	else
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
				     echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Avibacterium_paragallinarum/Avibacterium \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

	else
 continue
   fi
  fi
 fi
;;
#---------- Tipificación para Brucella_spp ----------#

			Brucella_spp)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${gene} != "Brucella" ]]; then
continue
        else
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
				echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Brucella_spp/Brucella \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

        else
 continue
   fi
  fi
 fi
;;

#---------- Tipificación para Salmonella ----------#

                        Salmonella_enterica)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${organism} != "Salmonella_enterica" ]]; then
continue
        else
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
				echo -e "\t ---------- Tipificando ${ID} ----------" 
         stringMLST.py --predict -1 ${R1} -2 ${R2} \
                      -P ${dirdb}/Salmonella_enterica/Salmonella_enterica \
                      -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

        else
 continue
   fi
  fi
 fi
;;

#---------- Tipificación para Enterococcus_faecalis ----------#

                        Enterococcus_faecalis)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${organism} != "Enterococcus_faecalis" ]]; then
continue
        else
     if [[ ! -f stringMLST_temp_${especie}.tsv ]]; then
				echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                       -P ${dirdb}/Enterococcus_faecalis/Enterococcus_faecalis \
                       -o ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv >> ${dirout}/stringMLST_result_${especie}.tsv | sort -r | uniq

else
   continue
   fi
  fi
 fi
;;

#---------- Tipificación para Enterococcus_faecium ----------#
                         Enterococcus_faecium)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${organism} != "Enterococcus_faecium" ]]; then
continue
	else
     if [[ ! -f stringMLST_temp_${especie}.tsv ]]; then
				echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Enterococcus_faecium/Enterococcus_faecium \
                        -o ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv >> ${dirout}/stringMLST_result_${especie}.tsv | sort -r | uniq

else
   continue
   fi
  fi
 fi
;;

#---------- Tipificación para Mycobacteria_spp ----------#
                         Mycobacteria_spp)
    if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
    if [[ ${gene} != "Mycobacterium" ]]; then
continue
        else
     if [[ ! -f stringMLST_temp_${especie}.tsv ]]; then
				echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Mycobacteria_spp/Mycobacteria_spp \
                        -o ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv >> ${dirout}/stringMLST_result_${especie}.tsv | sort -r | uniq

else
   continue
   fi
  fi
 fi
;;

#---------- Tipificación para Staphylococcus_aureus ----------#
                         Staphylococcus_aureus)
	if [[ ${ID_org} == ${ID} ]]; then
                                     echo -e "If control: ${ID_org} ${ID}"
	if [[ ${organism} != "Staphylococcus_aureus" ]]; then
continue
        else
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
					echo -e "\t ---------- Tipificando ${ID} ----------"
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Staphylococcus_aureus/Staphylococcus_aureus \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq


fi
fi
fi
esac
done
#	 rm ${especie}*
done
done

rm /home/admcenasa/Analisis_corridas/stringMLST/*_tmp_*

echo -e "###############################################################################" "\n"
echo -e =============== Determinación del MLST sobre lecturas terminada =============== "\n"
echo -e  "\t"                     ===== Fin: $(date) ===== "\n"
echo -e "###############################################################################" "\n"
