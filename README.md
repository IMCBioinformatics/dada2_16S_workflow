
# Amplicon sequencing DADA2 snakemake workflow

[![Snakemake](https://img.shields.io/badge/snakemake-v6.13.1-blue)](https://snakemake.bitbucket.io)
[![DADA2](https://img.shields.io/badge/DADA2-v1.14-orange)](https://benjjneb.github.io/dada2/index.html)
[![Conda](https://img.shields.io/badge/conda-v4.11.0-lightgrey)](https://docs.conda.io/en/latest/)


This is a snakemake workflow for profiling microbial communities from amplicon sequencing
data using dada2. The initial code was cloned from https://github.com/SilasK/amplicon-seq-dada2 
and modified to make a workflow suitable for my needs.

## Overview

Input: 
* Raw paired-end fastq files
* samples.tsv [example](samples.tsv)

Output:

* Taxonomic assignment tables for specified databases (GTDB, RDP, SILVA).
* ASV abundance table (seqtab_nochimera.rds, seqtab_fitlerLength.rds)
* ASV sequences in a fasta file from seqtab_nochimera.rds
* Summary of reads filtered at each step (Nreads.tsv)


## Pipeline summary

<img src="rulegraph.png" width="600">


## How to Use

1. Please make sure you have installed conda (miniconda) before running this workflow.


2. Use prepare.py to generate samples.tsv. 
 ``` prepare.py <DIR> ```
<DIR> is the location of the raw fastq files.

```bash
python utils/scripts/common/prepare.py <DIR>
```

Config file

3. Include the correct primer sequences in config.yaml 

4. Make sure you modify TRUNC and Trim parameters for DADA2's filter function in config.yaml

5. Download the taxonomy databases from http://www2.decipher.codes/Downloads.html  that you plan to use in utils/databases/.

6. Once confident with all the parameters you can run
 ``` snakemake --use-conda --cores THREADS ```



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
