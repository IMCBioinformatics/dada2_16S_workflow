suppressMessages(library(dada2))
suppressMessages(library(ggplot2))
suppressMessages(library(gridExtra))

#sink(snakemake@log[[1]])


p_F<-lapply(1:length(snakemake@input$R1),
          function(x){
	  print(snakemake@input$R1[x])
            plotQualityProfile(snakemake@input$R1[x],n=1e5) + theme_classic(base_size=6)

          })

print("Out of plotQualityProfile")

qp_F <- marrangeGrob(p_F, nrow=2, ncol=2)

print("Out of grob")


ggsave(snakemake@output$R1,qp_F)
print(snakemake@output$R1)


p_R<-lapply(1:length(snakemake@input$R2),
          function(x){
	  print(snakemake@input$R2[x])

           plotQualityProfile(snakemake@input$R2[x],n=1e5) + theme_classic(base_size=6)
          })

print("Out of plotQualityProfile")

qp_R <- marrangeGrob(p_R, nrow=2, ncol=2)

print("Out of grob")

ggsave(snakemake@output$R2,qp_R)

print("Out of saving")

                   

