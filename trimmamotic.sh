#!/bin/bash  -l

#SBATCH --nodes=1
#SBATCH --array=1-16
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=0-05:15:00
#SBATCH --mail-user=zli529@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="trim"
#SBATCH --output=logs/trim_%A_%a.out
#SBATCH --error=logs/trim_%A_%a.err
#SBATCH -p intel

# This batch script is an example for running parallel on cluster. I use trimmomatic and 16 paired RNA-seq data for example.

# Define the directory of input and output data
input_dir=~/lab/cleavage/rna_data
output_paired_dir=~/lab/cleavage/preprocessing/trim/results/paired
output_unpaired_dir=~/lab/cleavage/preprocessing/trim/results/unpaired

# creat the input and output names
samples_R1=[]
samples_R2=[]
output_paired_R1=[]
output_paired_R2=[]
output_unpaired_R1=[]
output_unpaired_R2=[]

# Use a loop function to look through all files in the input directory and add sample names to `samples` array
# add R1 samples
for file in "$input_dir"/*R1*.fastq.gz; do

        filename_R1=$(basename "$file")
        # echo "$filename"
        if [ -n "$filename_R1" ]; then
            samples_R1+=("$filename_R1")
            echo "complete creat input R1 $filename_R1"
            output_paired_R1+=("paired_$filename_R1")
            echo "complete creat output paired R1 $filename_R1"
            output_unpaired_R1+=("unpaired_$filename_R1")
            echo "complete creat output unpaired R1 $filename_R1"

        fi
done

# add R2 samples
for file in "$input_dir"/*R2*.fastq.gz; do
    filename_R2=$(basename "$file")
    if [ -n "$filename_R2" ]; then
        samples_R2+=("$filename_R2")
        echo "complete creat input R2 $filename_R2"
        output_paired_R2+=("paired_$filename_R2")
        echo "complete creat output paired R2 $filename_R2"
        output_unpaired_R2+=("unpaired_$filename_R2")
        echo "complete creat output unpaired R2 $filename_R2"
    fi
done

# Run all samples on parallel
#index=$(expr $SLURM_ARRAY_TASK_ID -1)
index=$(expr $SLURM_ARRAY_TASK_ID)
echo "the index number is $index"
input_R1=${samples_R1[$index]}
input_R2=${samples_R2[$index]}
out_paired_R1=${output_paired_R1[$index]}
out_paired_R2=${output_paired_R2[$index]}
out_unpaired_R1=${output_unpaired_R1[$index]}
out_unpaired_R2=${output_unpaired_R2[$index]}

echo "start running the trimmomatic package"
# remember to add TruSeq3-PE.fa to the current pathway
java -jar /opt/linux/rocky/8.x/x86_64/pkgs/trimmomatic/0.39/trimmomatic.jar PE "$input_dir/$input_R1" "$input_dir/$input_R2" "$output_paired_dir/$out_paired_R1" "$output_paired_dir/$out_paired_R2" "$output_unpaired_dir/$out_unpaired_R1" "$output_unpaired_dir/$out_unpaired_R2" ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
echo "complete trim $input_R1 and $input_R2."

