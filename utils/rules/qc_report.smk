rule qc_report:
    input:
        Nread=config["path"]+"/"+config["output_dir"]+"/dada2/Nreads.tsv",
        Length_distribution=config["path"]+"/"+config["output_dir"]+"/figures/length_distribution/",
        quality=config["path"]+"/"+config["output_dir"]+"/figures/quality/"
    conda:
        "rmd"
    params:
        config["output_dir"]+"/QC_html_report"
    output:
        config["output_dir"]+"/QC_html_report/"+"qc_report.html"
    script:
        "../scripts/dada2/qc_report.Rmd"
