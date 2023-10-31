import pandas as pd

list_files = pd.read_csv(snakemake.input[0], sep="\t", index_col=0)
print(list_files)
subset = list_files[list_files["R1"].str.contains(snakemake.config["excluded_samples"]) == False]
print(subset)
random_samples = subset.sample(n=snakemake.config["random_n"])
print(random_samples)
random_samples.to_csv(snakemake.output[0], index=True,columns=[], header=False)

