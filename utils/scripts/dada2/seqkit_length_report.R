#!/usr/bin/env Rscript	
args = commandArgs(trailingOnly=TRUE)

library(ggplot2)
library(limma)

##reading files in and save them as objects
object_names <- list.files(args[1], pattern = "R1|R2",full.names = T)


for (i in 1:length(object_names)) {
  # Read in the object
  my_data <- read.table(object_names[i],header = F)
  # Save the updated object
  assign(x=gsub(".txt","",basename(object_names[i])),value = my_data)
  
}


## fixing raw files
raw_objects <- ls(pattern = "raw")

for (i in raw_objects){
  # Read in the object
  my_data <- get(i)
  if (nrow(my_data) == 1){ #this for times that primers are already removed from raw reads and they are not the same length anymore
    my_data <- data.frame(
      V1 = seq_along(1:my_data$V1),
      V2 = c(rep(x = 0, times = my_data$V1-1), rep(my_data$V2, times = 1))) # Add missing closing parentheses
    #Save the updated object
    assign(i, value = my_data)
  }
}



object_names <- ls(pattern = "R1|R2")

#### Loop over each file and change the column names and save them as a new object each
for (i in object_names) {
  # Read in the object
  my_data <- get(i)
  
  # Print the current column names
  #print(colnames(my_data))
  
  # Change the column names
  colnames(my_data) <- c("read_length", "num_reads")
  
  # Print the new column names
  #print(colnames(my_data))
  
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


reads <- c("_R1","_R2")

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



names<-unique(strsplit2(object_names,split="_R[1-2]")[,1])

# Loop through the list of object names and combine them using rbind
for (i in names){
  obj_list=ls(pattern = i)
  combined_data <- data.frame() # Create an empty data frame to store the combined data
  for (j in obj_list) {
    obj <- get(j)
    if (is.data.frame(obj)) {
      combined_data <- rbind(combined_data, obj)
      assign(x = paste0("combined_",i), combined_data)
    }
  }
}


rm(combined_data)

# Loop through each file and make column filetype a factor
for (file in ls(pattern = "combined_")) {
  # Read in the file
  data <- get(file)
  
  # Convert the desired column to a factor
  data$filetype <- factor(data$filetype,levels = c("raw","cutadapt","dada2"))
  
  # Save the modified file back to disk
  assign(value = data, x = file)
}


files=ls(pattern = "combined_")

##Making a distribution plot by a for loop
for (i in 1:length(files)){
  temp=ggplot(get(files[i]), aes(x=read_length,y=num_reads,fill="red"))+geom_col(width=4)+
    facet_wrap(readtype~filetype,ncol = 3,nrow = 2, strip.position = "top")+theme_bw()+
    labs(title = files[i])+xlab(label = "Length (bp)")+ylab(label = "Reads")+
    theme(legend.position = "none")
  ggsave(filename = paste0(args[2],"/","S",i,"_ASVLength.png"),temp)
}



















