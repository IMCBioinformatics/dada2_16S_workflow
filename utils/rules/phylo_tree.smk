
rule multiple_align:
    input:
        seqtab =rules.removeChimeras.output.rds
    output:
        seqfasta="output/taxonomy/ASV_seq.fasta",
        alignment="output/taxonomy/ASV_aligned.fasta"
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "output/logs/taxonomy/multiple_align.log"
    script:
        "../scripts/dada2/alignment.R"

   

rule newick_tree:
    input:
         rules.multiple_align.output.alignment
    output:
        "output/taxonomy/ASV_tree.nwk"
    threads:
        config['threads']
    conda:
        "../envs/fastree_mafft.yaml"
    log:
        "output/logs/taxonomy/fastree.log"
    shell:
        """
        export OMP_NUM_THREADS={threads} && FastTreeMP -nt -gamma -spr 4 -log {log} -quiet {input} > {output} || fasttree -nt -gamma -spr 4 -log {log} -quiet {input} > {output}
        """
