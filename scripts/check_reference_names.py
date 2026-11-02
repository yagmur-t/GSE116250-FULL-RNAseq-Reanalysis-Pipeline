"""
This checks whether all sequence names in the GTF file exist in the 
HISAT2 index summary.
Reports GTF sequence names that are missing from the index.

Limitations:
- Compares only the names, does not verify the DNA sequence identity,
coordiante compatibility or annotation origin.
- It assumes the expected HUSAT2 summart and tab-delimited GTF formats.
"""

# Get reference sequence names from the index summary file.
index_names = set()

with open("reference/index_summary.txt") as summary_file:
    for line in summary_file:
        if line.startswith("Sequence-"):
            fields = line.split()
            index_names.add(fields[1])

# Get sequence names used in the annotation file.
gtf_names = set()

with open("reference/Homo_sapiens.GRCh38.115.gtf") as gtf_file:
    for line in gtf_file:
        if line.strip() and not line.startswith("#"):
            fields = line.split("\t")
            gtf_names.add(fields[0])

# Find which annotated sequenes are not available in the index.
missing_names = gtf_names - index_names

print(f"Sequences in index: {len(index_names)}")
print(f"Sequences in GTF: {len(gtf_names)}")
print(f"GTF sequences missing from the index: {len(missing_names)}")

for name in sorted(missing_names):
    print(name)
