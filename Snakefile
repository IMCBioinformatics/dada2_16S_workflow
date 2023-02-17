#Required python modules
import os
import pandas as pd

##Input files

configfile: "config.yaml"
SampleTable = pd.read_table(config['sampletable'],index_col=0)
SAMPLES = list(SampleTable.index)


rule all:
    input:
        config["output_dir"]+"/figures/ASVsLength/Sequence_Length_distribution_abundance.png",
        config["output_dir"]+"/figures/ASVsLength/Sequence_Length_distribution.png",
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
        config["output_dir"]+"/multiqc_raw/multiqc_report_raw.html"
#        "qc_report.html"



rule rawReadCount:
    input:
        SampleTable["R1"][1].rsplit("/",1)[0]
    output:
        config["output_dir"]+"/rawReadCount.txt"
    conda: "QC"
    shell:
        "seqkit stats -a {input}/*.gz > {output}"


rule numSeqParse:
     input:rules.rawReadCount.output
     output:config["output_dir"]+"/dada2/Parsed_rawReadCount.txt"
     shell:
        " sed 's/,//g' {input} | sed -n '1p;0~2p' | awk '{{print $1,$4}}'| rev | cut -d'/' -f 1 | rev | sed 's/\_R.*gz//'  | tr ' ' '\t'> {output}"


#Used to combine read counts from each step of dada2
rule combineReadCounts:
    input:
        config["output_dir"]+"/dada2/Parsed_rawReadCount.txt",
        config["output_dir"]+"/dada2/Nreads_filtered.txt",
        config["output_dir"]+"/dada2/Nreads_with_chimeras.txt",
        config["output_dir"]+"/dada2/Nreads_nochimera.txt"
    output:
        config["output_dir"]+"/dada2/Nreads.tsv"
    run:
        import pandas as pd
        D= pd.read_table(input[0],index_col=0)
        D= D.join(pd.read_table(input[1],index_col=0))
        D= D.join(pd.read_table(input[2],index_col=0))
        D= D.join(pd.read_table(input[3],squeeze=True,index_col=0))
        D.to_csv(output[0],sep='\t')


#rule qc_report:
#    input:
#        config["output_dir"]+"/dada2/Nreads.tsv"
#    conda:
#        "utils/envs/rmd.yaml"
#    output:
#        "qc_report.html"
#    script:
#        "qc_report.Rmd"


include: "utils/rules/qc_cutadapt.smk"
include: "utils/rules/dada2.smk"
include: "utils/rules/phylo_tree.smk"
#include: "utils/rules/readsLengthDistribution.smk"
