library(dada2)
library(DECIPHER)

seqtab = readRDS(snakemake@input[['seqtab']])

seqs <- colnames(seqtab)

names(seqs) <- seqs # This propagates to the tip labels of the tree

seq_stringset<-DNAStringSet(seqs)

writeXStringSet(seq_stringset,snakemake@output[['seqfasta']])

print("ASV sequences written to FASTA file")

alignment <- AlignSeqs(DNAStringSet(seqs), anchor=NA)

writeXStringSet(alignment,snakemake@output[['alignment']])

print("Multiple sequence alignment written to FASTA file")
