GENOME_INDEX = "reference/grch38_tran/genome_tran"
GTF = "reference/Homo_sapiens.GRCh38.115.gtf"

if "batch" in config:
# Read the selected batch.
    batch_id = int(config["batch"])
    batch_path = f"data/batches/batch_{batch_id:02d}.txt"

    with open(batch_path) as batch_file:
        batch_samples = [
            line.strip()
            for line in batch_file
            if line.strip()
        ]

# Request the final index files for this batch.
    rule batch:
        input:
            expand( "results/aligned/{sample}_sorted.bam.bai", sample=batch_samples)

# MultiQC
    rule multiqc:
        input:
            expand("results/qc/{sample}_fastqc.zip", sample=batch_samples)
        output:
            f"results/qc/batch_{batch_id:02d}/multiqc_report.html"
        params:
            outdir = f"results/qc/batch_{batch_id:02d}/"
        shell:
            "multiqc -f {input:q} -o {params.outdir:q}"

# Construct the all samples list
with open("data/batches/all_samples.txt") as samples_file:
    all_samples = [
        line.strip()
        for line in samples_file
        if line.strip()
    ]

# FastQC on raw reads
rule fastqc:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        html = "results/qc/{sample}_fastqc.html",
        zip = "results/qc/{sample}_fastqc.zip"
    params:
        outdir = "results/qc/"
    threads: 2
    shell:
        "fastqc {input} -o {params.outdir} -t {threads}"


# MultiQC for all samples
rule multiqc_all:
    input:
        expand("results/qc/{sample}_fastqc.zip", sample=all_samples)
    output:
        "results/qc/all_samples/multiqc_report.html"
    params:
        outdir = "results/qc/all_samples/"
    shell:
        "multiqc -f {input:q} -o {params.outdir:q}"

# HISAT2 alignment
rule hisat2_alignment:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        temp("results/aligned/{sample}.sam")
    params:
        index = GENOME_INDEX
    threads: 8
    log:
        summary = "logs/hisat2/{sample}.summary.txt",
        stderr = "logs/hisat2/{sample}.stderr.log"
    shell:
        "hisat2 -x {params.index:q} -U {input:q} -S {output:q} " 
        "-p {threads} --rna-strandness R "
        "--summary-file {log.summary:q} 2> {log.stderr:q}"

    # Sort SAM into BAM
rule sort_bam:
    input:
        "results/aligned/{sample}.sam"
    output:
        "results/aligned/{sample}_sorted.bam"
    threads: 4
    log:
        "logs/samtools/{sample}_sort.log"
    shell:
        "samtools sort {input:q} -o {output:q} -@ {threads} "
        "-m 512M 2> {log:q}"

# Remove mitochondrial reads (optional)
rule remove_mitoch:
    input:
        "results/aligned/{sample}_sorted.bam"
    output:
        "results/aligned/{sample}_nomito.bam"
    threads: 4
    shell:
        "samtools view -b -e 'rname !=\"MT\"' {input} -o {output} -@ {threads}"

# Before and after mitochondrial read removal stats (optional)
rule mito_stats:
    input:
        before = "results/aligned/{sample}_sorted.bam",
        after = "results/aligned/{sample}_nomito.bam"
    output: 
        "results/qc/{sample}_mito_stats.txt"
    shell:
        """
        echo 'Before mitochondrial read removal:' > {output}
        samtools flagstat {input.before} >> {output}
        echo 'After mitochondrial read removal:' >> {output}
        samtools flagstat {input.after} >> {output}
        """

# BAM index
rule index_bam:
    input:
        "results/aligned/{sample}_sorted.bam"
    output:
        "results/aligned/{sample}_sorted.bam.bai"
    threads: 2
    shell:
        "samtools index {input:q} -@ {threads:q}"

# featureCounts
rule featurecounts:
    input:
        bams = expand("results/aligned/{sample}_sorted.bam", sample=all_samples),
        bais = expand("results/aligned/{sample}_sorted.bam.bai", sample=all_samples)
    output:
        "results/counts/featurecounts_matrix.txt"
    params:
        gtf = GTF
    threads: 4
    shell:
        "featureCounts -a {params.gtf:q} -o {output:q} -T {threads} -s 2 {input.bams:q}"