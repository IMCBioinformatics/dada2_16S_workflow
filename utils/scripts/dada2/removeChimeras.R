suppressMessages(library(dada2))


seqtab.all= readRDS(snakemake@input[['seqtab']]) # seqtab.all


# Remove chimeras
seqtab <- removeBimeraDenovo(seqtab.all, method=snakemake@config[['chimera_method']], multithread=snakemake@threads)

saveRDS(seqtab, snakemake@output[['rds']])
write.csv(seqtab, snakemake@output[['csv']])


track <- rowSums(seqtab)
names(track) <- row.names(seqtab)

write.table(track,col.names = c("nonchim"),
            snakemake@output[['nreads']],sep='\t')
