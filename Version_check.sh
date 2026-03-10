
# *********************
# *** version check ***
# *********************

#!/bin/bash


# ***** WARNING: Please ensure that the script is run with the correct environment names.
# ***** This script may not work properly if different names have been assigned to created local enviroments.



#Innitalize conda
conda init bash &> /dev/null

#refresh shell environment after conda init
source ~/.bashrc &> /dev/null

echo “Started at: `date`” && echo -e "\n"


#Conda version
echo "conda version:" && conda --version && echo -e "\n"

#Tools in snakemake env
conda activate snakemake
echo "python version from snakemake environment:" && python --version && echo -e "\n"
echo "snakemake version from snakemake environment:" && snakemake --version && echo -e "\n"
conda deactivate


#Packages in dada2 env
conda activate dada2
echo "dada2 version from dada2 environment:" && Rscript -e "packageVersion('dada2')" && echo -e "\n"
echo "gridExtra version from dada2 environment:" && Rscript -e "packageVersion('gridExtra')" && echo -e "\n"
echo "ggplot2 version from dada2 environment:" && Rscript -e "packageVersion('ggplot2')" && echo -e "\n"
echo "dplyr version from dada2 environment:" && Rscript -e "packageVersion('dplyr')" && echo -e "\n"
echo "BiocManager version from dada2 environment:" && Rscript -e "packageVersion('BiocManager')" && echo -e "\n"
echo "DECIPHER version from dada2 environment:" && Rscript -e "packageVersion('DECIPHER')" && echo -e "\n"
echo "Biostrings version from dada2 environment:" && Rscript -e "packageVersion('Biostrings')" && echo -e "\n"
echo "limma version from dada2 environment:" && Rscript -e "packageVersion('limma')" && echo -e "\n"
conda deactivate


#Tools and packages in QC env
echo "fastqc version from QC environment:" && conda activate QC && fastqc --version && echo -e "\n"
echo "multiqc version from QC environment:" && conda activate QC && multiqc --version && echo -e "\n"
echo "cutadapt version from QC environment:" && conda activate QC && cutadapt --version && echo -e "\n"
echo "seqkit version from QC environment:" && conda activate QC && seqkit version && echo -e "\n"
echo "pandas version from QC environment:" && conda activate QC && python -c "import pandas as pd; print(pd.__version__)"  && echo -e "\n"
conda deactivate


#Tools in fastree_mafft env
conda activate fastree_mafft
echo "fasttree version from fastree_mafft environment:" && fasttree 2>&1 | grep -i "version" | sed -n 's/.*version \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p' && echo -e "\n"
conda deactivate


#Tools and packages in rmd env
conda activate rmd
echo "R version from rmd environment:" && R --version | grep -i version | sed -n 's/.*version \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p' && echo -e "\n"
echo "pandoc version from rmd environment:" && pandoc --version |  head -n 1 && echo -e "\n"
echo "tidyverse version from rmd environment:" && Rscript -e "packageVersion('tidyverse')" && echo -e "\n"
echo "kableExtra version from rmd environment:" && Rscript -e "packageVersion('kableExtra')" && echo -e "\n"
echo "dada2 version from rmd environment:" && Rscript -e "packageVersion('dada2')" && echo -e "\n"
echo "ggpubr version from rmd environment:" && Rscript -e "packageVersion('ggpubr')" && echo -e "\n"
echo "DT version from rmd environment:" && Rscript -e "packageVersion('DT')" && echo -e "\n"
echo "ggplot2 version from rmd environment:" && Rscript -e "packageVersion('ggplot2')" && echo -e "\n"
echo "BiocManager version from rmd environment:" && Rscript -e "packageVersion('BiocManager')" && echo -e "\n"
echo "phyloseq version from rmd environment:" && Rscript -e "packageVersion('phyloseq')" && echo -e "\n"
echo "remotes version from rmd environment:" && Rscript -e "packageVersion('remotes')" && echo -e "\n"
echo "psadd version from rmd environment:" && Rscript -e "packageVersion('psadd')" && echo -e "\n"
echo "RColorBrewer version from rmd environment:" && Rscript -e "packageVersion('RColorBrewer')" && echo -e "\n"
echo "limma version from rmd environment:" && Rscript -e "packageVersion('limma')" && echo -e "\n"
echo "waterfalls version from rmd environment:" && Rscript -e "packageVersion('waterfalls')" && echo -e "\n"
echo "plotly version from rmd environment:" && Rscript -e "packageVersion('plotly')" && echo -e "\n"


#Tools in vsearch env
conda activate vsearch
echo "vsearch version from vsearch environment:" && vsearch 2>&1 | head -n 1 | sed -n 's/.*v\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/v\1/p'
conda deactivate && echo -e "\n"


echo "Finished at: `date`"
