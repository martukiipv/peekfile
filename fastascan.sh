#Establecemos por defecto que la carpeta sea la actual.
if [[ -z $1 ]]; then fold=.; else fold=$1; fi

#Establecemos por defecto que el número de líneas sea 0.
if [[ -z $2 ]]; then N=0; else N=$2; fi

find $fold -type f -name '*.fa' -or -name '*.fasta' | while read i;
do
	if [[ -s $i ]]; then
		awk '/>/{print $1}' $i >> uniq_files
		fi; done

echo In this folder there are:
echo - $(find $fold -type f -name '*.fa' -or -name '*.fasta'| wc -l) fasta files.
echo - $(cat uniq_files | sort | uniq | wc -l) uniques IDs.
rm uniq_files

#find $fold -type f -name '*.fa' -or -name '*.fasta' | while read i;
#do 
	#echo $i $'\t' $(if [[ -h $i ]]; then echo Symbolic link; else echo Real file; fi) $'\t' Number of sequences: $(awk '/>/{print "line"}' $i | wc -l); 
#echo ; done



#Para contar la longitud de las secuencias 
#sed 's/[- \n]//g' $i | awk '/>/{print "-"} !/>/{print length($0)}' | while read j; do 
	#if [[ $j == - ]]; 
		#then N=0; else N=$((N+$j)); S=$N; fi; 
	#if [[ $S -gt $N ]]; 
		#then echo $S; fi; done


#Por si se trata de la sequencia total
#sed 's/[- \n]//g' example.fa | for i in $(awk '!/>/{print length($0)}'); do LEN=$((LEN + $i)); done; echo $LEN