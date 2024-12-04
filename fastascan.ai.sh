#!/bin/bash

# Script to analyze FASTA files in a directory and generate a report.

# Function to display an error message and exit
error_exit() {
    echo -e "\e[31mError: $1\e[0m" >&2
    exit 1
}

# Validate input arguments
directory=${1:-.}  # Default directory: current folder
N=${2:-0}          # Default number of lines: 0

# Check if the directory is valid and accessible
if [[ ! -d $directory ]]; then
    error_exit "$directory is not a valid directory."
elif [[ ! -r $directory || ! -x $directory ]]; then
    error_exit "Permission denied for accessing the directory $directory."
fi

# Find FASTA files in the directory
fasta_files=$(find "$directory" -type f \( -name "*.fa" -o -name "*.fasta" \))

if [[ -z $fasta_files ]]; then
    echo "No FASTA files found in the directory $directory."
    exit 0
fi

# Report on found FASTA files
unique_ids=()  # Array to store unique IDs

echo "Analyzing FASTA files in the directory: $directory"

for file in $fasta_files; do
    if [[ -r $file ]]; then
        # Extract IDs and sequences
        ids=$(awk '/^>/{print $1}' "$file")
        unique_ids+=($ids)
        
        seqs=$(awk 'BEGIN{ORS="";} !/^>/{print $0}' "$file" | sed 's/[- ]//g')

        # Determine sequence type
        if [[ $seqs =~ [DEQHILKMFPSWV] ]]; then
            seq_type="Amino Acids"
        elif [[ ${#seqs} -ge 5 ]]; then
            seq_type="Genetic"
        else
            seq_type="Undetermined"
        fi

        # Display file information
        echo -e "File: $(basename "$file")"
        echo -e " - Type: $(if [[ -h $file ]]; then echo 'Symbolic Link'; else echo 'Real File'; fi)"
        echo -e " - Sequences: $(grep -c '^>' "$file")"
        echo -e " - Total Length: ${#seqs}"
        echo -e " - Sequence Type: $seq_type"

        # Print content based on N
        if [[ $N -gt 0 ]]; then
            total_lines=$(wc -l < "$file")
            if [[ $total_lines -le $((2 * N)) ]]; then
                cat "$file"
            else
                head -n "$N" "$file"
                echo "..."
                tail -n "$N" "$file"
            fi
            echo
        fi

    else
        echo "Permission denied for reading $file"
    fi
done

# Summary of unique IDs
echo -e "\\nSummary:"
echo "- FASTA files found: $(echo "$fasta_files" | wc -w)"
echo "- Unique IDs: $(printf "%s\\n" "${unique_ids[@]}" | sort -u | wc -l)"
