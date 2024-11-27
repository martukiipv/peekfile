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
echo ============================
rm uniq_files

rm a
find $fold -type f -name '*.fa' -or -name '*.fasta' | while read i;
do 
	seqs=$(awk '{ORS=""} !/>/{print $0}' $i | sed 's/[- ]//g');
	echo $(basename $i) $(if [[ -h $i ]]; then echo Symbolic link; else echo Real file; fi) Number of sequences: $(awk '/>/{print "line"}' $i | wc -l) $(echo -n $seqs | wc -m) $(echo $seqs | if [[ -n $(grep -i [DEQHILKMFPSWV]) ]]; then 
		echo Aminoacid sequence; 
	else 
		echo Genetic sequence; fi);
	echo; 
done










