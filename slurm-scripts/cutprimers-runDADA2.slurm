#!/bin/bash
##ENVIRONMENT SETTINGS; CHANGE WITH CAUTION
#SBATCH --export=NONE        #Do not propagate environment
#SBATCH --get-user-env=L     #Replicate login environment
  
##NECESSARY JOB SPECIFICATIONS
#SBATCH --job-name=cut-dada2     #Set the job name to "JobExample1"
#SBATCH --time=20:00:00            #Set the wall clock limit to 1hr and 30min
#SBATCH --ntasks=1                 #Request 1 task
#SBATCH --cpus-per-task=32	
#SBATCH --mem=250GB                #Request 2560MB (2.5GB) per node
#SBATCH --output=cut_dada2-q2.%j    #Send stdout/err to "Example1Out.[jobID]"


module load QIIME2/2023.2

echo "Use cutadapt to remove primer sequences"

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


echo "Starting DADA2 denoising, error prediction, chimera removal, and ASV determination..."

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



echo "DADA2 complete"


qiime tools export \
    --input-path $SCRATCH/amplicon-output/paired-end-input-asv-table.qza \
    --output-path $SCRATCH/amplicon-output/output-tables/

biom convert -i $SCRATCH/amplicon-output/output-tables/feature-table.biom \
    -o $SCRATCH/amplicon-output/output-tables/samples-asv-table.tsv \
    --to-tsv

qiime metadata tabulate \
       --m-input-file $SCRATCH/amplicon-output/paired-end-input-dada2-stats.qza \
       --o-visualization $SCRATCH/amplicon-output/paired-end-input-dada2-stats.qzv


echo "Done re-formatting files"
