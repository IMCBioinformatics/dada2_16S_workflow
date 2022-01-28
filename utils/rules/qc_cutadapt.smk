
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
    shell: "fastqc -o output/fastqc {input.R1} {input.R2} >> {log}"


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
        "multiqc -f output/fastqc -o output/multiqc_unfilt -n multiqc_report_unfiltered.html >> {log}"



rule cutadapt:
    input:
        unpack( lambda wc: dict(SampleTable.loc[wc.sample]))
    output:
        R1= "output/cutadapt/{sample}" + config["R1"] + ".fastq.gz",
        R2= "output/cutadapt/{sample}" + config["R2"] + ".fastq.gz"
        #touch("mytask.done")

    params:
       inputs= lambda wc,input: f"{input.R1} {input.R2}",
        m=10,
        o=17,
        e=0.1
    threads:
        config['threads']
    conda:
        "../envs/cutadapt.yaml"
    log: 
        "output/logs/qc/cutadapt_primer/cutadapt{sample}.log"
    shell:
        "cutadapt -m {params.m} -O {params.o} " 
#       "-g {config[fwd_primer]} -G {config[rev_primer]} -a {config[rev_primer_rc]} -A {config[fwd_primer_rc]}"
        " -o {output.R1} -p {output.R2} "
        "{params.inputs} >> {log}"

rule cutadapt_qc:
    input:
        R1= rules.cutadapt.output.R1,
        R2= rules.cutadapt.output.R2
    output:
        R1= "output/cutadapt_qc/{sample}" + config["R1"] + ".fastq.gz",
        R2= "output/cutadapt_qc/{sample}" + config["R2"] + ".fastq.gz"
    params:
        qf=20,
        qr=20,
        m=10,
    threads:
        config['threads']
    conda:
        "../envs/cutadapt.yaml"
    log: 
        "output/logs/qc/cutadapt_primer/cutadapt{sample}.log"
    shell:
        "cutadapt -A XXX -q {params.qf},{params.qr} -m {params.m} -o {output.R1} -p {output.R2} {input.R1} {input.R2} >> {log}"
#	 " {params.inputs}"




rule fastqc_filt:
    input:
        R1= rules.cutadapt_qc.output.R1,
        R2= rules.cutadapt_qc.output.R2
    output:
        R1= "output/fastqc_filt/{sample}"+ config["R1"] + "_fastqc.html",
        R2= "output/fastqc_filt/{sample}"+ config["R2"] + "_fastqc.html"
    conda: 
        "../envs/fastqc.yaml"
    log: 
        "output/logs/qc/fastqc_{sample}_filt.log"
    shell: 
        "fastqc -o output/fastqc_filt {input.R1} {input.R2} >> {log}"
       



rule multiqc_filt:
    input:
        R1= expand("output/fastqc_filt/{sample}"+ config["R1"] + "_fastqc.html",sample=SAMPLES),
        R2= expand("output/fastqc_filt/{sample}"+ config["R2"] + "_fastqc.html",sample=SAMPLES)
    output:
        "output/multiqc_filt/multiqc_report_filtered.html"
    conda:
        "../envs/multiqc.yaml"
    log:   
        "output/logs/qc/multiqc_filt.log"
    shell: 
        "multiqc -f output/fastqc_filt -o output/multiqc_filt -n multiqc_report_filtered.html >> {log}"
