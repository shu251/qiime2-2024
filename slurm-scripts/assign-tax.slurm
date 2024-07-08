#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=assign-tax     #Set the job name to "JobExample1"
#SBATCH --time=00:10:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=32	
#SBATCH --mem=250GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=assign-taxonomy-q2.%j    #Send stdout/err to "Example1Out.[jobID]"


module load QIIME2/2023.2


qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_SSU_mothur.fasta \
  --output-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_seqs.qza


qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_SSU_mothur.tax.gz \
  --output-path /scratch/group/hu-lab/PR2/pr2_version_5.0.0_tax.qza

echo "Assign taxonomy"

qiime feature-classifier classify-consensus-vsearch \
    --i-query $SCRATCH/amplicon-output/paired-end-input-asvs-ref-seqs.qza \
    --i-reference-reads /scratch/group/hu-lab/PR2/pr2_version_5.0.0_seqs.qza \
    --i-reference-taxonomy /scratch/group/hu-lab/PR2/pr2_version_5.0.0_tax.qza \
    --output-dir $SCRATCH/amplicon-output/taxonomy-0.9_0.75 \
    --p-threads $SLURM_CPUS_PER_TASK \
    --p-maxaccepts 10 \
    --p-perc-identity 0.90 \
    --p-min-consensus 0.75


echo "Completed taxonomy assignment. Reformatting output."

qiime tools export \
    --input-path $SCRATCH/amplicon-output/paired-end-tutorial-taxa.qza \
    --output-path $SCRATCH/amplicon-output/tax-output/

echo "Done re-formatting files"
