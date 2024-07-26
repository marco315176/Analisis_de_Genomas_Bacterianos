#!/bin/bash

echo -e "##################################################################################################"

echo -e ===== Identificación de genes y mutaciones de RAM en ensambles bacterianos con AMRFinderPlus =====

echo -e                                    ===== Inicio: $(date) =====

echo -e "##################################################################################################"

#Para actualizar la base de datos de AMRFinder: amrfinder -u
#Para conocer la lista de organismos disponibles para la opción --organism: amrfinder -l


for especie in Salmonella Escherichia; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

for file in /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for assembly in /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial/*.fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')

case ${especie} in Salmonella)
     if [[ ${especie} == ${gene} ]]; then
echo -e "If control: ${genero} ${gene}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${assembly} \
          --organism ${especie} \
          --plus \
          --mutation_all /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_${especie}_temp.tsv \
          --nucleotide_output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_nuc_${especie}.fa \
          --output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_${especie}_temp.tsv

   else

#echo -e "Else control: ${genero} ${gene}"
#echo -e "Else control: ${ID_org} ${ID}"

continue

     fi
   fi
 ;;

                   Escherichia)
 if [[ ${especie} == ${gene} ]]; then
echo -e "If control: ${genero} ${gene}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${assembly} \
          --organism ${especie} \
          --plus \
          --mutation_all /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_${especie}_temp.tsv \
          --nucleotide_output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_nuc_${especie}.fa \
          --output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_${especie}_temp.tsv

        else

#echo -e "Else control: ${genero} ${gene}"
#echo -e "Else control: ${ID_org} ${ID}"

continue

         fi
        fi
        ;;
     esac

     done
  done
done

# ---------------------------
# Eliminar archivos sin peso
#----------------------------

find /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/ -type f -size 0 -exec rm -f {} \;

# ----------------------------------------------------------------------------------------------------------------
# Mover los archivos de nucleotidos de las regiones identificadas por AMRFinder de cada muestra a una sola carpeta
# ----------------------------------------------------------------------------------------------------------------

mkdir -p /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/Nucleotide
mv /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/*nuc* /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/Nucleotide

# -----------------------------------------------------------------
# Filtrar los archivos para solo obtener los genes y mutaciones RAM
# -----------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/

for genes in ./*_gen_*; do
    mutaciones=${genes/_gen_/_mut_}
    ID=$(basename ${genes} | cut -d '_' -f '1')
    especie=$(basename ${genes} | cut -d '_' -f '3')

cat ${genes} | tr " " "_" | awk '{print $6"\t"$11"\t"$9"\t"$7"\t"$2"\t"$3"\t"$4"\t"$5"\t"$14"\t"$15"\t"$16"\t"$17"\t"$13}' | grep AMR > /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_${especie}_filt_tmp.tsv

sed -i '1i Gene_symbol\tClass\tElement_type\tSequence_name\tContig_id\tStart\tStop\tStrand\tTarget_length\tReference_sequence_length\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence\tMethod' /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_${especie}_filt_tmp.tsv

cat ${mutaciones} | tr " " "_" | awk '{print $6"\t"$11"\t"$12"\t"$7"\t"$2"\t"$9"\t"$10"\t"$16"\t"$17}' | grep AMR > /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_${especie}_filt_tmp.tsv

sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_${especie}_filt_tmp.tsv

done

rm *temp*

# ---------------------------------------------------------------
# Conjuntar los archivos de genes y mutaciones en un solo archivo
# ---------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder

for file in /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for gen in ./*_gen_*; do
    ename=$(basename ${gen} | cut -d '_' -f '1')
    spg=$(basename ${gen} | cut -d '_' -f '3')

 if [[ ${gene} == ${spg} ]]; then
echo -e "\n${ename} \n$(cat ${gen})"

        else
  continue
fi
   done >> ./GenesAMRF_${gene}_all.tsv
done
#####
for file in /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')


for mut in ./*_mut_*; do
    ename=$(basename ${mut} | cut -d '_' -f '1')
    spm=$(basename ${mut} | cut -d '_' -f '3')

if [[ ${gene} == ${spm} ]]; then
echo -e "\n${ename} \n$(cat ${mut})"

         else
  continue
fi
    done >> ./MutacionesAMRF_${gene}_all.tsv
done

rm *tmp*
rm /home/secuenciacion_cenasa/Analisis_corridas/kmerfinder/bacteria/*.spa

echo -e "#########################################"
echo -e         ===== Fin: $(date) =====
echo -e "#########################################"

