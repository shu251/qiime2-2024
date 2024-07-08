# Set up R working environment
library(tidyverse)

# Import taxonomy
tax_names <- read_delim(file = "q2-output/taxonomy.tsv")

# Import ASV table
asv_table <- read_delim(file = "q2-output/samples-asv-table.tsv", skip = 1)


# Change name of first column of each dataframe to match & merge them
colnames(asv_table)[1] <- c("Feature ID")

# Check to make sure "Feature ID" is the same for each
colnames(asv_table)
colnames(tax_names)

# Merge them
asv_results <- asv_table %>% 
  left_join(tax_names)

# Parse taxonomic names
## 9 levels are now in the PR2 database: https://pr2-database.org/documentation/pr2-taxonomy-9-levels/
asv_results_parsed <- asv_results %>% 
  separate(Taxon, into = c("Domain", "Supergroup", "Division", "Subdivision", "Class", "Order", "Family", "Genus", "Species"), sep = ";", remove = FALSE)

