import pandas as pd 

# Export from SRA Run Selector. Copy your own download before running.
RAW_PATH = "data/sra_run_table.csv"
OUTPUT_PATH = "data/metadata.csv"

df = pd.read_csv(RAW_PATH)

df = df[["Run", "AGE", "disease", "sex"]]
df.columns = ["sample_id", "age", "condition", "sex"]

df["condition"] = df["condition"].replace({
    "dilated cardiomyopathy" : "DCM",
    "ischemic cardiomyopathy" : "ICM",
    "non-failing" : "NF"
})

df.to_csv(OUTPUT_PATH, index = False)