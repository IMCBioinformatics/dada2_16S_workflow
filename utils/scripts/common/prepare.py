import os
import gzip
import subprocess

def count_reads(file_path):
    """Count the number of reads in a FASTQ file."""
    with gzip.open(file_path, 'rt') as f:
        return sum(1 for line in f) // 4

def main(path):
    if not os.path.exists('samples'):
        os.makedirs('samples')

    read_files = []

    for file in os.listdir(path):
        if file.endswith('.fastq.gz'):
            file_path = os.path.join(path, file)
            reads = count_reads(file_path)
            if reads > 0:
                read_files.append(file_path)
#                print(f"Passed files in terms of number of reads are {file_path}")
            else:
                print(f"No reads in {file_path}")


    # Extracting unique sample IDs
    unique_sample_ids = set()
    for file in read_files:
        base_name = os.path.basename(file)
        sample_id = base_name.split('_R')[0]
        unique_sample_ids.add(sample_id)

    # Separating files into R1 and R2
    R1_files = [file for file in read_files if '_R1_' in file]
    R2_files = [file for file in read_files if '_R2_' in file]

    # Creating the final tab-delimited file
    with open('samples/samples.tsv', 'w') as output_file:
        output_file.write("Sample_ID\tR1\tR2\n")
        for id in unique_sample_ids:
            R1_file = next((file for file in R1_files if id in file), None)
            R2_file = next((file for file in R2_files if id in file), None)
            output_file.write(f"{id}\t{R1_file}\t{R2_file}\n")

if __name__ == "__main__":
    import sys
    main(sys.argv[1])
