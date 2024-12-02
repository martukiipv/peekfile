#Establecemos por defecto que la carpeta sea la actual.
if [[ -z $1 ]]; then fold=.; N=0
else
	if [[ -d $1 ]]; then
		if [[ -x $1 && -r $1 ]]; then fold=$1
		else echo $1: Permission denied | grep --color "$1: Permission denied"; fold='Warning'
		fi
		if [[ -n $2 ]]; then
			if echo $2 | grep -q '[0-9]'; then N=$2
			else echo Warning: give a valid number | grep --color "Warning: give a valid number"; N=0
			fi
		else 
			N=0
		fi
	elif echo $1 | grep -q '[0-9]'; then fold=. N=$1
	else echo $1: Dir not found | grep --color "$1: Dir not found"; fold='Warning'
	fi
fi

if [[ $fold != 'Warning' ]]; then
	
	findfasta=$(find $fold -type f -name '*.fa' -or -name '*.fasta')

	for i in $findfasta;
	do
		if [[ -r $i ]]; then
			#Creamos el archivo all_id, donde guardamos todas las secuencias.
			awk '/>/{print $1}' $i >> all_id254762

			#Y ahora vamos a crear un archivo con los headers para poderlo poner con columnas bonitas
			seqs=$(awk '{ORS=""} !/>/{print $0}' $i | sed 's/[- ]//g');
			(echo "==>" $(basename $i)$'\t'\
				$(if [[ -h $i ]]; then echo Symbolic link; else echo Real file; fi)$'\t'\
				Number of sequences: $(awk '/>/{print "line"}' $i | wc -l)$'\t'\
				Total length: $(echo -n $seqs | wc -m)$'\t'\
				$(if echo $seqs | grep -q -i [DEQHILKMFPSWV]; then echo Aminoacid sequence; else if [[ $(echo -n $seqs | wc -m) -ge 5 ]]; then echo Genetic sequence; else echo Indetermined; fi; fi)$'\t'"<==") >> header254762
		else
			echo $i: Permission denied
		fi
	done


	echo In this folder there are:
	echo - $(echo $findfasta| wc -w) fasta files.
	echo - $(if [[ -e all_id254762 ]]; then cat all_id254762 | sort | uniq | wc -l; else echo 0; fi) uniques IDs.
	echo
	if [[ -e all_id254762 ]]; then rm all_id254762; fi

	cont=0
	for i in $findfasta;
	do
		if [[ -r $i ]]; then
			cont=$((cont+1))
			column -t -s $'\t' header254762 | awk -v line=$cont -F’\t’ 'NR==line {print $0}'

			if [[ $N -eq 0 ]]; then
				continue
			elif
				[[ $(cat $i | wc -l) -le $((2*$N)) ]]; then
				cat $i
			else
				head -n $N $i
				echo ...
				tail -n $N $i
			fi
			echo;
		fi
	done

	if [[ -e header254762 ]]; then rm header254762; fi
fi



