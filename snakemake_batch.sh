#!/bin/bash

#SBATCH --partition=cpu2019,synergy,bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=7-00:00:00
#SBATCH --mem=38G
#SBATCH --error=Dada2Snakemake_run.%J.err
#SBATCH --output=Dada2Snakemake_run.%J.out

log_dir="$(pwd)"
log_file="logs/dada2snakemake.log.txt"

# The number of jobs for the snakemake command.
num_jobs=60

# The number of seconds to wait before checking if the output file of a snakemake rule is created.
latency_wait=30

# The number of times to restart a job if it fails.
restart_times=10

# The maximum inventory time.
max_inventory_time=20

echo "started at: `date`"

# Load the ~/.bashrc file as source.
source ~/.bashrc

# Activate the snakemake conda environment.
conda activate snakemake

snakemake --cluster-config cluster.json --cluster 'sbatch --partition={cluster.partition} --cpus-per-task={cluster.cpus-per-task} --nodes={cluster.nodes} --ntasks={cluster.ntasks} --time={cluster.time} --mem={cluster.mem} --output={cluster.output} --error={cluster.error}' --jobs $num_jobs --latency-wait $latency_wait --restart-times $restart_times --rerun-incomplete --max-inventory-time $max_inventory_time --use-conda &> $log_dir/$log_file

echo "finished with exit code $? at: `date`"
