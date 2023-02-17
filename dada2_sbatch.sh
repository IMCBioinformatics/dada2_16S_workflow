#!/bin/bash

#SBATCH --partition=synergy,cpu2019,cpu2021
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2-00:00:00
#SBATCH --mem=38G
#SBATCH --error=dada2.%J.err
#SBATCH --output=dada2.%J.out

log_dir="$(pwd)"
log_file="logs/dada2-analysis.log.txt"
num_jobs=100

echo "started at: `date`"

snakemake --rerun-triggers mtime --latency-wait 25 --rerun-incomplete  --cluster-config cluster.json --cluster 'sbatch --partition={cluster.partition} --cpus-per-task={cluster.cpus-per-task} --nodes={cluster.nodes} --ntasks={cluster.ntasks} --time={cluster.time} --mem={cluster.mem} --output={cluster.output} --error={cluster.error}' --jobs $num_jobs --use-conda &> $log_dir/$log_file

output_dir=$(grep "output_dir" < config.yaml | cut -d ' ' -f2 | sed 's/"//g')
list_files=$(grep "sampletable" < config.yaml | cut -d ' ' -f2 | sed 's/"//g')

#Copying all snakemake/log files of the run in the output folder
snakemake_file_dir="${output_dir}/snakemake_files"
mkdir -p $snakemake_file_dir

cp $list_files $snakemake_file_dir
cp Snakefile $snakemake_file_dir
cp config.yaml $snakemake_file_dir
cp cluster.json $snakemake_file_dir
cp dada2_sbatch.sh $snakemake_file_dir 
cp -rf logs $snakemake_file_dir
cp -rf utils $snakemake_file_dir


echo "finished with exit code $? at: `date`"

