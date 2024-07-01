# QIIME2 - 2024 protocol


## 1.0 Set up working area

### 1.1 QIIME2 with Anaconda environment

Create a conda environment to install QIIME2. Only make conda environments in your personal scratch directory. To do this on the TAMU HPRC, follow the below instructions.

```
cd $SCRATCH                                     # Make scratch your current directory
module load Anaconda3/2024.02-1                 # Load Anaconda module (you can use the latest version)
conda config --set auto_activate_base False     # run once to disable auto Anaconda loading
```

You only need to do the above once.

#### Install QIIME2

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

### 6.1 Run DADA2 with exisiting references


## 7.0 Taxonomy assignment


### 7.1 Reference Sequence Databases

[Protist Ribosomal 2 database](https://app.pr2-database.org/pr2-database/) is the preferred database for microeukaryotes right now. 

```
qiime feature-classifier classify-consensus-vsearch \
    --i-query $SCRATCH/paired-end-input-asvs-ref-seqs.qza \
    --i-reference-reads /vortexfs1/omics/huber/db/pr2-db/pr2_version_4.14_seqs.qza \
    --i-reference-taxonomy /vortexfs1/omics/huber/db/pr2-db/pr2_version_4.14_tax.qza \
    --o-classification /vortexfs1/scratch/sarahhu/mcr-samples-taxa.qza \
    --p-threads 8 \
    --p-maxaccepts 10 \
    --p-perc-identity 0.8 \
    --p-min-consensus 0.70


qiime tools export \
    --input-path /vortexfs1/scratch/sarahhu/mcr-samples-taxa.qza \
    --output-path /vortexfs1/scratch/sarahhu/mcr-samples-output/
```


## 8.0 Compile output files
