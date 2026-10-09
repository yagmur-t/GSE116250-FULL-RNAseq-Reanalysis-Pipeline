TEST_SAMPLES = ["SRR7426784", "SRR7426785", "SRR7426786"]
GENOME_INDEX = "reference/grch38_tran/genome_tran"
GTF = "reference/Homo_sapiens.GRCh38.115.gtf"

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

# MultiQC
rule multiqc:
    input:
        expand("results/qc/{sample}_fastqc.zip", sample=TEST_SAMPLES)
    output:
        "results/qc/multiqc_report.html"
    params:
        indir = "results/qc/",
        outdir = "results/qc/"
    shell:
        "multiqc {params.indir} -o {params.outdir}"

# QC Quality Control, flag failed samples
rule flag_qc_fails:
    input:
        expand("results/qc/{sample}_fastqc.zip", sample=TEST_SAMPLES)
    output:
        "results/qc/qc_flags.txt"
    shell:
        """
        > {output}
        for sample_zip in {input}
        do
            sample=$(basename $sample_zip _fastqc.zip)
            unzip -p $sample_zip ${{sample}}_fastqc/summary.txt | grep FAIL >> {output}
        done
        """

# HISAT2 alignment
rule hisat2_alignment:
    input:
        "data/raw/{sample}.fastq.gz"
    output:
        "results/aligned/{sample}.sam"
    params:
        index = GENOME_INDEX
    threads: 4
    log:
        "logs/hisat2/{sample}.log"
    shell:
        "hisat2 -x {params.index} -U {input} -S {output} -p {threads} --summary-file {log}"