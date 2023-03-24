rule random_samples:
    input:
        "samples/samples.tsv"
    output:
        "samples/random_samples.tsv"
    conda: "QC"
    script:
        "../scripts/common/random_sample.py"


rule seqkit_counts:
    input:
        R1= expand(config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["forward_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        R2= expand(config["output_dir"]+"/dada2/dada2_filter/{sample}" + config["reverse_read_suffix"] + ".fastq.gz",sample=SAMPLES),
        file="samples/random_samples.tsv"
    output:
          temp=config["output_dir"]+"/random_samples/"+"temp_cutadapt.txt"
    params:
          output_dir=config["output_dir"]+"/random_samples",
          input_dir=config["output_dir"]+"/cutadapt_qc/",
          input_suff_r1=config["forward_read_suffix"]+".fastq.gz",
          input_suff_r2=config["reverse_read_suffix"]+".fastq.gz",
          output_suff1=config["forward_read_suffix"]+"_cutadapt",          
          output_suff2=config["reverse_read_suffix"]+"_cutadapt"          

    conda: "QC"
    shell:
        """
	while read IDS
	 do
	 input_r1={params.input_dir}"$IDS"{params.input_suff_r1}
         input_r2={params.input_dir}"$IDS"{params.input_suff_r2} 
         output_r1={params.output_dir}"/""$IDS"{params.output_suff1}".txt" 
	 output_r2={params.output_dir}"/""$IDS"{params.output_suff2}".txt" 
         if [[ ! -f "$input_r1" || ! -f "$input_r2" ]]; then
             echo "Error: input file does not exist for ID $IDS"
             continue
         fi
         seqkit fx2tab -nl $input_r1 | awk 'NR {{count[$3]++}} END {{for (i in count) print i, count[i]}}' > $output_r1
         seqkit fx2tab -nl $input_r2 | awk 'NR {{count[$3]++}} END {{for (i in count) print i, count[i]}}' > $output_r2
         done < {input.file}
         touch {output.temp}
        """


use rule seqkit_counts as seqkit_counts_dada2 with:
    output:
          temp=config["output_dir"]+"/random_samples/"+"temp_dada2.txt"
    params:
          input_dir=config["output_dir"]+"/dada2/dada2_filter/",
          input_suff_r1=config["forward_read_suffix"]+".fastq.gz",
          input_suff_r2=config["reverse_read_suffix"]+".fastq.gz",
          output_dir=config["output_dir"]+"/random_samples",
          output_suff1=config["forward_read_suffix"]+"_dada2",          
          output_suff2=config["reverse_read_suffix"]+"_dada2"          



use rule seqkit_counts as seqkit_counts_raw with:
    output:
          temp=config["output_dir"]+"/random_samples/"+"temp_raw.txt"
    params:
          input_dir=config["input_dir"] + "/",
          input_suff_r1=config["forward_read_suffix"]+".fastq.gz",
          input_suff_r2=config["reverse_read_suffix"]+".fastq.gz",
          output_dir=config["output_dir"]+"/random_samples",
          output_suff1=config["forward_read_suffix"]+"_raw",          
          output_suff2=config["reverse_read_suffix"]+"_raw"
