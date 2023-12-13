suppressMessages(library(dada2))


fnFs <- snakemake@input[['R1']]
fnRs <- snakemake@input[['R2']]

filtFs <- snakemake@output[['R1']]
filtRs <- snakemake@output[['R2']]


track.filt_keep_phix <- filterAndTrim(fnFs,filtFs, 
                            fnRs,filtRs, 
#                            truncLen= snakemake@config[["truncLen"]],
                            maxN=0,
                            maxEE=snakemake@config[["maxEE"]], 
                            truncQ=snakemake@config[["truncQ"]],
                            compress=TRUE,
                            verbose=TRUE,
                            multithread=snakemake@threads,
                            rm.phix=FALSE)

track.filt <- filterAndTrim(fnFs,filtFs, 
                            fnRs,filtRs, 
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

track.filt<-data.frame(track.filt)
track.filt <- track.filt[track.filt$filtered > 0, ]

write.table(track.filt,snakemake@params[['nread']],  sep='\t')

percent_phix=data.frame(percent_phix=100*(track.filt_keep_phix[,2]-track.filt[,2])/track.filt[,1])

write.table(percent_phix,snakemake@params[['percent_phix']],  sep='\t')
