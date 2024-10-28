if [[ -n $2 ]]
then
	numero=$2
else
	numero=3
fi

if [[ $(cat $1 | wc -l) -le $((2*numero)) ]]
then 
	cat $1
else
	echo Warning: file contains more lines than required
	head -n $numero $1
	echo ...
	tail -n $numero $1
fi