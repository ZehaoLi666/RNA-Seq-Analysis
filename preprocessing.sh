#!/bin/bash  -l

#SBATCH --nodes=1
#SBATCH --array=1-32         #depends on how mang files you are going to conduct
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=0-02:15:00 
#SBATCH --mail-user=zli529@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="fastQC"
#SBATCH --output=fastqc/logs/fastqc_%A_%a.out 
#SBATCH --error=fastqc/logs/fastqc_%A_%a.err
#SBATCH -p intel    

# This batch script is an example for running parallel on cluster. I use fastQC and 16 RNA-seq data for example.
module load fastqc
# Define the directory of input data
input_dir=~/lab/cleavage/rna_data

# Add the sample names 
samples=[]

# Use a loop function to look through all files in the input directory and add sample names to `samples` array
for file in "$input_dir"/*; do
       if [ -f "$file" ]; then       # keep space around "$file"
              filename=$(basename "$file")
       else
              echo " $file is not a file "
              # echo "$filename"
              if [ -n "$filename" ]; then
                     samples+=("$filename")
                     # echo $samples
              else 
                     "Empty filename detected for file: $file"
              fi
       fi
done

# Run all samples on parallel
index=$(expr $SLURM_ARRAY_TASK_ID )
sample=${samples[$index]}
echo $sample
fastqc "${input_dir}/${sample}"  -o fastqc/results



