rule qc_report:
    input:
        rules.combineReadCounts.output,
        rules.plotASVLength.output,
        rules.plotQualityProfileAfterdada2.output,
        rules.plotQualityProfileRaw.output,
        rules.plotQualityProfileAfterQC.output
    conda:
        "rmd"
    params:
        Nread=config["output_dir"]+"/dada2/Nreads.tsv",
        quality=config["path"]+"/"+config["output_dir"]+"/figures/quality/",
        length_distribution=config["path"]+"/"+config["output_dir"]+"/figures/length_distribution/",
        config["output_dir"]+"/QC_html_report"
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report.html"
    script:
        "../scripts/dada2/qc_report.Rmd"
