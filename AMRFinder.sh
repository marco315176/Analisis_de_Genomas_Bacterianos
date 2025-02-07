#!/bin/bash

echo -e "#########################################################################################" "\n"

echo -e "\t" ===== Identificación de genes de RAM en ensambles bacterianos con AMRFinderPlus ===== "\n"

echo -e           "\t"               ===== Inicio: $(date) ===== "\n"

echo -e "##########################################################################################" "\n"

#Para actualizar la base de datos de AMRFinder: amrfinder -u
#Para conocer la lista de organismos disponibles para la opción --organism: amrfinder -l

# -------------------------------------------
# Correr AMRFinder para identificar genes RAM
#--------------------------------------------
cd /home/admcenasa/Analisis_corridas/SPAdes/bacteria

for RAM in *.fa; do
    ID=$(basename ${RAM} | cut -d '-' -f '1')

amrfinder --nucleotide ${RAM} --plus --nucleotide_output /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_nuc.fa --output /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_gen_temp.tsv

done

#----------------------------------------------------
# Correr AMRFinder para identificar mutaciones de RAM
#----------------------------------------------------

echo -e "##############################################################################################" "\n"

echo -e "\t" ===== Identificación de mutaciones de RAM en ensambles bacterianos con AMRFinderPlus ===== "\n"

echo -e           "\t"               ===== Inicio: $(date) ===== "\n"

echo -e "##############################################################################################" "\n"

for especie in  Salmonella Escherichia Campylobacter Enterobacter_cloacae Enterococcus_faecalis Enterococcus_faecium Staphylococcus_aureus; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

for file in /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*.spa; do
    gene=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID_org=$(basename ${file} | cut -d '_' -f '1')

for AMR in *.fa; do
    ID=$(basename ${AMR} | cut -d '-' -f '1')

########################################################
########### Mutaciones de RAM para Salmonella ##########
########################################################
case ${especie} in Salmonella)
     if [[ ${genero} == ${gene} ]]; then
echo -e "If control: ${genero} ${gene}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${AMR} --organism Salmonella --mutation_all /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_mut_temp.tsv

else
        continue
     fi
   fi
 ;;
########################################################
########### Mutaciones de RAM para Escherichia #########
########################################################
                  Escherichia)
     if [[ ${genero} == ${gene} ]]; then
echo -e "If control: ${genero} ${gene}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${AMR} --organism Escherichia --mutation_all /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_mut_temp.tsv

else
        continue
     fi
   fi
 ;;
###################################################################
########### Mutaciones de RAM para Enterococcus_faecalis ##########
###################################################################
                  Enterococcus_faecalis)
     if [[ ${especie} == ${organism} ]]; then
echo -e "If control: ${especie} ${organism}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${AMR} --organism Enterococcus_faecalis --mutation_all /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_mut_temp.tsv

else
        continue
     fi
   fi
 ;;
###################################################################
########### Mutaciones de RAM para Staphylococcus_aureus ##########
###################################################################
                  Staphylococcus_aureus)
     if [[ ${especie} == ${organism} ]]; then
echo -e "If control: ${especie} ${organism}"
    if [[ ${ID_org} == ${ID} ]]; then
echo -e "If control: ${ID_org} ${ID}"

amrfinder --nucleotide ${AMR} --organism Staphylococcus_aureus --mutation_all /home/admcenasa/Analisis_corridas/AMRFinder/${ID}_mut_temp.tsv

#else
 #       continue
  #   fi
   #fi
 #;;

           fi
         fi
      esac
    done
  done
done

# ---------------------------
# Eliminar archivos sin peso
#----------------------------
#find /home/admcenasa/Analisis_corridas/AMRFinder/ -type f -size 0 -exec rm -f {} \;
#if compgen -G "./*_nuc.fa" > /dev/null; then
#mkdir -p /home/admcenasa/Analisis_corridas/AMRFinder/Nucleotide
#mv /home/admcenasa/Analisis_corridas/AMRFinder/*nuc* /home/admcenasa/Analisis_corridas/AMRFinder/Nucleotide
#fi

if compgen -G "/home/admcenasa/Analisis_corridas/AMRFinder/*_nuc.fa" > /dev/null; then
    mkdir -p "/home/admcenasa/Analisis_corridas/AMRFinder/Nucleotide"
    mv /home/admcenasa/Analisis_corridas/AMRFinder/*_nuc.fa "/home/admcenasa/Analisis_corridas/AMRFinder/Nucleotide"
fi

# -----------------------------------------------------------------
# Filtrar los archivos para solo obtener los genes y mutaciones RAM
# -----------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/AMRFinder

#Genes RAM
if compgen -G "./*_gen_temp.tsv" > /dev/null; then
	for genes in *_gen_*; do
            ID=$(basename ${genes} | cut -d '_' -f '1')

cat ${genes} | tr " " "_" | awk '{print $6"\t"$11"\t"$9"\t"$7"\t"$2"\t"$3"\t"$4"\t"$5"\t"$14"\t"$15"\t"$16"\t"$17"\t"$13}' | grep AMR > ./${ID}_gen_filt_tmp.tsv
sed -i '1i Gene_symbol\tClass\tElement_type\tSequence_name\tContig_id\tStart\tStop\tStrand\tTarget_length\tReference_sequence_length\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence\tMethod' ./${ID}_gen_filt_tmp.tsv

        done
fi

#Mutaciones RAM
if compgen -G "./*_mut_temp.tsv" > /dev/null; then
	for mutaciones in *_mut_*; do
            ID=$(basename ${mutaciones} | cut -d '_' -f '1')

cat ${mutaciones} | tr " " "_" | awk '{print $6"\t"$11"\t"$12"\t"$7"\t"$2"\t"$9"\t"$10"\t"$16"\t"$17}' | grep AMR > ./${ID}_mut_filt_all.tsv
sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' ./${ID}_mut_filt_all.tsv

        done
fi

#Mutaciones AMR identificadas
if compgen -G "./*_mut_filt_all.tsv" > /dev/null; then
	for mut in *mut_filt*; do
            ID=$(basename ${mut} | cut -d '_' -f '1')
cat ${mut} | tr " " "_" | grep resist > ./${ID}_mutresist_tmp.tsv
sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' ./${ID}_mutresist_tmp.tsv

	done
fi
# ---------------------------------------------------------------
# Conjuntar los archivos de genes y mutaciones en un solo archivo
# ---------------------------------------------------------------

##### Genes #####
cd /home/admcenasa/Analisis_corridas/AMRFinder

if compgen -G "./*_gen_filt_tmp.tsv" > /dev/null; then
	for gen in *_gen_filt_tmp.tsv; do
            ename=$(basename ${gen} | cut -d '_' -f '1')

echo -e "\n########## ${ename} ########## \n$(cat ${gen})"
	done >> ./GenesAMRF_all.tsv
rm ./*gen_filt*
	fi

##### Mutaciones #####

if compgen -G "./*_mutresist_tmp.tsv" > /dev/null; then
	for mut in *mutresist*; do
	    ename=$(basename ${mut} | cut -d '_' -f '1')

echo -e "\n########## ${ename} ########## \n$(cat ${mut})"
	done >> ./MutacionesAMRF_all.tsv
rm *mutresist_tmp*
rm *_mut_filt*
	fi

rm ./*temp*
#rm *gen_filt*
#rm *mutresist_tmp*
#rm *_mut_filt*

rm /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/*spa

echo -e  "###############################################################"
echo -e "\t"                    ===== Fin: $(date) =====
echo -e  "###############################################################"

