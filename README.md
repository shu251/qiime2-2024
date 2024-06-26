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

## 3.0 Import sequences as QIIME2 artifact files

The rest of the steps are working in QIIME2 and we will use SLURM scripts to submit all the jobs. Each step is separated by a SLURM script below so we can view each of the outputs.

```
module load QIIME2/2023.2

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \ # See "importing data" to determine
  --input-path pe-64-manifest \ # Location of manifest file
  --output-path paired-end-demux.qza \ # Location for output qiime2 artifacts
  --input-format PairedEndFastqManifestPhred33V2 #see option for changing to Phred 64 if needed
```



