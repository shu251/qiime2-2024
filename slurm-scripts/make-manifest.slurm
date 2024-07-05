#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=making-manifest     #Set the job name to "JobExample1"
#SBATCH --time=00:10:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=1	
#SBATCH --mem=1GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=make-manifest-file.%j    #Send stdout/err to "Example1Out.[jobID]"

## For GRACE on the TAMU HPRC, there is a max of 48 cores (--cpus-per-task)
# Each core on grace has 384 GB nodes, there are 800 nodes available
# If command below requires you to specify threads use this: --threads $SLURM_CPUS_PER_TASK

### Place all code below:

module load GCC/12.2.0
module load OpenMPI/4.1.4
module load R_tamu/4.3.1

Rscript r-scripts/create-manifest.R
