#!/bin/bash

echo -e "#################################################################################"
echo -e ===== Iniciando pipeline para análisis de genomas de aisamientos bacterianos =====
echo -e ===== Inicio del pipeine: $(date) =====
echo -e "#################################################################################"

# ---------------------------------------------------------------------------------------------------------
# Script para obtener estadisticos de lecturas crudas, reaizar trimming y obtener estadisticos pos-trimming
# ---------------------------------------------------------------------------------------------------------

bash estadisticas_lecturas_bacteria.sh 

# -------------------------------------------------------------------
# Script para realizar el ensamble con SPAdes con la opción --isolate
# -------------------------------------------------------------------

bash SPAdes_bacterial.sh

# -------------------------------------------------------------------------
# Script para btener las estadisticas de los ensambles obtenidos con SPAdes
# -------------------------------------------------------------------------

bash Estadisticos_ensamble_bacterial.sh

# -----------------------------------------------------------------------------------------------------------------------------------------------
# Scripts para realizar la identificación taxonómica de genero y especie, así como el MLST y formula antigénica de aisados de Salmonella y E.coli
# -----------------------------------------------------------------------------------------------------------------------------------------------

bash kmerfinder_bacteria.sh

#bash kraken2_bacterial.sh

bash stringMLST.sh

bash seqsero2.sh

bash serotypefinder.sh

# ------------------------------------------------
# Script para obtener genes de RAM de las muestras
# ------------------------------------------------

bash AMRFinder.sh

# ---------------------------------------------------------------------
# Script para mover todos los archivos de resultados a una sola carpeta
# ---------------------------------------------------------------------

bash results_bacteria.sh

echo -e "##############################################################################################"
echo -e ===== Pipeline de análisis de genomas bacterianos completado: $(date) =====
echo -e "##############################################################################################"
