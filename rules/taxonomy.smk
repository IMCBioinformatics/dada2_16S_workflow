

rule build_tree:
    input:
        rds= "output/seqtab.rds",
    output:
        alignment= "output/taxonomy/alignment.fasta",
        tree= "output/taxonomy/otu_tree.nwk",
    threads:
        1
    log:
        "output/logs/taxonomy/alignment.txt"
    script:
        "../scripts/dada2/alignment.R"
