rule reads_Length_Distribution:
    input:
        needed=rules.seqkit_counts_raw.output
    output:
        temp=config["output_dir"]+"/figures/ASVsLength/"+"temp_read_length.txt"
    params:
        files=config["output_dir"]+"/random_samples",
        outdir=config["output_dir"]+"/figures/ASVsLength/"
    conda: 
        "dada2"
    shell:
        """
        Rscript utils/scripts/dada2/readsLengthDistribution.R {params.files} {params.outdir}
        touch {output.temp}
        """
