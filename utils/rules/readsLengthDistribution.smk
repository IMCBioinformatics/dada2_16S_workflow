rule reads_Length_Distribution:
    input:
        R1= rules.dada2_filter.output.R1,
        R2= rules.dada2_filter.output.R2,
        sampleTBL= "samples.tsv"
        remove_samples=config["remove_samples"]
    output:
        result=directory(config["output_dir"]+"/figures/ReadsLength/")
    conda:
        "readLength"
    script:
        "../scripts/dada2/readsLengthDistribution.R"



rule selectedSamples:
    input:
       sampleTBL="samples.tsv
       remove_samples=config["remove_samples"] 
    output:
       o1="select_files.tsv"
    conda: "seqkit"
    shell:
      "grep -vE "(2016|5659)" samples.tsv |  awk 'NR>1 '  | sort --random-sort | head -n 5 | awk {'first = $1; $1=""; print $0'}|sed 's/^ //g' | awk '
    { for (i=1; i<=NF; i++) a[i] = a[i] $i ORS } END { for (i=1; i<=NF; i++) printf "%s", a[i] }'" 

rule plotSamples:
    input:
        i1=rules.selectedSamples.output.o1

grep -vE {input.remove_samples} {input.sampleTBL} |
 awk 'NR>1 ' samples.tsv | sort --random-sort | head -n 5 | awk {'first = $1; $1=""; print $0'}|sed 's/^ //g' | awk '
    { for (i=1; i<=NF; i++) a[i] = a[i] $i ORS } END { for (i=1; i<=NF; i++) printf "%s", a[i] }'
