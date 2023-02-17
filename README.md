
# Amplicon sequencing DADA2 snakemake workflow

[![Snakemake](https://img.shields.io/badge/snakemake-v6.13.1-blue)](https://snakemake.bitbucket.io)
[![DADA2](https://img.shields.io/badge/DADA2-v1.14-orange)](https://benjjneb.github.io/dada2/index.html)
[![Conda](https://img.shields.io/badge/conda-v4.11.0-lightgrey)](https://docs.conda.io/en/latest/)


This is a snakemake workflow for profiling microbial communities from amplicon sequencing
data using dada2. The initial code was cloned from https://github.com/SilasK/amplicon-seq-dada2 
and modified to make a workflow suitable for our needs.

## Overview

Input: 
* Raw paired-end fastq files
* samples.tsv [example](example_files/samples.tsv)

Output:

* Taxonomic assignment tables for specified databases (GTDB, RDP, SILVA).
* ASV abundance table (seqtab_nochimera.rds, seqtab_fitlerLength.rds)
* ASV sequences in a fasta file from seqtab_nochimera.rds
* Summary of reads filtered at each step (Nreads.tsv)
* A phylogenetic tree


## Pipeline summary

<iframe src="dag.pdf&embedded=true" style="height:400px; width:600px;" frameborder="0"></iframe>

## How to Use

1. Please make sure you have installed conda (miniconda) and snakemake before running this workflow.

2. Navigate to your project directory and clone this repository into that directory using the following command:

```bash
git clone https://github.com/IMCBioinformatics/dada2_snakemake_workflow.git
```

3. Use prepare.py script to generate the samples.tsv file as an input for this pipeline using the following command:. 

```<DIR>``` is the location of the raw fastq files.

```bash
python utils/scripts/common/prepare.py <DIR>
```

## Config file

4. Make sure to change the paths to sample.tsv file and the main dada2 pipeline folder.

5. Include the correct primer sequences in config.yaml for primer removal.

6. Make sure you modify TRUNC and Trim parameters for DADA2's filter function in config file.

7. Download the taxonomy databases from http://www2.decipher.codes/Downloads.html  that you plan to use in utils/databases/ and consequently set the path for them in the config file.

8. Once confident with all the parameters first run the snakemake dry run command to make sure that pipeline is working.
 
 
 ```bash
 snakemake -np
 
 ```
 if the pipeline is working then we can run the following command:
 
 
 ```bash
 snakemake --use-conda --cores THREADS
 ```



## Output files and logs

### Log files
All logs are placed in output/logs

### Important result files:
#### output/dada2
      1. seqtab_nochimeras.rds
      2. seqtab_filterLength.rds
      3. Nreads.tsv
#### output/taxonomy
    1. <DATABASE>.tsv
    2. ASV_seq.fasta
    3. ASV_tree.nwk
