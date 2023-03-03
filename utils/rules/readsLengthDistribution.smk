rule reads_Length_Distribution:
    input:
        files=config["output_dir"]+"/random_samples"
    output:
        outdir=expand(config["output_dir"]+"/figures/ASVsLength/"+"{sample}_qc.png",sample=SAMPLES)
    conda:
        "dada2"
    script:
        "../scripts/dada2/readsLengthDistribution.R"
