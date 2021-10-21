suppressMessages(library(dada2))
suppressMessages(library(DECIPHER))
sink(snakemake@log[[1]])

packageVersion("DECIPHER")

seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

print(snakemake)

dna <- DNAStringSet(getSequences(seqtab)) # Create a DNAStringSet from the ASVs

#load(snakemake@input[['ref']]) #trainingSet

print(snakemake@input[['species']])
print(snakemake@input[['ref']])

taxtab <- assignTaxonomy(seqtab, refFasta = snakemake@input[['ref']],tryRC=TRUE,multithread=20)
#colnames(taxtab)<-c("domain", "phylum", "class", "order", "family", "genus")


print(colnames(taxtab))

taxid<-addSpecies(taxtab=taxtab,refFasta=snakemake@input[['species']],allowMultiple=T, tryRC=TRUE)
#colnames(taxid)<-c("domain", "phylum", "class", "order", "family", "genus","species")

print( colnames(taxid))

write.table(taxid,snakemake@output[['taxonomy']],sep='\t')







