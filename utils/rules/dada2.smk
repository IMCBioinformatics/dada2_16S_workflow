rule plotQualityProfileRaw:
    input:
        R1= expand(config["input_dir"]+"/{sample}" + config["forward_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        R2= expand(config["input_dir"]+"/{sample}" + config["reverse_read_suffix"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1=config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R1.png",
        R2=config["output_dir"]+"/figures/quality/rawFilterQualityPlots_R2.png"
    conda:
        "dada2"
    script:
        "../scripts/dada2/plotQualityProfile.R"


rule plotQualityProfileAfterQC:
    input:
        R1= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["forward_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        R2= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["reverse_read_suffix"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1=config["output_dir"]+"/figures/quality/afterQCQualityPlots_R1.png",
        R2=config["output_dir"]+"/figures/quality/afterQCQualityPlots_R2.png"
    conda:
        "dada2"
    script:
        "../scripts/dada2/plotQualityProfile.R"
   


rule dada2Filter:
    input:
        R1= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["forward_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        R2= expand(config["output_dir"]+"/cutadapt_qc/{sample}" + config["reverse_read_suffix"] + ".fastq.gz",sample=SAMPLES)
    output:
        R1= expand(config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["forward_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        R2= expand(config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["reverse_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        nreads= config["output_dir"]+"/dada2/Nreads_filtered.txt",
        percent_phix= config["output_dir"]+"/dada2/percent_phix.txt"
    params:
        samples=SAMPLES,
        nread=config["output_dir"]+"/dada2/Nreads_filtered.txt",
        percent_phix= config["output_dir"]+"/dada2/percent_phix.txt"
    threads:
         config["threads"]
    conda:
        "dada2"
    script:
        "../scripts/dada2/dada2_filter.R"


rule plotQualityProfileAfterdada2:
    input:
        R1= rules.dada2Filter.output.R1, 
        R2= rules.dada2Filter.output.R2
    output:
        R1=config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R1.png",
        R2=config["output_dir"]+"/figures/quality/afterdada2FilterQualityPlots_R2.png"
    conda:
        "dada2"
    script:
        "../scripts/dada2/plotQualityProfile.R"



rule learnErrorRates:
    input:
        R1= rules.dada2Filter.output.R1,
        R2= rules.dada2Filter.output.R2
    output:
        errR1= config["output_dir"]+"/dada2/learnErrorRates/ErrorRates_R1.rds",
        errR2 = config["output_dir"]+"/dada2/learnErrorRates/ErrorRates_R2.rds",
        plotErr1=config["output_dir"]+"/figures/errorRates/ErrorRates_R1.pdf",
        plotErr2=config["output_dir"]+"/figures/errorRates/ErrorRates_R2.pdf"
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/learnErrorRates.R"


rule generateSeqtab:
    input:
        R1= rules.dada2Filter.output.R1,
        R2= rules.dada2Filter.output.R2,
        errR1= rules.learnErrorRates.output.errR1,
        errR2= rules.learnErrorRates.output.errR2
    output:
        seqtab= temp(config["output_dir"]+"/dada2/seqtab_with_chimeras.rds"),
        nreads= temp(config["output_dir"]+"/dada2/Nreads_with_chimeras.txt")
    params:
        samples=SAMPLES
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/generateSeqtab.R"

rule removeChimeras:
    input:
        seqtab= rules.generateSeqtab.output.seqtab
    output:
        rds= config["output_dir"]+"/dada2/seqtab_nochimeras.rds",
        csv= config["output_dir"]+"/dada2/seqtab_nochimeras.csv",
        nreads=temp(config["output_dir"]+"/dada2/Nreads_nochimera.txt")
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/removeChimeras.R"





##plots the distribution of ASV length count and abundance based on length

rule plotASVLength:
    input:
        seqtab= rules.removeChimeras.output.rds
    output:
        plot_seqlength= config["output_dir"]+"/figures/length_distribution/Sequence_Length_distribution.png"
    threads:
        config["threads"]
    conda:
        "dada2"
    script:
        "../scripts/dada2/asv_length_distribution_plotting.R"


rule IDtaxa:
    input:
        seqtab=rules.removeChimeras.output.rds,
        ref= lambda wc: config['idtaxa_dbs'][wc.ref],
        species= lambda wc: config['idtaxa_species'][wc.ref]
    output:
        taxonomy= config["output_dir"]+"/taxonomy/{ref}_IDtaxa.tsv",
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/IDtaxa.R"

rule RDPtaxa:
    input:
        seqtab=rules.removeChimeras.output.rds,
        ref= lambda wc: config['RDP_dbs'][wc.ref],
        species= lambda wc: config['RDP_species'][wc.ref]
    output:
        taxonomy= config["output_dir"]+"/taxonomy/{ref}_RDP.tsv",
        rds_bootstrap=config["output_dir"]+"/taxonomy/{ref}_RDP_boostrap.rds"
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/RDPtaxa.R"

