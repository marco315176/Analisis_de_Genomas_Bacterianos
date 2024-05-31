#!/bin/bash

echo -e "####################################################################################"

echo -e ===== Identificación de genes de RAM en ensambles bacterianos con AMRFinderPlus =====

echo -e                           ===== Inicio: $(date) =====

echo -e "#####################################################################################"

#Para actualizar la base de datos de AMRFinder: amrfinder -u

cd /home/secuenciacion_cenasa/Analisis_corridas/SPAdes_bacterial


# ------------------------------------
# Definir especie y género bacterianos
# ------------------------------------

#Para conocer la lista de organismos disponibles para la opción --organism: amrfinder -l

for especie in Salmonella Escherichia Campylobacter Enterococcus_faecalis Enterococcus_faecium; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

# --------------------------------------------------------
# Loop para cada ensamble de la carpeta donde nos ubicamos
# --------------------------------------------------------

for assembly in *.fa; do
    ID=$(basename ${assembly} | cut -d '-' -f '1')

# ---------------------------------------------------------------------------------------------------
# Correr AMRFinderPlus sobre los ensambles obtenidos para la identificación de genes y mutaciones RAM
# ---------------------------------------------------------------------------------------------------

case ${especie} in Salmonella)
     if [[ ! -f AMRFinderPlus_tmp_${genero}.tsv ]]; then

amrfinder --nucleotide ${assembly} \
          --organism ${especie} \
          --plus \
          --mutation_all /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_tmp.tsv \
          --nucleotide_output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_nuc.fa \
          --output /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_tmp_amrf.tsv

fi
esac

# -------------------------------------------------------------------------------------------------------
# Filtrar el archivo de resultados de los genes y mutaciones para solo mostrar los genes y mutaciones AMR
# -------------------------------------------------------------------------------------------------------

cat /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_tmp_amrf.tsv | tr " " "_" | awk '{print $6"\t"$11"\t"$9"\t"$7"\t"$2"\t"$3"\t"$4"\t"$5"\t"$14"\t"$15"\t"$16"\t"$17"\t"$13}' | grep AMR > /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_filt_tmp.tsv

sed -i '1i Gene_symbol\tClass\tElement_type\tSequence_name\tContig_id\tStart\tStop\tStrand\tTarget_length\tReference_sequence_length\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence\tMethod' /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_filt_tmp.tsv

cat /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_tmp.tsv | tr " " "_" | awk '{print $6"\t"$11"\t"$12"\t"$7"\t"$2"\t"$9"\t"$10"\t"$16"\t"$17}' | grep AMR > /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_filt_tmp.tsv

sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_filt_tmp.tsv

done 
done

rm /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_mut_tmp.tsv /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder/${ID}_gen_tmp_amrf.tsv

# ---------------------------------------------------------------
# Conjuntar los archivos de genes y mutaciones en un solo archivo
# ---------------------------------------------------------------

cd /home/secuenciacion_cenasa/Analisis_corridas/AMRFinder

for file in *_gen_filt_*; do 
    ename=$(basename ${file} | cut -d '_' -f '1')
echo -e "\n${ename} \n$(cat ${file})"

done >> ./GenesAMRF_all.tsv

for file in *mut_filt*; do
    ename=$(basename ${file} | cut -d '_' -f '1')
echo -e "\n${ename} \n$(cat ${file})"

done >> ./MutacionesAMRF_all.tsv

# ----------------------------------------------------------------------------------------------------------------
# Mover los archivos de nucleotidos de las regiones identificadas por AMRFinder de cada muestra a una sola carpeta
# ----------------------------------------------------------------------------------------------------------------

mkdir -p Nucleotide
mv *nuc* ./Nucleotide
rm *tmp*

echo -e "#########################################"
echo -e         ===== Fin: $(date) =====
echo -e "#########################################"
