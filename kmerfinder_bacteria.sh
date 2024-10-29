#!/bin/bash

echo -e "########################################################################################################################" "\n"

echo -e === Ejecutar kmerfinder sobre ensambles obtenidos con SPAdes para la identificación taxonómica de bacterias === "\n"

echo -e                                        ===== Inicio: $(date) ===== "\n"

echo -e "#########################################################################################################################" "\n"

cd /home/admcenasa/Analisis_corridas/SPAdes/bacteria

for assembly in *.fa*; do
    ID="$(basename ${assembly} | cut -d '-' -f '1')"
    ename="$(basename ${assembly} | cut -d '_' -f '1,2')"

# -----------------------------------------------------------------------
# Correr kmerfinder sobre los ensambles obtenidos con metaSPAdes o SPAdes
# -----------------------------------------------------------------------

kmerfinder.py -i ${assembly} \
              -db $KF_DB_PATH/bacteria/bacteria.ATG \
              -tax $KF_DB_PATH/bacteria/bacteria.tax \
              -o /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}

# ----------------------------------------------------------------------------------------------------------------------
# Mover los resultados .txt y .spa un directorio atras, añadiendoles el ID de su muestra y eliminar la carpeta /KF_${ID}
# ----------------------------------------------------------------------------------------------------------------------

mv /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}/results.txt /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/${ID}_results.txt
mv /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}/results.spa /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/${ID}_results.spa
rm -R /home/admcenasa/Analisis_corridas/kmerfinder/bacteria/KF_${ID}

done

# ------------------------------------------------------------------------------------
# Mover los ensambles a una carpeta nombrada con el genero del organismo identificado
# ------------------------------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/kmerfinder/bacteria


for file in *spa; do
    genero=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID=$(basename ${file} | cut -d '_' -f '1')

for assembly in /home/admcenasa/Analisis_corridas/SPAdes/bacteria/*.fa; do
    assembly_ID=$(basename ${assembly} | cut -d '-' -f '1')

if [[ ${ID} != ${assembly_ID} ]]; then
       continue
 else

mkdir -p /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/Ensambles/${genero}

echo -e "Moviendo ${assembly} a ${genero}"
     cp ${assembly} /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/Ensambles/${genero}

        fi
    done
done

# ------------------------------------------------------------------------------------
# Mover los archivos trimmiados a una carpeta nombrada con el genero del organismo identificado
# ------------------------------------------------------------------------------------

cd /home/admcenasa/Analisis_corridas/kmerfinder/bacteria

for file in *spa; do
    genero=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    organism=$(cat ${file} | sed -n '2p' | cut -d ' ' -f '2,3' | tr ' ' '_')
    ID=$(basename ${file} | cut -d '_' -f '1')

for trim in /home/admcenasa/Analisis_corridas/Archivos_postrim/bacteria/*fastq.gz; do
    trim_ID=$(basename ${trim} | cut -d '_' -f '1')

if [[ ${ID} != ${trim_ID} ]]; then
       continue
 else
mkdir -p /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/Archivos_trimming/${genero}

echo -e "Moviendo ${trim} a ${genero}"
     cp ${trim} /home/admcenasa/Analisis_corridas/Resultados_all_bacteria/Archivos_trimming/${genero}

        fi
    done
done


# -----------------------------------------------------
# Conjuntar los archivos .spa en uno solo de resultados
# -----------------------------------------------------

cd /home/admcenasa/Analisis_corridas/kmerfinder/bacteria

for file in *.spa; do
    ename="$(basename ${file} | cut -d '_' -f '1')"
    echo -e "\n ########## \t${ename} \t ########## \n$(cat ${file})"

done >> ./kmerfinder_results_all.tsv

rm *.txt
