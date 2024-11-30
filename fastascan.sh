#Establecemos por defecto que la carpeta sea la actual.
if [[ -z $1 ]]; then fold=. N=0;
elif [[ -n $1 && -n $2 ]]; then fold=$1 N=$2;
elif [[ -n $1 && -z $2 ]]; then
	if [[ $1 != [0123456789] ]]; then fold=$1 N=0;
	else
		if ls $1 . > out254762; then fold=$1 N=0; #HAgo esta comprobación por si la carpeta es un número.
		else fold=. N=$1;
		fi;
	fi;
fi

ls $fold . > out254762 || fold=. #por si la carpeta no existe
rm out254762

echo carpeta: $fold
echo numero:  $N
echo
echo
echo ===================

findfasta=$(find $fold -type f -name '*.fa' -or -name '*.fasta')

for i in $findfasta;
do
	#Creamos el archivo all_id, donde guardamos todas las secuencias.
	if [[ -s $i ]]; then
		awk '/>/{print $1}' $i >> all_id
		fi; 

	#Y ahora vamos a crear un archivo con los headers para poderlo poner con columnas bonitas
	seqs=$(awk '{ORS=""} !/>/{print $0}' $i | sed 's/[- ]//g');
	(echo $(basename $i)^I$(if [[ -h $i ]]; then 
		echo Symbolic link; 
	else 
		echo Real file; fi)^INumber of sequences: $(awk '/>/{print "line"}' $i | wc -l)^ITotal length: $(echo -n $seqs | wc -m)^I$(echo $seqs | if [[ -n $(grep -i [DEQHILKMFPSWV]) ]]; then 
		echo Aminoacid sequence; 
	else 
		echo Genetic sequence; fi)) >> a
done


echo In this folder there are:
echo - $(echo $findfasta| wc -w) fasta files.
echo - $(cat all_id | sort | uniq | wc -l) uniques IDs.
echo 
rm all_id


for i in $findfasta;
do
	column -t -s'^I' a | awk -F’\t’ '$1~/example1.fasta/{print $0}'

	if [[ $N -eq 0 ]]; then
		continue
	elif
		[[ $(cat $i | wc -l) -le $((2*$N)) ]]; then
		cat $i
	else
		echo Warning: file contains more lines than required | grep --color "Warning: file contains more lines than required"
		head -n $N $i
		echo ... | grep --color "..."
		tail -n $N $i
	fi;
	echo; 
done

rm a





