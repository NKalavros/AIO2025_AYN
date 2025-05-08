#!/bin/bash
#SBATCH --job-name=aio_sigprofiler_assigner_brca_sbs # Job name
#SBATCH --mail-type=END,FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=adam.walker@nyulangone.org # Where to send mail
#SBATCH --ntasks=1 # typically 1
#SBATCH --cpus-per-task=5 #number of threads
#SBATCH --mem=32gb # Job memory request
#SBATCH --time=12:00:00 # Time limit hrs:min:sec
#SBATCH --output=/gpfs/data/courses/aio2025/adw9882/Analysis/output/logs/aio_sigprofiler_assigner_brca_sbs_%A_%a.log # Standard output and error log
#SBATCH -p cpu_short #can be whatever size you feel you need

## input data
FILELOCATION="/gpfs/data/courses/aio2025/adw9882/Data"
OUTPUTFILELOCATION="/gpfs/data/courses/aio2025/adw9882/Analysis/output"

#Source Conda initialization script

source /gpfs/data/courses/aio2025/adw9882/aio_analysis/etc/profile.d/conda.sh

#Initialize conda

eval "$(conda shell.bash hook)"

#Activate your specific environment

conda activate aio_py

## Append proper name to make sure that you're using the right file
BRCAFILE="${FILELOCATION}/brca_converted.txt"

## output location and make a folder if it doesn't exist
BRCAOUTLOC="${OUTPUTFILELOCATION}/SBS_SigAssigner_output_brca"

mkdir -p ${BRCAOUTLOC}

## SigAssigner for Cosmic

SigProfilerAssignment cosmic_fit \
    ${BRCAFILE} \
    ${BRCAOUTLOC} \
    --context_type "SBS" \
    --collapse_to_SBS96 "True" \
    --verbose "True"
    
#Optionally deactivate when done

conda deactivate

# Print completion message
#echo "SigProfiler assignment completed for project: ${INPUTFILE}"