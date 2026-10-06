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
