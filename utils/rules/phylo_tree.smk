rule multipleAlign:
    input:
        seqtab =rules.removeChimeras.output.rds
    output:
        seqfasta=config["output_dir"]+"/phylogeny/ASV_seq.fasta",
        alignment=config["output_dir"]+"/phylogeny/ASV_aligned.fasta"
    threads:
        config['threads']
    conda:
        "dada2"
    script:
        "../scripts/dada2/alignment.R"

   

rule newickTree:
    input:
         rules.multipleAlign.output.alignment
    output:
        config["output_dir"]+"/phylogeny/ASV_tree.nwk"
    threads:
        config['threads']
    conda:
        "fastree_mafft"
    shell:
        """
        export OMP_NUM_THREADS={threads} && FastTreeMP -nt -gamma -spr 4 {input} > {output} || fasttree -nt -gamma -spr 4  {input} > {output}
        """
