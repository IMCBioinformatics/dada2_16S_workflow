suppressMessages(library(dada2))
suppressMessages(library(Biostrings))
#suppressMessages(library(DECIPHER))


#packageVersion("DECIPHER")

seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

print(snakemake)

dna <- DNAStringSet(getSequences(seqtab)) # Create a DNAStringSet from the ASVs

#load(snakemake@input[['ref']]) #trainingSet

print(snakemake@input[['species']])
print(snakemake@input[['ref']])


set.seed(snakemake@config[['seed']]) # Initialize random number generator for reproducibility

taxtab <- assignTaxonomy(seqtab, refFasta = snakemake@input[['ref']],tryRC=TRUE,multithread=snakemake@threads,outputBootstraps = T)

print( colnames(taxtab$tax))
write.table(taxtab$tax,snakemake@output[['taxonomy']],sep='\t')
saveRDS(taxtab,file=snakemake@output[['rds_bootstrap']])





