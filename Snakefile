#Required python modules
import os
import pandas as pd


##Input file
configfile: "config.yaml"
list_files = pd.read_table(config['list_files'],index_col=0)
SAMPLES = list(list_files.index)



rule all:
    input:
        config["output_dir"]+"/figures/length_distribution/Sequence_Length_distribution.png",
        config["output_dir"]+"/figures/quality/afterQCQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/afterQCQualityPlots_R2.png",
        config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R2.png",
        config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R1.png",
        config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R2.png",
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
        config["output_dir"]+"/figures/length_distribution/"+"temp_read_length.txt",
        config["output_dir"]+"/QC_html_report/"+"qc_report.html",
        config["output_dir"]+"/taxonomy/"+"annotation_combined_dada2.txt",
        "samples/random_samples.tsv",
        config["output_dir"]+"/vsearch/Final_uncollapsed_output.tsv",
        config["output_dir"]+"/vsearch/Final_colapsed_output.tsv",
        config["output_dir"]+"/taxonomy/Vsearch_output.tsv",
        config["output_dir"]+"/taxonomy/vsearch_dada2_merged.tsv"

##path to where different snakemake rule files are saved

include: "utils/rules/qc_cutadapt.smk"
include: "utils/rules/dada2.smk"
include: "utils/rules/phylo_tree.smk"
include: "utils/rules/readCount.smk"
include: "utils/rules/seqkit_length_report.smk"
include: "utils/rules/annotation_output_dada2.smk"
include: "utils/rules/vsearch.smk"
include: "utils/rules/qc_report.smk"
