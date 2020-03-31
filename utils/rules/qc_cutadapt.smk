
rule fastqc:
    input:
        unpack( lambda wc: dict(SampleTable.loc[wc.sample]))
    output:
        R1= "output/fastqc/{sample}" + config["R1"] + "_fastqc.html",
        R2 ="output/fastqc/{sample}" + config["R2"] + "_fastqc.html"
    conda: 
        "../envs/fastqc.yaml"
    log:
        "output/logs/qc/fastqc_{sample}_unfilt.log"
    shell: "fastqc -o output/fastqc {input.R1} {input.R2}"


rule multiqc:
    input:
        R1 =expand("output/fastqc/{sample}" + config["R1"] +"_fastqc.html",sample=SAMPLES),
        R2 =expand("output/fastqc/{sample}" + config["R2"] +"_fastqc.html",sample=SAMPLES)
    output:
        "output/multiqc_unfilt/multiqc_report_unfiltered.html"
    conda:
        "../envs/multiqc.yaml"
    log:
        "output/logs/qc/multiqc_unfiltered.log"	 	
    shell: 
        "multiqc -f output/fastqc -o output/multiqc_unfilt -n multiqc_report_unfiltered.html"



rule cutadapt:
    input:
        unpack( lambda wc: dict(SampleTable.loc[wc.sample]))
    output:
        R1= "output/cutadapt/{sample}_R1.fastq.gz",
        R2= "output/cutadapt/{sample}_R2.fastq.gz"
        #touch("mytask.done")

    params:
       inputs= lambda wc,input: f"{input.R1} {input.R2}",
        m=10,
        o=17,
        e=0
    threads:
        config['threads']
    conda:
        "../envs/cutadapt.yaml"
    log: 
        "output/logs/qc/cutadapt_primer/cutadapt{sample}.log"
    shell:
        "cutadapt -m {params.m} -O {params.o}  -g {config[fwd_primer]} -G {config[rev_primer]} "
        "-a {config[rev_primer_rc]} -A {config[fwd_primer_rc]} -o {output.R1} -p {output.R2} "
        "{params.inputs} >> {log}"
#	 " {params.inputs}"




rule fastqc_filt:
    input:
        R1= "output/cutadapt/{sample}_R1.fastq.gz",
        R2= "output/cutadapt/{sample}_R2.fastq.gz"
    output:
        R1= "output/fastqc_filt/{sample}_R1_fastqc.html",
        R2= "output/fastqc_filt/{sample}_R2_fastqc.html"
    conda: 
        "../envs/fastqc.yaml"
    log: 
        "output/logs/qc/fastqc_{sample}_filt.log"
    shell: 
        "fastqc -o output/fastqc_filt {input.R1} {input.R2}"
       



rule multiqc_filt:
    input:
        R1= expand("output/fastqc_filt/{sample}_R1_fastqc.html",sample=SAMPLES),
        R2= expand("output/fastqc_filt/{sample}_R2_fastqc.html",sample=SAMPLES)
    output:
        "output/multiqc_filt/multiqc_report_filtered.html"
    conda:
        "../envs/multiqc.yaml"
    log:   
        "output/logs/qc/multiqc_filt.log"
    shell: 
        "multiqc -f output/fastqc_filt -o output/multiqc_filt -n multiqc_report_filtered.html"
