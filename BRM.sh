#!/bin/bash -l
#SBATCH --job-name=BRM_Parallelization
#SBATCH --output=BRM.o%j
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mail-type=ALL

module reset
module load R

R --no-save -q < Model_for_small_dataset.R.R