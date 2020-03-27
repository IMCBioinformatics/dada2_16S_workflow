

rule multiple_align:
    input:
         rules.get_ASV_seq.output
    output:
        "output/taxonomy/ASV_aligned.fasta"
    threads:
        config['threads']
    conda:
        "../envs/fastree_mafft.yaml"
    log:
        "ouput/logs/multiple_align.log"

    shell:
        """
        mafft --auto --thread {threads} --maxiterate 1000 --globalpair {input} > {output}
        """


rule newick_tree:
    input:
         rules.multiple_align.output
    output:
        "output/taxonomy/ASV_tree.nwk"
    threads:
        config['threads']
    conda:
        "../envs/fastree_mafft.yaml"
    log:
        "output/logs/fastree.log"
    shell:
        """
        export OMP_NUM_THREADS={threads} && FastTreeMP -nt -gamma -spr 4 -log {log} -quiet {input} > {output} || fasttree -nt -gamma -spr 4 -log {log} -quiet {input} > {output}
        """

#rule plot_tree
#    input:
#      nwk=rules.newick_tree.output,
      

#read.tree("ASV_tree.nwk")->p

#ggsave(ggtree(p)+ geom_tiplab(size=7),filename="test2.pdf")
