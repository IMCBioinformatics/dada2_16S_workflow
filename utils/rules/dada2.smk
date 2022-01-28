
#Snakemake file for dada2 related rules


rule plotQualityProfileRaw:
    input:
        R1= expand("output/cutadapt/{sample}" + config["R1"] + ".fastq.gz",sample=SAMPLES),
        R2= expand("output/cutadapt/{sample}" + config["R2"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1="output/figures/quality/rawFilterQualityPlots_R1.png",
        R2="output/figures/quality/rawFilterQualityPlots_R2.png"
    conda:
        "../envs/dada2_arc.yaml"
    log:
	"output/logs/dada2/rawplotQualityProfile.log"
    script:
        "../scripts/dada2/plotQualityProfile.R"


rule plotQualityProfile:
    input:
        R1= expand("output/cutadapt_qc/{sample}" + config["R1"] + ".fastq.gz",sample=SAMPLES),
        R2= expand("output/cutadapt_qc/{sample}" + config["R2"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1="output/figures/quality/predada2FilterQualityPlots_R1.png",
        R2="output/figures/quality/predada2FilterQualityPlots_R2.png"
    conda:
        "../envs/dada2_arc.yaml"
    log:
	"output/logs/dada2/PreplotQualityProfile.log"
    script:
        "../scripts/dada2/plotQualityProfile.R"
   


rule dada2_filter:
    input:
        R1= expand("output/cutadapt_qc/{sample}" + config["R1"] + ".fastq.gz",sample=SAMPLES),
        R2= expand("output/cutadapt_qc/{sample}" + config["R2"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1= expand("output/dada2/dada2_filter/{sample}" + config["R1"] + ".fastq.gz",sample=SAMPLES),
        R2= expand("output/dada2/dada2_filter/{sample}" + config["R2"] + ".fastq.gz",sample=SAMPLES),
        nreads= "output/dada2/Nreads_filtered.txt",
        percent_phix= "output/dada2/percent_phix.txt"
    params:
        samples=SAMPLES,
        nread="output/dada2/Nreads_filtered.txt",
        percent_phix= "output/dada2/percent_phix.txt"
    threads:
         config['threads']
    conda:
         "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/dada2_filter.log"
    script:
        "../scripts/dada2/dada2_filter.R"


rule plotQualityProfilePostFilter:
    input:
        R1= rules.dada2_filter.output.R1, 
        R2= rules.dada2_filter.output.R2
    output:
        R1="output/figures/quality/postdada2FilterQualityPlots_R1.png",
        R2="output/figures/quality/postdada2FilterQualityPlots_R2.png"
    conda:
        "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/PostplotQualityProfile.log"
    script:
        "../scripts/dada2/plotQualityProfile.R"



rule learnErrorRates:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2
    output:
        errR1= "output/dada2/learnErrorRates/ErrorRates_R1.rds",
        errR2 = "output/dada2/learnErrorRates/ErrorRates_R2.rds",
        plotErr1="output/figures/ErrorRates_R1.pdf",
        plotErr2="output/figures/ErrorRates_R2.pdf"
    threads:
        config['threads']
    conda:
        "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/learnErrorRates.log"
    script:
        "../scripts/dada2/learnErrorRates.R"


rule dereplicate:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2,
        errR1= rules.learnErrorRates.output.errR1,
        errR2= rules.learnErrorRates.output.errR2
    output:
        seqtab= temp("output/dada2/seqtab_with_chimeras.rds"),
        nreads= temp("output/dada2/Nreads_dereplicated.txt")
    params:
        samples=SAMPLES
    threads:
        config['threads']
    conda:
        "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/dereplicate.log"
    script:
        "../scripts/dada2/dereplicate.R"

rule removeChimeras:
    input:
        seqtab= rules.dereplicate.output.seqtab
    output:
        rds= "output/seqtab_nochimeras.rds",
        nreads=temp("output/dada2/Nreads_chimera_removed.txt")
    threads:
        config['threads']
    conda:
        "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/removeChimeras.log"
    script:
        "../scripts/dada2/removeChimeras.R"



# Use this rule if you automatically want to subset the ASVs based on their distribution.
# This rule is commented out at the moment

rule filterLength:
    input:
        seqtab= rules.removeChimeras.output.rds
    output:
        plot_seqlength= "output/figures/ASVsLength/Sequence_Length_distribution.png",
        plot_seqabundance= "output/figures/ASVsLength/Sequence_Length_distribution_abundance.png",
        rds= "output/dada2/seqtab_filterLength.rds",
    threads:
        1
    conda:
        "../envs/dada2_arc.yaml"
    log:
        "output/logs/dada2/filterLength.log"
    script:
        "../scripts/dada2/filterLength.R"


rule IDtaxa:
    input:
        seqtab=rules.removeChimeras.output.rds,
        ref= lambda wc: config['idtaxa_dbs'][wc.ref],
        species= lambda wc: config['idtaxa_species'][wc.ref]
    output:
        taxonomy= "output/taxonomy/{ref}.tsv",
    threads:
        config['threads']
    log:
        "output/logs/dada2/IDtaxa_{ref}.log"
    conda:
        "../envs/dada2_arc.yaml"
    script:
        "../scripts/dada2/IDtaxa.R"

rule combine_taxa:
     input:
        RDP="output/taxonomy/RDP.tsv",
        SILVA="output/taxonomy/Silva.tsv",
        GTDB="output/taxonomy/GTDB.tsv"
     output:
         taxonomy="output/taxonomy/consensus_taxa.tsv"
     script:
         "../scripts/dada2/consensus_taxa.py"


rule RDPtaxa:
    input:
        seqtab=rules.removeChimeras.output.rds,
        ref= lambda wc: config['RDP_dbs'][wc.ref],
        species= lambda wc: config['RDP_species'][wc.ref]
    output:
        taxonomy= "output/taxonomy/{ref}_RDP.tsv",
    threads:
        config['threads']
    log:
        "output/logs/dada2/RDPtaxa_{ref}.log"
    conda:
        "../envs/dada2_arc.yaml"
    script:
        "../scripts/dada2/RDPtaxa.R"

#rule combine_RDPtaxa:
#     input:
#        RDP="output/taxonomy/RDP_RDP.tsv",
#        SILVA="output/taxonomy/Silva_RDP.tsv",
#        GTDB="output/taxonomy/GTDB_RDP.tsv"
#     output:
#         taxonomy="output/taxonomy/consensus_RDPtaxa.tsv"
#     script:
#         "../scripts/dada2/consensus_taxa.py"
   
