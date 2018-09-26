setwd("path_to_working_directory")

data<-read.delim(exp <- "output_from_corr_data.pl", header=FALSE)

head(data)
dim(data)

rownames(data)<-data[,1]
data<-data[,-1]

minexp <- 1
m<-as.data.frame(cor(t(data[rowSums(data)>minexp,]), method="spearman"))

corr_list = data.frame(row=rownames(m)[row(m)[upper.tri(m)]],
           col=colnames(m)[col(m)[upper.tri(m)]],
           corr=m[upper.tri(m)])

#corr_list[1:3,]

keep = corr_list[corr_list$corr >= 0.65,]

keep$corr <- format(round(keep$corr,2), nsmall=2)
#keep[1:3,]


write.table(keep, file="corr_data.txt", sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
