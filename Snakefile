
import os
import pandas as pd

configfile: "config.yaml"
SampleTable = pd.read_table(config['sampletable'],index_col=0)
SAMPLES = list(SampleTable.index)

#CONDAENV ='envs'
PAIRED_END= ('R2' in SampleTable.columns)
FRACTIONS= ['R1']
if PAIRED_END: FRACTIONS+= ['R2']



qc = config["qc_only"]

def all_input_reads(qc):
    if config["qc_only"]:
        return expand("output/fastqc/{sample}" + config["R1"] + "_fastqc.html", sample=SAMPLES)
    else:
#                return expand("output/cutadapt/{sample}_R1.fastq.gz",sample=SAMPLES)
                return expand("output/fastqc/{sample}" + config["R1"] + "_fastqc.html", sample=SAMPLES)





rule all:
    input:
#        expand("output/dada2/dada2_filter/{sample}_{direction}.fastq.gz",sample=SAMPLES,direction=['R1','R2']),
#        "output/model/ErrorRates_R1.rds",
#        "output/seqtab.tsv",
        "output/figures/Lengths/Sequence_Length_distribution_abundance.pdf",
         expand("output/taxonomy/{ref}.tsv",ref= config['idtaxa_dbs'].keys()),
#        "output/taxonomy/ASV_seq.fasta",
#	"output/taxonomy/ASV_aligned.fasta",
        "output/taxonomy/ASV_tree.nwk",         
        'output/dada2/Nreads.tsv',
        'output/taxonomy/consensus_taxa.tsv',
        "output/taxonomy/consensus_RDPtaxa.tsv",
#        'output/taxonomy/consensus_RDPtaxa.tsv',
        "output/multiqc_unfilt/multiqc_report_unfiltered.html" if config["qc_only"] else "output/multiqc_filt/multiqc_report_filtered.html",
        "output/multiqc_unfilt/multiqc_report_unfiltered.html",
         all_input_reads


rule all_profile:
    input: expand("output/dada2/quality/qualityPlots_{direction}.pdf",direction=['R1','R2'])



#Used to combine read counts from each step of dada2
rule combine_read_counts:
    input:
        'output/dada2/Nreads_filtered.txt',
        'output/dada2/Nreads_dereplicated.txt',
        'output/dada2/Nreads_chimera_removed.txt'
    output:
        'output/dada2/Nreads.tsv',
    run:
        import pandas as pd
        D= pd.read_table(input[0],index_col=0)
        D= D.join(pd.read_table(input[1],index_col=0))
        D= D.join(pd.read_table(input[2],squeeze=True,index_col=0))
        D.to_csv(output[0],sep='\t')



include: "utils/rules/qc_cutadapt.smk"
include: "utils/rules/dada2.smk"
include: "utils/rules/phylo_tree.smk"



