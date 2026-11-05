batch_file="$1"
failed=0

while IFS= read -r sample || [[ -n "$sample" ]]; do
    [[ -z "$sample" ]] && continue
    bam="results/aligned/${sample}_sorted.bam"

    if samtools quickcheck -v "$bam"; then
        printf '%s\tPASS\n' "$sample"
    else
        printf '%s\tFAIL\n' "$sample"
        failed=1
    fi
done < "$batch_file"

exit "$failed"