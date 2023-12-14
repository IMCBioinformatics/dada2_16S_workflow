suppressMessages(library(dada2))
suppressMessages(library(ggplot2))
suppressMessages(library(gridExtra))
suppressMessages(library(ShortRead))

filtFs = snakemake@input[['R1']]
filtRs = snakemake@input[['R2']]


exists <- file.exists(filtFs) & file.exists(filtRs)
filtFs <- filtFs[exists]
filtRs <- filtRs[exists]

# Create a function to count reads in a FASTQ file
count_reads <- function(file_path) {
  reads <- readFastq(file_path)
  return(length(reads))
}


# Iterate through the list of FASTQ files and count reads
valid_filtFs <- character(0)  # To store valid file paths

for (file_path in filtFs) {
  read_count <- count_reads(file_path)
  if (read_count > 0) {
    valid_filtFs <- c(valid_filtFs, file_path)
  } else {
    print(paste("File:", file_path, "has zero reads and will be disregarded.\n"))
  }
}


# Iterate through the list of FASTQ files and count reads
valid_filtRs <- character(0)  # To store valid file paths

for (file_path in filtRs) {
  read_count <- count_reads(file_path)
  if (read_count > 0) {
    valid_filtRs <- c(valid_filtRs, file_path)
  } else {
    print(paste("File:", file_path, "has zero reads and will be disregarded.\n"))
  }
}


p_F<- plotQualityProfile(valid_filtFs,n=1e5,aggregate=T) + theme_classic(base_size=6)
print("Out of plotQualityProfile R1")


ggsave(snakemake@output$R1,p_F)


p_R<- plotQualityProfile(valid_filtRs,n=1e5,aggregate=T) + theme_classic(base_size=6)

print("Out of plotQualityProfile R2")

ggsave(snakemake@output$R2,p_R)
print("Out of saving Quality profiles")

                   

