library(dada2)
library(ggplot2)
#sink(snakemake@log[[1]])


p_F<-lapply(1:length(snakemake@input$R1),
          function(x){
            plotQualityProfile(snakemake@input$R1)
          })

qp_F <- marrangeGrob(p_F, nrow=4, ncol=4)
ggsave(snakemake@output$R2),qp_F)


p_R<-lapply(1:length(snakemake@input$R2),
          function(x){
           plotQualityProfile(snakemake@input.R2)
          })

qp_R <- marrangeGrob(p_R, nrow=4, ncol=4)
ggsave(snakemake@output$R2),qp_R)





                   

