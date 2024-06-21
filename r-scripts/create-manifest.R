# Read in SRA sample IDs and list of raw fastq files to generate a manifest file ready for qiime2 import

# Change working directory to sequences
setwd("/scratch/group/hu-lab/code-club-test/amplicon-qiime2-intro/")

# Required libraries
library(tidyverse)

# Import all files in current directory
paths <- as.data.frame(list.files(pattern = ".fastq.gz", full.names = TRUE))

colnames(paths)[1]<-"FASTQ"

# Get local path & add to dataframe
path_to_files <- getwd()
paths$PATH <- path_to_files

# Extract sample ID
paths_run <- paths %>% 
## Use for sampleid_L001_Rx_001.fastq.gz
	mutate(SAMPLEID = str_replace(FASTQ, "(\\w*?)_MCR_(\\w*?)_L001_R((\\w+))_001.fastq.gz","\\2"))

## Use for _R1.fastq.gz
#	mutate(SAMPLEID = str_replace(FASTQ, "(\\w*?)_R((\\d)).fastq.gz","\\1")) %>%
#	separate(SAMPLEID, c("SAMPLEID", "else"), sep = "_L001_")
#
## ^See wildcard options on this line to modify how R script pulls out your sample IDs from fastq files

paths_run$SAMPLEID <- gsub("./","", paths_run$SAMPLEID)
paths_run$FASTQ <- gsub("./","", paths_run$FASTQ)

# Write full path
paths_run$FULL_PATH <- paste(paths_run$PATH, paths_run$FASTQ, sep="/")

forward <- paths_run %>%
	filter(grepl("R1_001.fastq.gz|_1.fastq.gz|R1.fastq.gz", FASTQ)) %>%
	select(SAMPLEID, `forward-absolute-filepath` = FULL_PATH)

# Write manifest file
manifest <- paths_run %>%
	filter(grepl("R2_001.fastq.gz|_2.fastq.gz|R2.fastq.gz", FASTQ)) %>%
	select(SAMPLEID, `reverse-absolute-filepath` = FULL_PATH) %>%
	right_join(forward) %>%
	select('sample-id' = SAMPLEID, `forward-absolute-filepath`, `reverse-absolute-filepath`)

# Write output as a manifest file
write.table(manifest, file = "/home/skhu/amplicon-tutorial/manifest", quote=FALSE,col.names=TRUE,row.names=FALSE,sep="\t")


