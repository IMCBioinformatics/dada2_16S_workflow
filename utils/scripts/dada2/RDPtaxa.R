
suppressMessages(library(dada2))
suppressMessages(library(Biostrings))


seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

set.seed(snakemake@config[['seed']]) # Initialize random number generator for reproducibility

taxtab <- assignTaxonomy(seqtab, refFasta = snakemake@input[['ref']],tryRC=TRUE,multithread=snakemake@threads,outputBootstraps = T)
saveRDS(taxtab,file=snakemake@output[['rds_bootstrap']])

taxtab<-addSpecies(taxtab$tax[,1:6], refFasta=snakemake@input[['species']],tryRC=TRUE,allowMultiple = TRUE)

write.table(taxtab,snakemake@output[['taxonomy']],sep='\t')
