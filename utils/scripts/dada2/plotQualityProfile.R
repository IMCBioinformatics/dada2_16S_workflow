suppressMessages(library(dada2))
suppressMessages(library(ggplot2))
suppressMessages(library(gridExtra))

#sink(snakemake@log[[1]])


p_F<- plotQualityProfile(snakemake@input$R1,n=1e5,aggregate=T) + theme_classic(base_size=6)
print("Out of plotQualityProfile R1")


ggsave(snakemake@output$R1,p_F)


p_R<- plotQualityProfile(snakemake@input$R2,n=1e5,aggregate=T) + theme_classic(base_size=6)

print("Out of plotQualityProfile R2")

ggsave(snakemake@output$R2,p_R)
print("Out of saving Quality profiles")

                   

