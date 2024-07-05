#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=import-q2     #Set the job name to "JobExample1"
#SBATCH --time=00:45:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=4	
#SBATCH --mem=1GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=import-q2.%j    #Send stdout/err to "Example1Out.[jobID]"


$SCRATCH=/scratch/user/skhu/amplicon-output/

$SCRATCH


#module load QIIME2/2023.2

#qiime tools import \
#  --type 'SampleData[PairedEndSequencesWithQuality]' \
#  --input-path /home/skhu/qiime2-2024/manifest \
#  --output-path /scratch/user/skhu/amplicon-output/paired-end-input.qza \
#  --input-format PairedEndFastqManifestPhred33V2

#qiime demux summarize \      
#        --i-data /scratch/user/skhu/amplicon-output/paired-end-input.qza \                 
#        --o-visualization /scratch/user/skhu/amplicon-output/viz/paired-end-input.qzv
