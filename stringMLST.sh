#!/bin/bash

echo -e "##########################################################################################" "\n"

echo -e ===== Ejecutando stringMLST sobre lecturas de diferentes géneros bacterianos ===== "\n"

echo -e                                ===== Inicio: $(date) ===== "\n"

echo -e "##########################################################################################" "\n"

#Creación de db de otra especie que no este en la db de stringMLST: stringMLST.py --buildDB -c mlst_dbs/Avibacterium_paragallinarum/Avibacterium_config.txt -P Avibacterium
#Nota: Se necesita un archivo fasta (.tfa) para cada uno de los alelos y un archivo config.txt
#Para descargar otro organismo: https://pubmlst.org/organisms

cd /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria

ln -s /home/admcenasa/Programas_bioinformaticos/stringMLST/mlst_dbs/* $(pwd)

# ------------------------------------------------------------------
# Definir especie y género de las bacterias de interés para análisis
# ------------------------------------------------------------------

for especie in Avibacterium_paragallinarum Brucella_spp Salmonella_enterica Enterococcus_faecalis Enterococcus_faecium Escherichia_coli_1 Escherichia_coli_2 Staphylococcus_aureus; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

# -------------------------------------------------------
# Loop para cada archivo en la carpeta donde nos ubicamos
# -------------------------------------------------------
dirdb="/home/admcenasa/Programas_bioinformaticos/stringMLST/mlst_dbs"
dirout="/home/admcenasa/Analisis_corridas/stringMLST"

for file in /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for R1 in *R1_trim.fastq.gz; do
    R2=${R1/_R1_/_R2_}
    ID=$(basename ${R1} | cut -d '_' -f '1')

# Tipificación para Avibacterium
case ${especie} in Avibacterium_paragallinarum)
if [[ ${ID} == ${ID_org} ]]; then
        echo -e "If control: ${ID} ${assembly_ID}"
if [[ ${organism} != "Avibacterium_paragallinarum" ]]; then
        echo -e "If control: ${genero}"
continue
	else
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Avibacterium_paragallinarum/Avibacterium \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

	fi
     fi
  fi
 ;;

# Tipificación para Brucella_spp
                 Brucella_spp)
if [[ ${ID} == ${ID_org} ]]; then
        echo -e "If control: ${ID} ${assembly_ID}"
if [[ ${gene} != "Brucella" ]]; then
        echo -e "If control: ${genero}"
continue
        else

     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Brucella_spp/Brucella \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

        fi
     fi
  fi

 ;;

#Tipificación para Salmonella
			 Salmonella_enterica)
if [[ ${ID} == ${ID_org} ]]; then
        echo -e "If control: ${ID} ${assembly_ID}"
if [[ ${gene} != "Salmonella" ]]; then
        echo -e "If control: ${genero}"
continue
        else

     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Salmonella_enterica/Salmonella_enterica \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

         fi
     fi
  fi

 ;;

#Tipificación para Enterococcus_faecalis
                         Enterococcus_faecalis)
     if [[ ! -f stringMLST_temp_${especie}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Enterococcus_faecalis/Enterococcus_faecalis \
                        -o ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv >> ${dirout}/stringMLST_result_${especie}.tsv | sort -r | uniq

else
   continue
fi
 ;;

#Tipificación para Enterococcus_faecium
                         Enterococcus_faecium)
     if [[ ! -f stringMLST_temp_${especie}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Enterococcus_faecium/Enterococcus_faecium \
                        -o ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${especie}.tsv >> ${dirout}/stringMLST_result_${especie}.tsv | sort -r | uniq

else
   continue
fi
 ;;

#Tipificación para Staphylococcus_aureus
                         Staphylococcus_aureus)
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Staphylococcus_aureus/Staphylococcus_aureus \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}.tsv >> ${dirout}/stringMLST_result_${genero}.tsv | sort -r | uniq

else
   continue
fi
 ;;

#Tipificación para Escherichia_coli 1
                         Escherichia_coli_1)
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Escherichia_coli_1/Escherichia_coli_1 \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}_1.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}_1.tsv >> ${dirout}/stringMLST_result_${genero}_1.tsv | sort -r | uniq

else
   continue
fi
 ;;

#Tipificación para Escherichia_coli 2
                         Escherichia_coli_2)
     if [[ ! -f stringMLST_temp_${genero}.tsv ]]; then
          stringMLST.py --predict -1 ${R1} -2 ${R2} \
                        -P ${dirdb}/Escherichia_coli_2/Escherichia_coli_2 \
                        -o ${dirout}/${ID}_stringMLST_tmp_${genero}_2.tsv
cat ${dirout}/${ID}_stringMLST_tmp_${genero}_2.tsv >> ${dirout}/stringMLST_result_${genero}_2.tsv | sort -r | uniq

#else
   #continue
#fi
# ;;
#                        Siguiente genero bacteriano)

fi
esac
done
	 rm ${especie}*
done
done
done

rm /home/admcenasa/Analisis_corridas/stringMLST/*_tmp_*

echo -e "###############################################################" "\n"	

echo -e                  ===== Fin: $(date) ===== "\n"

echo -e "###############################################################" "\n"
