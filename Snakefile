TEST_SAMPLES = ["SRR7426784", "SRR7426785", "SRR7426786"] 

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
