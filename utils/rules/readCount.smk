rule rawReadCount:
    input:
        list_files["R1"][1].rsplit("/",1)[0]
    output:
        config["output_dir"]+"/dada2/rawReadCount.txt"
    conda: "QC"
    shell:
        "seqkit stats -a {input}/*.gz > {output}"


rule numSeqParse:
    input:rules.rawReadCount.output
    output:config["output_dir"]+"/dada2/Parsed_rawReadCount.txt"
    shell:
        "sed 's/,//g' {input} | sed -n '1p;0~2p' | awk '{{print $1,$4}}'| rev | cut -d'/' -f 1 | rev | sed 's/\_R.*gz//'  | tr ' ' '\t'> {output}"


#Used to combine read counts from each step of dada2
rule combineReadCounts:
    input:
        config["output_dir"]+"/dada2/Parsed_rawReadCount.txt",
        config["output_dir"]+"/dada2/Nreads_filtered.txt",
        config["output_dir"]+"/dada2/Nreads_with_chimeras.txt",
        config["output_dir"]+"/dada2/Nreads_nochimera.txt"
    output:
        config["output_dir"]+"/dada2/Nreads.tsv",
    run:
        import pandas as pd
        D= pd.read_table(input[0],index_col=0)
        D= D.join(pd.read_table(input[1],index_col=0))
        D= D.join(pd.read_table(input[2],index_col=0))
        D= D.join(pd.read_table(input[3]).squeeze(0))
        D.to_csv(output[0],sep='\t')

