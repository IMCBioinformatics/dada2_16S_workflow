
# Amplicon sequencing DADA2 snakemake workflow

[![Conda](https://img.shields.io/badge/conda-v4.14.0-lightgrey)](https://docs.conda.io/en/latest/)
[![Snakemake](https://img.shields.io/badge/snakemake-7.21.0.1-blue)](https://snakemake.bitbucket.io)
[![DADA2](https://img.shields.io/badge/DADA2-v1.26.0-orange)](https://benjjneb.github.io/dada2/index.html)


This is a snakemake workflow for profiling microbial communities from amplicon sequencing
data using dada2. DADA2 tutorial can be found from https://benjjneb.github.io/dada2/index.html. The initial code was cloned from https://github.com/SilasK/amplicon-seq-dada2 and modified to make a workflow suitable for our needs.

<br>

In the dada2 pipeline, species assignment is accomplished through the application of a naive Bayesian classifier method (https://pubmed.ncbi.nlm.nih.gov/17586664/), where a strict requirement of a 100% nucleotide identity match between the reference sequences and the query is employed. To enhance the adaptability of the species assignment process, we leveraged an established tool to adjust the identity threshold to 99.3% (modifiable).
VSEARCH, an open-source alternative to the widely utilized USEARCH tool, is employed in this context. VSEARCH excels in performing optimal global sequence alignments for the query against potential target sequences.
For a more comprehensive understanding of this methodology, please refer to the paper available at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5075697/.

<br>

## Overview

Input: 
* Raw paired-end fastq files
* samples.tsv [example](example_files/samples.tsv)

Output:

* Taxonomic assignment tables using RDP classifier (by GTDB, RDP, SILVA, and URE databases), in addition to VSEARCH (by GTDB and URE databases).
* ASV abundance table (seqtab_nochimera.rds).
* ASV sequences in a fasta file from seqtab_nochimera.rds (ASV_seq.fasta).
* Summary of reads filtered at each step (Nreads.tsv).
* A phylogenetic tree (ASV_tree.nwk).

<br> 

## Pipeline summary

<img src="dag.svg" width= auto height= auto >

## Workflow

<details>
<summary><h3 style="font-size: 24px;">1. Prerequisites</h3></summary>
    
Please install the following tools before running this workflow. Please request an interactive session before starting the installation step by running the following command:

```bash
    salloc --mem=20G --time=05:00:00
```

conda (miniconda): https://conda.io/projects/conda/en/stable/user-guide/install/linux.html

snakemake: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html

</details>


<details>

<summary><h3 style="font-size: 24px;">2. Setting up environments</h3></summary>

Note: 
After installation, verify the installation of each tool by executing its name followed by the flag '-h'. For example, use fastqc -h to check if FastQC is installed. This command should display the help information or usage instructions for the tool, indicating successful installation.

For packages installed in R, initiate an R session within the same environment. Confirm the package installation by executing the library("package name") command, replacing "package name" with the actual name of the package. This will load the package in R, showing that it is properly installed and accessible in the current environment.

Next we need to set up a few environments to use in different steps of the pipeline.

#### 2.1. dada2 environment

To install r and dada2:

```bash
conda create -n dada2 -c conda-forge -c bioconda -c defaults --override-channels bioconductor-dada2
```

To activate the environment and install the required packages (dplyr, gridExtra, ggplot2, DECIPHER, Biostrings, limma) locally in R:

```bash
conda activate dada2
```

to open an R session within the dada2 environment type R, (dada2) [username@hostname ~]$ R


```bash
install.packages("gridExtra")
install.packages("ggplot2")
install.packages("dplyr")
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("DECIPHER")
BiocManager::install("Biostrings")
BiocManager::install("limma")
```

to quit R type q(), (dada2) [username@hostname ~]$ q() and deactivate the environment:

```bash
conda deactivate
```

<br>

#### 2.2. QC environment

To install fastqc, multiQC, cutadapt, and seqkit tools for quality control in a new environment:

```bash
conda create --name QC
conda activate QC
conda install -c bioconda fastqc==0.11.8
conda install pip
pip install multiqc
pip install pandas==1.5.3
pip install cutadapt
conda install -c bioconda seqkit
conda deactivate
```

<br>

#### 2.3 fastree_mafft environment 

To create an environment for generating a phylogenetic tree and a fasta file of ASVs:

```bash
conda create -n fastree_mafft
conda activate fastree_mafft
conda install -c bioconda fasttree
conda deactivate
```

<br>

#### 2.4 rmd environment

```bash
conda create -n rmd
conda activate rmd
conda install -c conda-forge r-base
conda install -c conda-forge pandoc
conda install -c conda-forge r-tidyverse
wget https://github.com/marbl/Krona/releases/download/v2.8.1/KronaTools-2.8.1.tar 
tar xf KronaTools-2.8.1.tar 
cd KronaTools-2.8.1
./install.pl --prefix=/softwares/miniconda/envs/rmd/
```

to open an R session within the dada2 environment type R, (rmd) [username@hostname ~]$ R

```bash
install.packages('DT')
install.packages("ggplot2")
install.packages("dplyr")
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("phyloseq") #This takes a while
install.packages("remotes")
remotes::install_github("cpauvert/psadd")
BiocManager::install("dada2")
BiocManager::install("limma")
BiocManager::install("kableExtra")
install.packages("RColorBrewer")
install.packages("ggpubr")
install.packages("waterfalls")
```

to quit R type q(), (rmd) [username@hostname ~]$ q() and deactivate the environment:

```bash
conda deactivate
```

<br>

#### 2.5 vsearch environment

```
conda create -n vsearch
conda activate vsearch
conda install -c "bioconda/label/cf201901" vsearch
conda deactivate
```

</details>
 

<details>
<summary><h3 style="font-size: 24px;">3. Usage</h3></summary> 

Then please follow these steps to set up and run the pipeline.

#### 3.1 Make sure that all the environments are set up and required packages are installed.

#### 3.2 Navigate to your project directory and clone this repository into that directory using the following command:

```bash
git clone https://github.com/IMCBioinformatics/dada2_snakemake_workflow.git
```

#### 3.3 Use prepare.py script to generate the samples.tsv file as an input for this pipeline using the following command: 

```<DIR>``` is the location of the raw fastq files.

```bash
python utils/scripts/common/prepare.py <DIR>
```

#### 3.4 Make sure to configure the config.yaml file.

##### 3.4.1 modifying pipeline parameters:
  - path of the input directory
  - name and path of the output directory
  - Forward and reverse reads format

##### 3.4.2 modifying QC parameters:
  - primer sequences (if they are sequenced)
  - primer removal (Optional: Set to "False" when primers are not sequenced)
  - quality trimming values
  
##### 3.4.3 modifying dada2 parameters:
  - DADA2 filter and trim thresholds
  - chimera removal method
  - number of reads for error rate learning

##### 3.4.4 modifying vsearch parameters:
  - identity threshold
  - maximum number of hits to consider per query
  - if URE should be used after using GTDB for speciation


#### 3.5 Download the taxonomy databases from http://www2.decipher.codes/Downloads.html that you plan to use in utils/databases/ and consequently set the path for them in the config file.

#### 3.6 Once confident with all the parameters first run the snakemake dry run command to make sure that pipeline is working.
 
 ```bash
 snakemake -np
 ```
Then snakemake can be executed by the following bash script:
 
 ```bash
 sbatch dada2_sbatch.sh
 ```
</details>


<details>
<summary><h3 style="font-size: 24px;">4. Output files and logs</h3></summary> 
 
To make sure that the pipeline is run completely, we need to check the log and output files.

#### 4.1 Log files
All logs are placed in the logs directory. 
A copy of all snakemake files and logs will be copied to the output directory (output/snakemake_files/) as well to avoid rewritting them by upcoming re-runs.

<br>

#### 4.2 Important result files:


##### 4.2.1 output/dada2
   - seqtab_nochimeras.rds
   - Nreads.tsv

<br>

##### 4.2.2 output/taxonomy
   - GTDB_RDP.tsv
   - RDP_RDP.tsv
   - Silva_RDP.tsv
   - URE_RDP.tsv
   - Vsearch_output.tsv

<br>

##### 4.2.3 output/phylogeny    
   - ASV_seq.fasta
   - ASV_tree.nwk

<br>

##### 4.2.4 output/QC_html_report
   - qc_report.html
</details>
