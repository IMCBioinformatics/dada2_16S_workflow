suppressMessages(library(dada2))
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))


seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

# Length of sequences
seq_lengths = nchar(getSequences(seqtab))

l_hist = as.data.frame(table(seq_lengths))
colnames(l_hist) <- c("LENGTH", "FREQUENCY")
l_hist$LENGTH <- as.numeric(as.character(l_hist$LENGTH))


table2 <- tapply(colSums(seqtab), seq_lengths, sum)
table2 <- data.frame(LENGTH = as.numeric(names(table2)), ABUNDANCE = table2, stringsAsFactors = FALSE)

final <- left_join(l_hist, table2, by = "LENGTH")


# Check for NA values
#print(sum(is.na(final)))

# Coefficient to adjust y2 to fit y1's scale
coef <- max(final$FREQUENCY, na.rm = TRUE) / max(final$ABUNDANCE, na.rm = TRUE)

# Convert LENGTH to factor
final$LENGTH <- as.factor(final$LENGTH)


# Create the plot
p <- ggplot(final, aes(x = LENGTH)) +
  geom_bar(aes(y = FREQUENCY, fill = "FREQUENCY"), stat="identity", color = "black") +
  geom_line(aes(y = ABUNDANCE * coef, group = 1, color = "Abundance"), size = 1) +
  scale_y_continuous(sec.axis = sec_axis(~./coef + 1e-10, name = "Abundance")) +
  scale_color_manual(name = NULL,
                     values = c("FREQUENCY" = "black", "Abundance" = "orange"),
                     labels = c("FREQUENCY" = "FREQUENCY", "Abundance" = "Abundance")) +
  scale_fill_manual(values = "grey70") +
  ggtitle("ASVs length distribution") +
  labs(caption =
  "The plot visualizes the distribution of ASVs (Amplicon Sequence Variants)
  by their length. The grey bars represent the count of ASVs at each
  specific length, indicating how frequently ASVs of that length occur
  in the dataset. The orange line illustrates the abundance of ASVs, which
  reflects the total number of sequences for ASVs of each length.") +
  theme(plot.caption = element_text(hjust = 0,size=12),
        axis.text.x = element_text(angle = 45, size = 12, colour = "black",  hjust = 1, face= "bold"),
        axis.title.y = element_text(size = 12, face = "bold"),
        legend.title = element_text(size = 16, face = "bold"),
        axis.title.x = element_text(size = 12, face = "bold"),
        legend.text = element_text(size = 12, face = "bold", colour = "black"),
        axis.text.y = element_text(colour = "black", size = 12, face = "bold"),
        plot.title = element_text(size=14,face="bold"),
        panel.background = element_blank(),
        panel.border =element_rect(fill = NA, color = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(colour = "black"),
        legend.position = "bottom")




if (!is.null(p)) {
  print("The plot is generated and stored in 'p'.")
} else {
  print("No plot is generated in 'p'.")
}


ggsave(snakemake@output[['plot_seqlength']],plot=p)



