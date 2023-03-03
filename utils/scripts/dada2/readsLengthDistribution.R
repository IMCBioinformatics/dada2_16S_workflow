library(ggplot2)

# set the path to the directory containing the text files
path <- snakemake@input[['files']]

##reading files in and save them as objects
object_names <- list.files(path, pattern = "R1|R2",full.names = T)

for (i in 1:length(object_names)) {
  # Read in the object
  my_data <- read.table(object_names[i],header = F)
  # Save the updated object
  assign(x=gsub(".txt","",object_names[i]),value = my_data)
  
}
  
  
## fixing raw files
raw_objects <- ls(pattern = "raw")

for (i in raw_objects){
  # Read in the object
  my_data <- get(i)
  my_data<-data.frame(V1=seq_along(1:my_data$V1),V2=c(rep(x = 0,times=my_data$V1-1),rep(my_data$V2,times=1)))
  # Save the updated object
  assign(i,value = my_data)
}



object_names <- ls(pattern = "R1|R2")

#### Loop over each file and change the column names and save them as a new object each
for (i in object_names) {
# Read in the object
my_data <- get(i)

# Print the current column names
print(colnames(my_data))

# Change the column names
colnames(my_data) <- c("read_length", "num_reads")

# Print the new column names
print(colnames(my_data))

# Save the updated object
assign(i,value = my_data)
}



#add two columns of readtype and filetype to all object files based on a name

# select objects with specific names 

names <- c("raw","dada2","cutadapt")

# loop over the selected objects and add columns to them
for (i in names){
  objs <- ls(pattern = i)
    for (j in objs){
      x <- get(j)
      x <- cbind(x, filetype = i)
      colnames(x)
      assign(j, x)
    }
}


reads <- c("R1","R2")

# loop over the selected objects and add columns to them
for (i in reads){
  objs <- ls(pattern = i)
  for (j in objs){
    x <- get(j)
    x <- cbind(x, readtype = i)
    colnames(x)
    assign(j, x)
  }
}


## Merging all the raw, cutadapt, & dada2 files of all samples 
list_files <- read.table(snakemake@config[['list_files']], header=TRUE, row.names=1)
samples <- rownames(list_files)


# Create an empty data frame to store the combined data
combined_data <- data.frame()

# Loop through the list of object names and combine them using rbind
for (i in samples){
  obj_list=ls(pattern = i)
  for (j in obj_list) {
    obj <- get(j)
    if (is.data.frame(obj)) {
      combined_data <- rbind(combined_data, obj)
    }
    assign(x = paste0("combined_",i), combined_data)
  }
}



# Loop through each file
for (file in ls(pattern = "combined_")) {
  # Read in the file
  data <- get(file)
  
  # Convert the desired column to a factor
  data$filetype <- factor(data$filetype,levels = c("raw","cutadapt","dada2"))
  
  # Save the modified file back to disk
  assign(value = data, x = file)
}


##Making a distribution plot by a for loop
for (i in ls(pattern = "combined_")){
    temp=ggplot(get(i), aes(x=read_length,y=num_reads,fill="red"))+geom_col(width=4)+
    facet_wrap(readtype~filetype,ncol = 3,nrow = 2, strip.position = "top")+theme_bw()+
    labs(title = i)+xlab(label = "Length (bp)")+ylab(label = "Reads")+
    theme(legend.position = "none")
    ggsave(filename = snakemake@output[['outdir']],"/",i,"_qc.png"),temp)
}


