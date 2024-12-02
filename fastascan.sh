#!/bin/bash

############################## Determine the folder where files will be searched and the number of lines that will be printed ##########################################
if [[ -z $1 ]]; then fold=.; N=0 #If user dosen't provide any argument, current folder and 0 will be used. 
else
	if [[ -d $1 ]]; then 
		if [[ -x $1 && -r $1 ]]; then fold=$1 #If user writes as 1st argument the name of an existing folder with permissions, that one will be used. 
		else echo $1: Permission denied | grep --color "$1: Permission denied"; fold='Error' #But if the folder has restricted permissions, an error message will appear.
		fi
		if [[ -n $2 ]]; then 
			if echo $2 | grep -q '[0-9]'; then N=$2 #If there is a number as 2nd argument, that one will be used.
			else echo Warning: give a valid number | grep --color "Warning: give a valid number"; N=0 #If there is any other thing as 2nd argument, a warning message will appear and 0 will be used.
			fi
		else 
			N=0 #If user doesn't provide any 2nd argument, 0 will be used. 
		fi
	#In case user writes something other than an existing folder as 1st argument:
	elif echo $1 | grep -q '[0-9]'; then fold=. N=$1 #If it is a number, current folder and that number will be used.
	else echo $1: Dir not found | grep --color "$1: Dir not found"; fold='Error' #If it is any other thing, an error message will appear.
	fi
fi


########################################## Display the report of all fasta files in the analysed folder ################################################################
if [[ $fold != 'Error' ]]; then #In case there is no error (unexisting folder or with no permissions) the rest of the program will run.
	
	findfasta=$(find $fold -type f -name '*.fa' -or -name '*.fasta') #Save all fasta files into a variable.

	for i in $findfasta; 
	do
		if [[ -r $i ]]; then #Check ¡f the file is readable.
			awk '/>/{print $1}' $i >> all_id254762 #Save all IDs into a file (will be used for count the uniques IDs of the folder).

			seqs=$(awk '{ORS=""} !/>/{print $0}' $i | sed 's/[- ]//g') #Saves the entire sequence - without GAPs - of the file into a variable.
			
			#Write the header for each file and save them into a file:
				#1. Name of the file.
				#2. Check if it is a link or a real file.
				#3. Count how many lines contain ">" = number of sequences in the file.
				#4. Count how many nucleotides or aa are in the file.
				#5. If the sequence has any of these letters, it will be aa. But nucleotide letters can also be aa, so if the sequence is shorter than 5, we cannot be statistically sure that they are nucleotides. If it is longer, we can say that it is a nucleotide sequence.
			(echo "==>" $(basename $i)$'\t'\
				$(if [[ -h $i ]]; then echo Symbolic link; else echo Real file; fi)$'\t'\
				Number of sequences: $(awk '/>/{print "line"}' $i | wc -l)$'\t'\
				Total length: $(echo -n $seqs | wc -m)$'\t'\
				$(if echo $seqs | grep -q -i [DEQHILKMFPSWV]; then echo Aminoacid sequence; else if [[ $(echo -n $seqs | wc -m) -ge 5 ]]; then echo Genetic sequence; else echo Indetermined; fi; fi)$'\t'"<==") >> header254762
		else
			echo $i: Permission denied #If the file has restricted restricted permissions, a warning message will appear.
		fi
	done

	echo In $fold folder there are:
	echo - $(echo $findfasta | wc -w) fasta files. #Count how many fasta files there are. 
	echo - $(if [[ -e all_id254762 ]]; then cat all_id254762 | sort | uniq | wc -l; else echo 0; fi) uniques IDs. #Count how many uniques IDs there are.
	echo
	if [[ -e all_id254762 ]]; then rm all_id254762; fi #Remove the file previously created.

	cont=0
	for i in $findfasta;
	do
		if [[ -r $i ]]; then #Check ¡f the file is readable.
			cont=$((cont+1))
			column -t -s $'\t' header254762 | awk -v line=$cont -F’\t’ 'NR==line {print $0}' #Read the headers as a table with columns, and prints one header for each file.

			if [[ $N -eq 0 ]]; then #If N=0, this step is skipped.
				continue
			elif [[ $(cat $i | wc -l) -le $((2*$N)) ]]; then cat $i #If the file has 2N lines or fewer, its full content will be printed.
			else #If the file is larger, its first and last N lines will be printed.
				head -n $N $i
				echo  ...
				tail -n $N $i
			fi
			echo
			echo;
		fi
	done

	if [[ -e header254762 ]]; then rm header254762; fi #Remove the file previously created.
fi



