#!/bin/bash

run_resfinder.py -ifa ~/Analisis_corridas/SPAdes_bacterial/1320-SPAdes-assembly.fa -s Salmonella -o ~/Analisis_corridas/resfinder/1320_RF_out -b /home/secuenciacion_cenasa/Programas_Bioinformaticos/ncbi-blast-2.15.0+/bin/blastn -k /home/secuenciacion_cenasa/Programas_Bioinformaticos/kma -db_res_kma $RESFINDER_DB_PATH -acq -c -db_point_kma $POINTFINDER_DB_PATH

