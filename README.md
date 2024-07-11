# QIIME2 protocol

The below tutorial is meant to be a primer for using QIIME2 on an HPC. This was written for training purposes and often refers to the HPRC system we use at TAMU.

Example data uses 18S rRNA gene sequences, but any amplicon sequences can be used. Refer to the QIIME2 documentation for more information. 

_Last updated July 2024_

## 1.0 Set up working area

There are two ways to "install" or "use" QIIME2 on an HPRC system. 

*(1.1)* One is to use Anaconda or _conda_. Conda is a package and software manager that allows a user to install programs on their own. As long as your HPRC system has conda installed, you can install any program available through conda. An alternative to this (but same idea) is mamba. 

*(1.2)* The second way is to see if a recent version of QIIME2 is already available on your HPRC system. 

_Reminder_ about the flow of data/information on the HPRC. When you login, you are on a "Login node". A login node has access to everything stored on the cluster, but it has little computing power. So it is really like a "staging area" to plan out your jobs. When you submit something to the "compute node", that is when you get access to larger amounts of CPUs and memory. Usually this is done through a job scheduler, like SLURM. Since we use SLURM, a lot of the below instructions are catered to slurm and all the scripts for running QIIME2 in SLURM can be found in `slurm-scripts`. 

When you work on the HPRC, you typically have a *HOME* and *SCRATCH* space desginated to you. Keep all your code, notes, and important files in HOME. Always write output files, etc. to your SCRATCH space. It is like a working bench top to put everything. Once you make sure you like the product, you can clean up the scratch space by removing what you don't use and save what you need to keep (likely home or wherever you have the most storage). To find the path to home and scratch try executing: `$SCRATCH` and `$HOME`


As an example my home and scratch spaces:

* Home: `/home/skhu/`

* Scratch: `/scratch/user/skhu/`


To get the code and example manifest file from here, clone this repo.

```
git clone https://github.com/shu251/qiime2-2024.git
``` 
 

### 1.1 QIIME2 with Anaconda environment

Create a conda environment to install QIIME2. Only make conda environments in your personal scratch directory. To do this on the TAMU HPRC, follow the below instructions.

```
cd $SCRATCH                                     # Make scratch your current directory
module load Anaconda3/2024.02-1                 # Load Anaconda module (you can use the latest version)
conda config --set auto_activate_base False     # run once to disable auto Anaconda loading
```

You only need to do the above once.

#### Install QIIME2 as a conda environment

Execute the below set of commands. This may take some time. *wget* downloads the latest version of QIIME2 that is available. This is an *environment* file, which ends in _.yml_. Then use anaconda to create your environment. The name of this environment will be ```qiime2-amplicon-2024.5```.

```
wget https://data.qiime2.org/distro/amplicon/qiime2-amplicon-2024.5-py38-linux-conda.yml
conda env create -n qiime2-amplicon-2024.5 --file qiime2-amplicon-2024.5-py38-linux-conda.yml
```
Once the environment is "solved", and completed, you can remove the .yml file.
```
rm qiime2-amplicon-2024.5-py38-linux-conda.yml
```

### 1.2 Find QIIME2 on HPC

**See if your HPC has it installed with ```module load QIIME2```.**

On the TAMU HPRC, use ```module load QIIME2/2023.2```

Once you have QIIME2 installed and activated, test it by calling the help menu.

```
qiime --help
```

## 2.0 Make manifest file

### 2.1 Locate raw sequences

To learn QIIME2, see ```/scratch/group/hu-lab/code-club-test/amplicon-qiime2-intro```.

Always review the importing protocol for qiime2, as the format sometimes changes for the manifest file. See this site: https://docs.qiime2.org/2024.5/tutorials/importing/

The most common fastq file type you will get back is an already de-multiplexed set of files. You should have an R1 and R2 for each sample you submitted for sequencing. 

### 2.2 Modify the manifest R script

See `/r-scripts/create-manifest.R`. Move this Rscript to the location of your raw se
Open this in Rstudio and run it to ensure the R script will work for your file name structure. Always use complete paths when putting in sequences.


Run this R script and modify for your specific sample list. Make sure each part of the `create-manifest.R` script has complete paths. 
```
# Load working R version (for TAMU HPRC)
module load GCC/12.2.0
module load OpenMPI/4.1.4
module load R_tamu/4.3.1

Rscript r-scripts/create-manifest.R
```

Make sure you know the complete path for the location of your manifest file. For example, mine is `/home/skhu/qiime2-2024/manifest`. We will use this in step 4.0 below.


## 3.0 Using QIIME2 with SLURM

There are a lot of great resources on the TAMU HPRC wiki for how to set up your slurm script. See the `template.slurm` and these resources to get started.

### 3.1 Learn a text editor

You need to learn to use a text editor on the command line, like [nano](https://www.nano-editor.org/dist/latest/cheatsheet.html). To edit the template script, navigate to the slurm script directory and type `nano template.slurm`. Use arrow keys to edit the job name, output log file name, specs for the set of commands you want to run, and more.

For example, to run the above R script using slurm, you would edit your slurm script to look like this:
```
#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment

##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=making-manifest     
#SBATCH --time=00:10:00            
#SBATCH --ntasks=1                 
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB               
#SBATCH --output=make-manifest-file.%j   

module load GCC/12.2.0
module load OpenMPI/4.1.4
module load R_tamu/4.3.1

Rscript r-scripts/create-manifest.R
```

To close the text editor, use CTRL+X. Answer "Yes" or "Y" to save your work. Then change the file name to something like: *make-manifest.slurm*. Answer yes to saving it under a new file name.


Then run `sbatch make-manifest.slurm`. 

### 3.2 QIIME2 on SLURM

To run the other steps below, you need to use `module load QIIME2/2023.2` before your QIIME2 commands in your SLURM script. An example is here:

```
#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment

##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=qiime2     
#SBATCH --time=72:00:00            # 72 hours
#SBATCH --ntasks=1                 
#SBATCH --cpus-per-task=32        # 32 threads
#SBATCH --mem=340GB               # lots of memory, but never the maximum (which is 384G)
#SBATCH --output=qiime2-output-log.%j  

# Load qiime2
module load QIIME2/2023.2

# use qiime2 below:

```


### 3.3 Notes on using SLURM

Once a slurm script is written execute the code:
```
sbatch example-code.slurm
```
It should output information on the `Submitted batch job` ID number. You can view the in progress job by executing:

```
# Replace "skhu" with your HPC user name
squeue -u skhu
```

If you need to cancel a job, find the job ID number (use squeue). And write:
```
scancel <JOBID>
```

Once a job is complete, it is a good idea to view how much memory and what % of the CPUs it actually used. This is how we learn how much time, memory, and CPUs to assign to future jobs. 
```
seff <JOBID>
```


## 4.0 Import sequences as QIIME2 artifact files

The rest of the steps are working in QIIME2 and we will use SLURM scripts to submit all the jobs. Each step below reports the QIIME2 specific commands to write below your #SBATCH lines in a slurm script. Keep this in mind.


First import all sequences. The `manifest` file reports the location of each of your files. When working on an HPC, always write files to _your scratch space_. For example, all of the files for this tutorial will be written to my scratch directory located here: `/scratch/user/skhu/amplicon-output`. If the below commands specify *$SCRATCH*, it means you replace this with your scratch directory.

```
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \ # See "importing data" to determine
  --input-path /home/skhu/qiime2-2024/manifest \ # Location of manifest file
  --output-path $SCRATCH/amplicon-output/paired-end-input.qza \ # Location for output qiime2 artifacts
  --input-format PairedEndFastqManifestPhred33V2 #see option for changing to Phred 64 if needed
```

### 4.1 Summarize main files

You can use the `demux summarize` argument to convert any artifact file to a `.qzv` file. This can be drag-dropped to the [QIIME2 viewer](https://view.qiime2.org) webpage to get a visual of your data.


We will include this for each step individually. You will have the option to view these files later. 

```
qiime demux summarize \      
        --i-data $SCRATCH/amplicon-output/paired-end-input.qza \                 
        --o-visualization $SCRATCH/amplicon-output/viz/paired-end-input.qzv
```

To see how I've written each of my slurm scripts for qiime2, see: `qiime2-2024/slurm-scripts/import-seqs.slurm`. Once each of the slurm scripts is running, it will write to an output file that ends with the job id. If errors occur, check this file. This is a good record to keep when things run successfully, as it captures all the outputs. And the job id can give you a lot more information on your run if you execute `seff <jobid>`.

## 5.0 Remove primers

For removing primers, you can use the qiime2 plug-in [cutadapt](https://docs.qiime2.org/2024.5/plugins/available/cutadapt/). For these samples we will use `trim-paired`, because sequences are already demultiplexed. 

```
qiime cutadapt trim-paired \
    --i-demultiplexed-sequences $SCRATCH/amplicon-output/paired-end-input.qza \
        --p-cores $SLURM_CPUS_PER_TASK \
        --p-front-f CCAGCASCYGCGGTAATTCC \
        --p-front-r ACTTTCGTTCTTGATYRA \
        --p-error-rate 0.1 \
        --p-overlap 3 \
    --p-match-adapter-wildcards \
        --o-trimmed-sequences $SCRATCH/amplicon-output/paired-end-input-trimmed.qza

# Grab trim stats from cutadapt
qiime demux summarize \
    --i-data $SCRATCH/amplicon-output/paired-end-input-trimmed.qza \
    --o-visualization $SCRATCH/amplicon-output/paired-end-input-trimmed.qzv
```

## 6.0 Run DADA2

We can also run [DADA2 as a plugin in qiime2](https://docs.qiime2.org/2024.5/plugins/available/dada2/denoise-paired/).

```
qiime dada2 denoise-paired \
        --i-demultiplexed-seqs $SCRATCH/amplicon-output/paired-end-input-trimmed.qza \
        --p-trunc-len-f 260 \
        --p-trunc-len-r 225 \
        --p-max-ee-f 2 \
        --p-max-ee-r 2 \
        --p-min-overlap 10 \
        --p-pooling-method independent \
        --p-n-reads-learn 1000000 \
        --p-n-threads $SLURM_CPUS_PER_TASK \
        --p-chimera-method pooled \
        --o-table $SCRATCH/amplicon-output/paired-end-input-asv-table.qza \
        --o-representative-sequences $SCRATCH/amplicon-output/paired-end-input-asvs-ref-seqs.qza \
        --o-denoising-stats $SCRATCH/amplicon-output/paired-end-input-dada2-stats.qza

qiime tools export \
    --input-path $SCRATCH/amplicon-output/paired-end-input-asv-table.qza \
    --output-path $SCRATCH/amplicon-output/output-tables/

biom convert -i $SCRATCH/amplicon-output/output-tables/feature-table.biom \
    -o $SCRATCH/amplicon-output/output-tables/samples-asv-table.tsv \
    --to-tsv

qiime metadata tabulate \
       --m-input-file $SCRATCH/amplicon-output/paired-end-input-dada2-stats.qza \
       --o-visualization $SCRATCH/amplicon-output/paired-end-input-dada2-stats.qzv

```

*Explanation of output files*

* `samples-asv-table.tsv`: ASV table that is tab-delimited. It should show your samples as columns, ASVs (or *FeatureIDs*) as rows, and numbers will represent the number of sequences assigned to the respective ASV and sample.

* `paired-end-input-asvs-ref-seqs.qza`: Reference sequences for the output ASVs. Use this below to assign taxonomy.

* `paired-end-input-dada2-stats.qzv`: Output visualization of the DADA2 stats. Import this to the QIIME2 viewer to learn more about how your sequences did. 


### 6.1 Run DADA2 with exisiting references

A major advantage of using ASVs is that you can take ASV results from other sequencing runs and compare your new data with this. We can use [*Database Darkly*](https://shu251.github.io/Database-Darkly/) as an example. The [Zenodo](https://zenodo.org/records/11490400) associated with this program includes the ASV reference sequences from all of the deep-sea hydrothermal vent 18S rRNA gene sequencing results. From the Zenodo page, download the reference sequence and the ASV table of the merged data. 



```
cd $SCRATCH/amplicon-output/

# Download the ASV table
wget https://zenodo.org/records/11490400/files/microeuk-merged-asv-table.qza?download=1 

# Download the reference sequences:
wget https://zenodo.org/records/11490400/files/microeuk-merged-ref-seqs.qza?download=1

# Download taxonomy table:
wget https://zenodo.org/records/11490400/files/microeuk-merged-taxa.qza?download=1
```


In this example below, we take the new DADA2 results from here and merge the ASV table and reference sequences. Then we would repeat the taxonomy assignment - OR merge with the taxonomy table we just downloaded. We can add several `--i-tables` arguments to the command to combine more than 2 tables together. 

```
# Merge ASV tables:
qiime feature-table merge \
    --i-tables $SCRATCH/amplicon-output/paired-end-input-asv-table.qza \
    --i-tables $SCRATCH/amplicon-output/microeuk-merged-asv-table.qza \
    --o-merged-table $SCRATCH/amplicon-output/merged-tutorial-asv-table.qza


# Merge reference sequences
qiime feature-table merge-seqs \
    --i-data $SCRATCH/amplicon-output/paired-end-input-asvs-ref-seqs.qza \
    --i-data $SCRATCH/amplicon-output/microeuk-merged-ref-seqs.qza \
    --o-merged-data $SCRATCH/amplicon-output/merged-tutorial-ref-seqs.qza
```


## 7.0 Taxonomy assignment


For this taxonomy assignment, we are taking the reference sequences and comparing them to a reference sequence database.

### 7.1 Reference Sequence Databases

[Protist Ribosomal 2 database](https://app.pr2-database.org/pr2-database/) is the preferred database for microeukaryotes right now. Additionally, the QIIME2 website does recommend doing a pre-taxonomy step where you subset your reference database by _in silico_ grabbing things that hit your primers. In our experience, skipping this is best for whole community diversity with microeukaryotes. See additional information in the supplemental of [this paper](https://doi.org/10.1111/1758-2229.13116). 

We're using [VSEARCH](https://github.com/torognes/vsearch) for this taxonomy assignment and it has a QIIME2 plugin [via the classify-consensus-vsearch option](https://docs.qiime2.org/2024.5/plugins/available/feature-classifier/classify-consensus-vsearch/).


Once you get the reference sequence database of choice, make sure it is unzipped, and then import it as a .qza file:
```
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_SSU_mothur.fasta \
  --output-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_seqs.qza
```

Make sure the taxonomy file has the correct column headers. `['Feature ID', 'Taxon']`

To fix this in R:
```
# Import with no headers
tax <- read.delim("pr2_version_5.0.0_SSU_mothur.tax", header = FALSE)
# Rename headers
colnames(tax) <- c("Feature ID", "Taxon")
# Write as .tsv file
write.table(tax, file = "pr2-tax.tsv", quote = FALSE, col.names = TRUE, sep = "\t", row.names=FALSE)
```

Then import as a QIIME2 artifact file:

```
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-path /scratch/group/hu-lab/PR2/pr2-tax.tsv \
  --output-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_tax.qza

```

### 7.2 Assign taxonomy with VSEARCH

Below, we are using a 90% identity match and ensuring that 75% of the assignments much match the top hit of the reference to be called a consensus assignment. 

```
qiime feature-classifier classify-consensus-vsearch \
    --i-query $SCRATCH/amplicon-output/paired-end-input-asvs-ref-seqs.qza \
    --i-reference-reads /scratch/group/hu-lab/PR2/pr2_version_5.0.0_seqs.qza \
    --i-reference-taxonomy /scratch/group/hu-lab/PR2/pr2_version_5.0.0_tax.qza \
    --output-dir $SCRATCH/amplicon-output/taxonomy-0.9_0.75 \
    --p-threads $SLURM_CPUS_PER_TASK \
    --p-maxaccepts 10 \
    --p-perc-identity 0.90 \
    --p-min-consensus 0.75


# Use the "classification" output
qiime tools export \
    --input-path $SCRATCH/amplicon-output/taxonomy-0.9_0.75/classification.qza \
    --output-path $SCRATCH/amplicon-output/taxonomy-0.9_0.75/classification

# Output gives you a taxonomy table:
## $SCRATCH/amplicon-output/taxonomy-0.9_0.75/classification/taxonomy.tsv
```

## 8.0 Compile output files

We have transferred output files to all be in .tsv files. We will import these in R.


Move files locally or to a central location. For instance, from the output qiime files in scratch, I will move these files to my home directory

```
mv $SCRATCH/amplicon-output/taxonomy-0.9_0.75/classification/taxonomy.tsv /home/skhu/qiime2-2024/q2-output/

mv $SCRATCH/amplicon-output/output-tables/samples-asv-table.tsv /home/skhu/qiime2-2024/q2-output/
```

See Rscript: `r-script/compile-q2-result.R` for recommendations on compiling your data.

### 8.1 Resources for analyzing ASV results

* [decontam](https://github.com/benjjneb/decontam): remove ASVs that might be contaminates. Uses blank samples to determine ASV ID and threshold for determining a contaminate ASV.

* [phyloseq](https://joey711.github.io/phyloseq/): Put ASV results into this package as phyloseq objects and there are lots of options for data wrangling, analyses, and visualizations. 

* [vegan](https://cran.r-project.org/web/packages/vegan/vignettes/intro-vegan.pdf): powerful set of tools inside the vegan package that focus on microbiome statistics.

* [Tools from Willis lab](https://github.com/adw96): look at DivNet, breakaway



### Page information

_last updated S. Hu - July 11, 2024_