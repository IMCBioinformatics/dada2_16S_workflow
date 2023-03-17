#Required python modules
import os
import pandas as pd


##Input file
configfile: "config.yaml"
list_files = pd.read_table(config['list_files'],index_col=0)
SAMPLES = list(list_files.index)

config["path"]+"/"+config["output_dir"]

## Find random samples to make qc plots with
subset=list_files[list_files[ "R1" ].str.contains( config["excluded_samples"] )==False ]
random_samples=subset.sample(n = 8)

isExist = os.path.exists(config["output_dir"])
if not isExist:
   os.makedirs(config["output_dir"])

random_samples.to_csv("samples/random_samples.tsv", columns=[], header=False,line_terminator = '')
#print(random_samples)


rule all:
    input:
        config["output_dir"]+"/figures/Length_distribution/Sequence_Length_distribution_abundance.png",
        config["output_dir"]+"/figures/Length_distribution/Sequence_Length_distribution.png",
        config["output_dir"]+"/figures/quality/afterQCQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/afterQCQualityPlots_R2.png",
        config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R2.png",
        config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R2.png",
        expand(config["output_dir"]+"/taxonomy/{ref}_IDtaxa.tsv",ref= config['idtaxa_dbs'].keys()),
        expand(config["output_dir"]+"/taxonomy/{ref}_RDP.tsv",ref= config['RDP_dbs'].keys()),
        config["output_dir"]+"/phylogeny/ASV_seq.fasta",
	config["output_dir"]+"/phylogeny/ASV_aligned.fasta",
        config["output_dir"]+"/phylogeny/ASV_tree.nwk",
        config["output_dir"]+"/dada2/Nreads.tsv",
        config["output_dir"]+"/dada2/Nreads_filtered.txt",
        config["output_dir"]+"/dada2/percent_phix.txt",
        config["output_dir"]+"/multiqc_filt/multiqc_report_filtered.html",
        config["output_dir"]+"/multiqc_raw/multiqc_report_raw.html",
        config["output_dir"]+"/random_samples/"+"temp_raw.txt",
	config["output_dir"]+"/random_samples/"+"temp_dada2.txt",
	config["output_dir"]+"/random_samples/"+"temp_cutadapt.txt",
        config["output_dir"]+"/figures/Length_distribution/"+"temp_read_length.txt",
        config["output_dir"]+"/QC_html_report/"+"qc_report.html",
        config["output_dir"]+"/taxonomy/"+"annotaion_combined_dada2.txt"



include: "utils/rules/qc_cutadapt.smk"
include: "utils/rules/dada2.smk"
include: "utils/rules/phylo_tree.smk"
include: "utils/rules/readCount.smk"
include: "utils/rules/seqkit_length_report.smk"
include: "utils/rules/reads_length_plotting.smk"
include: "utils/rules/qc_report.smk"
include: "utils/rules/annotation_output_dada2.smk"
