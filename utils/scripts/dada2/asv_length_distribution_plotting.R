suppressMessages(library(dada2))
suppressMessages(library(ggplot2))


seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

# Length of sequences

seq_lengths= nchar(getSequences(seqtab))

l_hist= as.data.frame(table(seq_lengths))
colnames(l_hist) <- c("LENGTH","COUNT")

p<-ggplot(l_hist,aes(x=LENGTH,y=COUNT)) + 
  geom_histogram(stat="identity") + 
  ggtitle("Sequence Lengths by SEQ Count") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5,size=10)) +
  theme(axis.text.y=element_text(size=10))+
  labs(subtitle = "Length of ASVs ")

ggsave(snakemake@output[['plot_seqlength']],plot=p)

table2 <- tapply(colSums(seqtab), seq_lengths, sum)
table2 <- data.frame(key=names(table2), value=table2,stringsAsFactors = F)
colnames(table2) <- c("LENGTH","ABUNDANCE")


p<-ggplot(table2,aes(x=LENGTH,y=ABUNDANCE)) + 
  geom_histogram(stat="identity") + 
  ggtitle("Sequence Lengths by SEQ Abundance") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5,size=10)) +
  theme(axis.text.y=element_text(size=10))+
  labs(subtitle ="Total count of each ASV in all samples")

ggsave(snakemake@output[['plot_seqabundance']],plot=p)
