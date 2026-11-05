batch_file="$1"

while IFS= read -r sample || [[ -n "$sample" ]]; do
    [[ -z "$sample" ]] && continue
    printf '\n%s\n' "$sample"
    cat "logs/hisat2/${sample}.summary.txt"
done < "$batch_file"