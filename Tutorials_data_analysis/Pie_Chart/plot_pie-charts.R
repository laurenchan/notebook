library(ggplot2)
library(dplyr)
library("viridis") 
library(ggsci)
library(wesanderson)

mysum2 <- read.delim("summary2.txt", header=T, sep="\t")
mysum2 <- as.data.frame(mysum2)

mysum2$Sample <- factor(mysum2$Sample, levels=c("Prey", "Total", "Pitfall", "Dipnet"))
mysum2$Taxon <- factor(mysum2$Taxon, levels=c("Coleoptera ",
"Collembola ",
"Diptera ",
"Hemiptera ",
"Hymenoptera",
"Lepidoptera",
"Odonata ",
"Orthoptera",
"Unknown Hexapoda",
"Arachnida",
"Myriapoda",
"Nematoda ",
"Annelida",
"Gastropoda ",
"Crustacea",
"Vertebrata "))

myplot2 <- ggplot(data=mysum2, aes(x="", y=Percent, group=Taxon, color=Taxon, fill=Taxon)) +
    geom_bar(width=1, stat="identity", color="gray", cex=0.2) +
    coord_polar("y", start=0) +
    facet_wrap(~ Sample) +
    theme(axis.text = element_blank(), 
          axis.ticks = element_blank(),
          panel.grid  = element_blank()) +
    scale_color_viridis(discrete = TRUE)+
    scale_fill_viridis(discrete = TRUE, option="D")
    
mycol<-rainbow(16)

myplot3 <- ggplot(data=mysum2, aes(x="", y=Percent, group=Taxon, color=Taxon, fill=Taxon)) +
    geom_bar(width=1, stat="identity", color="gray", cex=0.1) +
    coord_polar("y", start=0) +
    facet_wrap(~ Sample) +
    theme(axis.text = element_blank(), 
          axis.ticks = element_blank(),
          panel.grid  = element_blank()) +
    scale_fill_manual(values=mycol)
    

pdf(file="pie_neat.pdf")
myplot2
dev.off()

pdf(file="vers2.pdf")
myplot3
dev.off()
