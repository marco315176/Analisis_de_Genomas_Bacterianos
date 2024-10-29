#!/bin/bash

echo -e "#####################################################################" "\n"

echo -e "\t" ===== Análisis de SNP's entre secuencias con kSNP4 ===== "\n"

echo -e          "\t" "\t" ===== Inicio: $(date) ===== "\n"

echo -e "#####################################################################" "\n"


cd /home/secuenciacion_cenasa/Analisis_corridas/kSNP4

#Generar el archivo de entrada
MakeKSNP4infile -indir /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Secuencias -outfile ./Analisis.in

#Calcular la longitud ideal de k
Kchooser4 -in ./Analisis.in > ./Kchooser4_Analisis.report

cat ./Kchooser4_Analisis.report | grep "The optimum value of k is" > optimum_k.txt
k=$(cat optimum_k.txt | cut -d ' ' -f '8')
echo -e "El valor optimo de k es: ${k}"

#Ejecutar kSNP4
kSNP4 -in ./Analisis.in \
      -k ${k} \
      -outdir /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Resultados \
      -vcf \
      -ML \
      -NJ
#-core


mv /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Resultados/NJ.dist.matrix /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Resultados/SNP_matrix.matrix
#rm /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Resultados/*parsimony*
rm /home/secuenciacion_cenasa/Analisis_corridas/kSNP4/Resultados/*NJ*
rm Analisis.in  Kchooser4_Analisis.report  Kchooser4_.report  optimum_k.txt


