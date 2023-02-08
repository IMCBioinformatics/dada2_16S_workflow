#Required python modules
import os
import pandas as pd

##Input file
configfile: "config.yaml"
SampleTable = pd.read_table(config['sampletable'],index_col=0)
SAMPLES = list(SampleTable.index)


qc = config["qc_only"]

def all_input_reads(qc):
    if config["qc_only"]:
        return expand("output/fastqc/{sample}" + config["R1"] + "_fastqc.html", sample=SAMPLES)
    else:
                return expand("output/fastqc/{sample}" + config["R1"] + "_fastqc.html", sample=SAMPLES)




rule all:
    input:
        "output/rawReadsCount.txt",
        "output/Parsed_rawReadsCount.txt",
        "output/figures/ASVsLength/Sequence_Length_distribution_abundance.png",
        "output/figures/ASVsLength/Sequence_Length_distribution.png",
        "output/figures/quality/predada2FilterQualityPlots_R1.png",
        "output/figures/quality/predada2FilterQualityPlots_R2.png",
        "output/figures/quality/rawFilterQualityPlots_R1.png",
        "output/figures/quality/rawFilterQualityPlots_R2.png",
        "output/figures/quality/postdada2FilterQualityPlots_R1.png",
        "output/figures/quality/postdada2FilterQualityPlots_R2.png",
         expand("output/taxonomy/{ref}.tsv",ref= config['idtaxa_dbs'].keys()),
         expand("output/figures/ReadsLength/"),
        "output/taxonomy/ASV_seq.fasta",
	"output/taxonomy/ASV_aligned.fasta",
        "output/taxonomy/ASV_tree.nwk",
        'output/dada2/Nreads.tsv',
        'output/dada2/Nreads_filtered.txt',
        'output/dada2/percent_phix.txt',
        'output/taxonomy/consensus_taxa.tsv',
        'output/taxonomy/Silva_RDP.tsv',
        'output/taxonomy/GTDB_RDP.tsv',
        'output/taxonomy/RDP_RDP.tsv',
        "output/multiqc_unfilt/multiqc_report_unfiltered.html" if config["qc_only"] else "output/multiqc_filt/multiqc_report_filtered.html",
        "output/multiqc_unfilt/multiqc_report_unfiltered.html",
        "qc_report.html"



rule rawReadsCount:
    input:
        SampleTable["R1"][1].rsplit("/",1)[0]
    output:
        "output/rawReadsCount.txt"
    conda:
        "utils/envs/seqkit.yaml"
    shell:
        "seqkit stats -a {input}/*.gz > {output}"


rule num_seqParse:
     input:rules.rawReadsCount.output
     output:"output/Parsed_rawReadsCount.txt"
     shell:
        "perl -pe 's/(?<=\d),(?=\d)//g' {input} | sed -n '1p;0~2p' | awk '{{print $1,$4}}'| rev | cut -d'/' -f 1 | rev | sed 's/\_R.*gz//'  | tr ' ' '\t'> {output}"


#Used to combine read counts from each step of dada2
rule combine_read_counts:
    input:
        'output/Parsed_rawReadsCount.txt',
        'output/dada2/Nreads_filtered.txt',
        'output/dada2/Nreads_dereplicated.txt',
        'output/dada2/Nreads_chimera_removed.txt'
    output:
        'output/dada2/Nreads.tsv',
    run:
        import pandas as pd
        D= pd.read_table(input[0],index_col=0)
        D= D.join(pd.read_table(input[1],index_col=0))
        D= D.join(pd.read_table(input[2],index_col=0))
        D= D.join(pd.read_table(input[3],squeeze=True,index_col=0))
        D.to_csv(output[0],sep='\t')


rule qc_report:
    input:
        "output/dada2/Nreads.tsv"
    conda:
        "utils/envs/rmd.yaml"
    output:
        "qc_report.html"
    script:
        "qc_report.Rmd"


include: "utils/rules/qc_cutadapt.smk"
include: "utils/rules/dada2.smk"
include: "utils/rules/phylo_tree.smk"
include: "utils/rules/readsLengthDistribution.smk"
