#!/bin/bash

echo -e "#########################################################################################" "\n"
echo -e  ===== Identificación de genes de RAM en ensambles bacterianos con AMRFinderPlus ===== "\n"
echo -e                             ===== Inicio: $(date) ===== "\n"
echo -e "##########################################################################################" "\n"

#Para actualizar la base de datos de AMRFinder: amrfinder -u
#Para conocer la lista de organismos disponibles para la opción --organism: amrfinder -l

#---------------------------------------------------------------------------------
dirfa="$HOME/Analisis_corridas/SPAdes/bacteria"
dirout="$HOME/Analisis_corridas/AMRFinder"
dirkmer="$HOME/Analisis_corridas/kmerfinder/bacteria"
dirdb="$HOME/Programas_bioinformaticos/amr-amrfinder_v4.2.7/data/2026-01-21.1"
#---------------------------------------------------------------------------------

cd ${dirfa}

for RAM in *.fa; do
    ID=$(basename ${RAM} | cut -d '-' -f '1')

amrfinder --nucleotide ${RAM} \
          -d ${dirdb} \
          --plus \
          --output ${dirout}/${ID}_gen_temp.tsv

done

#---------------------------------------------------------------------------------------------------------------

echo -e "##############################################################################################" "\n"
echo -e  ===== Identificación de mutaciones de RAM en ensambles bacterianos con AMRFinderPlus ===== "\n"
echo -e                          ===== Inicio: $(date) ===== "\n"
echo -e "##############################################################################################" "\n"

#-----------------------------------------------------------------------------------------------------------------

for especie in  Salmonella \
                Escherichia \
				Campylobacter \
				Enterococcus_faecalis \
				Enterococcus_faecium \
				Staphylococcus_aureus; do
    genero=$(basename ${especie} | cut -d '_' -f '1')
echo -e "Genero: ${genero}"

for file in ${dirkmer}/*.spa; do
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

amrfinder --nucleotide ${AMR} -d ${dirdb} --organism Salmonella --mutation_all ${dirout}/${ID}_mut_temp.tsv

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

amrfinder --nucleotide ${AMR} -d ${dirdb} --organism Escherichia --mutation_all ${dirout}/${ID}_mut_temp.tsv

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

amrfinder --nucleotide ${AMR} -d ${dirdb} --organism Enterococcus_faecalis --mutation_all ${dirout}/${ID}_mut_temp.tsv

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

amrfinder --nucleotide ${AMR} -d ${dirdb} --organism Staphylococcus_aureus --mutation_all ${dirout}/${ID}_mut_temp.tsv

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

cd ${dirout}

#
if compgen -G "./*_gen_temp.tsv" > /dev/null; then
	for genes in *_gen_*; do
            ID=$(basename ${genes} | cut -d '_' -f '1')

cat ${genes} | tr " " "_" | awk '{print $6"\t"$11"\t"$9"\t"$7"\t"$2"\t"$3"\t"$4"\t"$5"\t"$14"\t"$15"\t"$16"\t"$17"\t"$13}' | grep AMR > ./${ID}_gen_filt_tmp.tsv
sed -i '1i Gene_symbol\tClass\tElement_type\tSequence_name\tContig_id\tStart\tStop\tStrand\tTarget_length\tReference_sequence_length\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence\tMethod' ./${ID}_gen_filt_tmp.tsv

        done
fi

#
if compgen -G "./*_mut_temp.tsv" > /dev/null; then
	for mutaciones in *_mut_*; do
            ID=$(basename ${mutaciones} | cut -d '_' -f '1')

cat ${mutaciones} | tr " " "_" | awk '{print $6"\t"$11"\t"$12"\t"$7"\t"$2"\t"$9"\t"$10"\t"$16"\t"$17}' | grep AMR > ./${ID}_mut_filt_all.tsv
sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' ./${ID}_mut_filt_all.tsv

        done
fi

#
if compgen -G "./*_mut_filt_all.tsv" > /dev/null; then
	for mut in *mut_filt*; do
            ID=$(basename ${mut} | cut -d '_' -f '1')
cat ${mut} | tr " " "_" | grep resist > ./${ID}_mutresist_tmp.tsv
sed -i '1i Gene_symbol\tClass\tSubclass\tSequence_name\tContig_id\tElement_type\tElement_subtype\t%_Coverage_of_reference_sequence\t%_Identity_to_reference_sequence' ./${ID}_mutresist_tmp.tsv

	done
fi

#
cd ${dirout}

if compgen -G "./*_gen_filt_tmp.tsv" > /dev/null; then
	for gen in *_gen_filt_tmp.tsv; do
            ename=$(basename ${gen} | cut -d '_' -f '1')

echo -e "\n########## ${ename} ########## \n$(cat ${gen})"
	done >> ./GenesAMRF_all.tsv
rm ./*gen_filt*
	fi

#
if compgen -G "./*_mutresist_tmp.tsv" > /dev/null; then
	for mut in *mutresist*; do
	    ename=$(basename ${mut} | cut -d '_' -f '1')

echo -e "\n########## ${ename} ########## \n$(cat ${mut})"
	done >> ./MutacionesAMRF_all.tsv
rm *mutresist_tmp*
rm *_mut_filt*
	fi

rm ./*temp*

rm ${dirkmer}/*.spa

echo -e  "###############################################################" "\n"
echo -e                    ===== Fin: $(date) ===== "\n"
echo -e  "###############################################################" "\n"

