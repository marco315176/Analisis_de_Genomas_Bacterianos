find . -type f -iname "*.fasta" -exec cp "{}" /home/secuenciacion_cenasa/MBovis_seq/ \; #Si se buscan archivos en general

find /backup/ -type f -iname "*.fa" | grep -Ff ids.txt | while IFS= read -r file; do cp "$file" /home/admcenasa/IPSN/; done #Si se cuenta con un archivo con ID's para identificar
