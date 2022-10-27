#!/bin/bash -l
#SBATCH --job-name=BigBRM
#SBATCH --output=BigBRM.o%j
#SBATCH --time=350:00:00
#SBATCH --mem=32G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --mail-type=ALL

module reset
module load R

R --no-save -q < Model_for_large_dataset.R