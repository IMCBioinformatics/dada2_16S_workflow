suppressMessages(library(dada2))
suppressMessages(library(ggplot2))


errF <- learnErrors(snakemake@input[['R1']], nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads)
errR <- learnErrors(snakemake@input[['R2']], nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads)
save(errF,file=snakemake@output[['errR1']])
save(errR,file=snakemake@output[['errR2']])

print("Order of samples read in before learning error rates")
print(snakemake@input[['R1']])
print(snakemake@input[['R2']])


## ---- plot-rates ----
p<-plotErrors(errF,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr1']],plot=p)
p<-plotErrors(errR,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr2']],plot=p)




