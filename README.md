
Amplicon sequencing DADA2 snakemake workflow

[![Snakemake](https://img.shields.io/badge/snakemake-v5.12.3-blue)](https://snakemake.bitbucket.io)
[![DADA2](https://img.shields.io/badge/DADA2-v1.14-orange)](https://benjjneb.github.io/dada2/index.html)
[![Conda](https://img.shields.io/badge/conda-v4.8.3-lightgrey)](https://docs.conda.io/en/latest/)


This is a snakemake workflow for profiling composition of microbial communities from amplicon sequencing
data (16s, with slight modifications for 18s and ITS)  using dada2.



## Overview

Input: 
* Raw paired-end fastq files
* samples.tsv [example](samples.tsv)

Output:

* Taxonomic assignment tables for specified databases (GTDB, RDP, SILVA).
* ASV abundance table (seqtab_nochimera.rds, seqtab_fitlerLength.rds)
* ASV sequences in a fasta file from seqtab_nochimera.rds
* Summary of reads filtered at each step (Nreads.tsv)


Output:

* Taxonomic assignment tables for specified databases (GTDB,RDP,SILVA).
* ASV abundance table (seqtab_nochimera.rds, seqtab_fitlerLength.rds)
* ASV sequences in a fasta file from seqtab_nochimera.rds
* Summary of reads filtered at each step (Nreads.tsv)


## Pipeline summary

<img src="utils/rulegraph.png" width="450">

