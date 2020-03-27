# An example collection of Snakemake rules imported in the main Snakefile.


rule plotQualityProfile:
    input:
        R1= expand("output/cutadapt/{sample}_R1.fastq.gz",sample=SAMPLES),
        R2= expand("output/cutadapt/{sample}_R2.fastq.gz",sample=SAMPLES)
#        R1= rules.cutadapt.output.R1,
#        R2= rules.cutadapt.output.R2,
    output:
        R1="output/dada2/quality/qualityPlots_R1.pdf",
        R2="output/dada2/quality/qualityPlots_R2.pdf"
    conda:
        "../envs/dada2.yaml"
    script:
        "../scripts/dada2/plotQualityProfile.R"




rule dada2_filter:
    input:
        R1= expand("output/cutadapt/{sample}_R1.fastq.gz",sample=SAMPLES),
        R2= expand("output/cutadapt/{sample}_R2.fastq.gz",sample=SAMPLES)
    output:
        R1= expand("output/dada2/dada2_filter/{sample}_R1.fastq.gz",sample=SAMPLES),
        R2 =expand( "output/dada2/dada2_filter/{sample}_R2.fastq.gz",sample=SAMPLES),
#        nreads= "output/dada2/{sample}/stats/Nreads_filtered.txt"
    params:
       	 samples=SAMPLES,
       	 nread="output/dada2/Nreads_filtered.txt"
    threads:
         config['threads']
    conda:
         "../envs/dada2.yaml"
    log:
        "output/logs/dada2/dada2_filter.txt"
    script:
       	"../scripts/dada2/dada2_filter.R"

rule learnErrorRates:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2
    output:
        errR1= "output/model/ErrorRates_R1.rds",
        errR2 = "output/model/ErrorRates_R2.rds",
        plotErr1="output/figures/ErrorRates_R1.pdf",
        plotErr2="output/figures/ErrorRates_R2.pdf"
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "output/logs/dada2/learnErrorRates.txt"
    script:
        "../scripts/dada2/learnErrorRates.R"


rule dereplicate:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2,
        errR1= rules.learnErrorRates.output.errR1,
        errR2= rules.learnErrorRates.output.errR2
    output:
        seqtab= temp("output/seqtab_with_chimeras.rds"),
        nreads= temp("output/dada2/Nreads_dereplicated.txt")
    params:
        samples=SAMPLES
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "output/logs/dada2/dereplicate.txt"
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
        "../envs/dada2.yaml"
    log:
        "output/logs/dada2/removeChimeras.txt"
    script:
        "../scripts/dada2/removeChimeras.R"



# Use this rule if you automatically want to subset the ASVs based on their distribution.
# This rule is commented out at the moment

rule filterLength:
    input:
        seqtab= rules.removeChimeras.output.rds
    output:
        plot_seqlength= "output/figures/Lengths/Sequence_Length_distribution.pdf",
        plot_seqabundance= "output/figures/Lengths/Sequence_Length_distribution_abundance.pdf",
        rds= "output/seqtab.rds",
        tsv=  "output/seqtab.tsv",
    threads:
        1
    conda:
        "../envs/dada2.yaml"
    log:
        "output/logs/dada2/filterLength.txt"
    script:
        "../scripts/dada2/filterLength.R"


rule IDtaxa:
    input:
        seqtab= "output/seqtab.rds",
        ref= lambda wc: config['idtaxa_dbs'][wc.ref],
        species= lambda wc: config['idtaxa_species'][wc.ref]
    output:
        taxonomy= "output/taxonomy/{ref}.tsv",
    threads:
        config['threads']
    log:
        "output/logs/dada2/IDtaxa_{ref}.txt"
    script:
        "../scripts/dada2/IDtaxa.R"


rule get_ASV_seq:
    input:
        "output/seqtab.tsv",
    output:
        "output/taxonomy/ASV_seq.fasta"
    run:
        with open(input[0]) as infile:
            seqs = infile.readline().strip().replace('"','').split()
        with open(output[0],'w') as outfile:
            for s in seqs:
                outfile.write(f">{s}\n{s}\n")
