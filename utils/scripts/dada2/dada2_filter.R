suppressMessages(library(dada2))

sink(snakemake@log[[1]])


track.filt_keep_phix <- filterAndTrim(snakemake@input[['R1']],snakemake@output[['R1']], 
                            snakemake@input[['R2']],snakemake@output[['R2']], 
#                            truncLen= snakemake@config[["truncLen"]],
                            maxN=0,
                            maxEE=snakemake@config[["maxEE"]], 
                            truncQ=snakemake@config[["truncQ"]],
                            compress=TRUE,
                            verbose=TRUE,
                            multithread=snakemake@threads,
                            rm.phix=FALSE)

track.filt <- filterAndTrim(snakemake@input[['R1']],snakemake@output[['R1']], 
                            snakemake@input[['R2']],snakemake@output[['R2']], 
#                            truncLen= snakemake@config[["truncLen"]],
                            maxN=0,
                            maxEE=snakemake@config[["maxEE"]], 
                            truncQ=snakemake@config[["truncQ"]],
                            compress=TRUE,
                            verbose=TRUE,
                            multithread=snakemake@threads,
                            rm.phix=TRUE)





row.names(track.filt) <- snakemake@params[["samples"]]
row.names(track.filt_keep_phix) <- snakemake@params[["samples"]]

colnames(track.filt) = c('afterCutadapt','filtered')

write.table(track.filt,snakemake@params[['nread']],  sep='\t')

print(track.filt)
print("****")
print(track.filt_keep_phix)

percent_phix=data.frame(percent_phix=100*(track.filt_keep_phix[,2]-track.filt[,2])/track.filt[,1])

print("}}}}")

print(percent_phix)

print(snakemake@params[['percent_phix']])

write.table(percent_phix,snakemake@params[['percent_phix']],  sep='\t')
