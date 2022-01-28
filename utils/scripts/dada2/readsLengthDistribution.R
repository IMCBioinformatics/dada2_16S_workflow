library(ShortRead)
library(seqTools)
library(qckitfastq)
library(ggplot2)
library(dplyr)
library(tibble)

num=5
print(c("Number of random samples for QC:",num))

samples=read.table(snakemake@input[['sampleTBL']])


dir.create(snakemake@output[['result']])

rawPath=dirname(samples$R2[1])
q20Path="output/cutadapt_qc"
dada2filterPath="output/dada2/dada2_filter"

print(c("Raw directory: ",rawPath))
samples$R1=basename(samples$R1)
samples$R2=basename(samples$R2)

samples$name<-rownames(samples)

remove_samples="DNA|Water|undetermined"
print(c("Samples not included in random selection:",remove_samples))
samples<-samples[-grep(pattern = "DNA|Water|undetermined",samples$name),] 
fiveRandom=samples[sample (samples$name, size=5, replace =F),]



for(i in 1:num){
    ## raw reads R1
    fname=paste0(rawPath,"/",fiveRandom$R1[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R1"
    read_len$type="raw"
    read_len$name=fiveRandom$name[i]
    
    if(!exists("all_reads")) {
        all_reads <- read_len
    } else{
        all_reads <- bind_rows(read_len, all_reads)
    }
    
    ## cutadapt 20 R1
    fname=paste0(q20Path,"/",fiveRandom$R1[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R1"
    read_len$type="cutadapt_trimming"
    read_len$name=fiveRandom$name[i]
    
    all_reads<-bind_rows(read_len,all_reads)
    ## dada2 R1
    fname=paste0(dada2filterPath,"/",fiveRandom$R1[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R1"
    read_len$type="dada2_filtering"
    read_len$name=fiveRandom$name[i]
    all_reads<-bind_rows(read_len,all_reads)
    
    
    
    ## raw reads R2
    fname=paste0(rawPath,"/",fiveRandom$R2[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R2"
    read_len$type="raw"
    read_len$name=fiveRandom$name[i]
    all_reads<-bind_rows(read_len,all_reads)
    
    ## cutadapt 20 R2
    fname=paste0(q20Path,"/",fiveRandom$R2[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R2"
    read_len$type="cutadapt_trimming"
    read_len$name=fiveRandom$name[i]
    
    all_reads<-bind_rows(read_len,all_reads)
    ## dada2 R2
    fname=paste0(dada2filterPath,"/",fiveRandom$R2[i])
    read_len <-  seqTools::fastqq(fname) %>%read_length(.)
    read_len$readtype="R2"
    read_len$type="dada2_filtering"
    read_len$name=fiveRandom$name[i]
    all_reads<-bind_rows(read_len,all_reads)
    all_reads$type<-factor(all_reads$type)
    all_reads$type<-relevel(all_reads$type,ref = "raw")
       }


for(i in 1:num){

p<-all_reads %>% filter(name==fiveRandom$name[i]) %>% 
        ggplot(aes(x=read_length,y=num_reads,color="red",fill="red"))+geom_col()+
        facet_wrap(readtype~type,ncol = 3,nrow = 2)+theme_bw()+
    labs(title = fiveRandom$name[i])+
    xlab(label = "Length (bp)")+ylab(label = "Reads")+
    theme(legend.position = "none")
ggsave(filename = paste0(snakemake@output[['result']],"/S",i,"_qc.png"),p) 
}




