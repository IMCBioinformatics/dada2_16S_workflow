rule reads_Length_Distribution:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2,
        sampleTBL= "samples.tsv"
    output:
        result=directory("output/figures/ReadsLength/")
    conda:
        "../envs/readLength.yaml"
    script:
        "../scripts/dada2/readsLengthDistribution.R"
