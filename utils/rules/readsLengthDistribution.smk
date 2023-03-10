rule reads_Length_Distribution:
    input:
        needed=rules.seqkit_counts_raw.output,
        files=config["output_dir"]+"/random_samples"
    output:
        temp=config["output_dir"]+"/figures/ASVsLength/"+"temp_read_length.txt"
    params:
        outdir=config["output_dir"]+"/figures/ASVsLength/"
    conda: 
        "dada2"
    shell:
        """
        Rscript utils/scripts/dada2/readsLengthDistribution.R {input.files} {params.outdir}
        touch {output.temp}
        """
