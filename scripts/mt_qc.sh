printf 'sample\tprimary_mapped\tprimary_mt\tmt_pct\n'

while IFS= read -r sample || [[ -n "$sample" ]]; do
    [[ -z "$sample" ]] && continue
    bam="results/aligned/${sample}_sorted.bam"

    mapped=$(samtools view -c -F UNMAP,SECONDARY,SUPPLEMENTARY "$bam") || break
    mt=$(samtools view -c -F UNMAP,SECONDARY,SUPPLEMENTARY "$bam" MT) || break

    awk -v sample="$sample" -v mapped="$mapped" -v mt="$mt"\
        'BEGIN {printf "%s\t%d\t%d\t%.2f\n", sample, mapped, mt, 100 * mt / mapped}'
done < data/batches/batch_01.txt