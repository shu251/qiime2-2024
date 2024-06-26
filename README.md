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
  --output-path $SCRATCH/paired-end-input.qza \ # Location for output qiime2 artifacts
  --input-format PairedEndFastqManifestPhred33V2 #see option for changing to Phred 64 if needed
```

### 4.1 Summarize main files

You can use the `demux summarize` argument to convert any artifact file to a `.qzv` file. This can be drag-dropped to the [QIIME2 viewer](https://view.qiime2.org) webpage to get a visual of your data.

```
qiime demux summarize \      
        --i-data $SCRATCH/paired-end-input.qza \                 
        --o-visualization $SCRATCH/viz/paired-end-input.qzv
```

## 5.0 Remove primers


## 6.0 Run DADA2

### 6.1 Run DADA2 with exisiting references

## 7.0 Convert files

## 8.0 Taxonomy assignment

