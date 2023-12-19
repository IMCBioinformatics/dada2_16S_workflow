
import os
import gzip
import multiprocessing
import sys

def count_reads(file_path):
    """Check if a FASTQ file contains any reads."""
    with gzip.open(file_path, 'rt') as f:
        try:
            next(f)
            return True
        except StopIteration:
            return False

def process_file(file_path):
    """Process a single file to determine if it has reads."""
    if file_path.endswith('.fastq.gz'):
        if count_reads(file_path):
            return file_path
        else:
            print(f"No reads in {file_path}")
            return None

def main(path):
    if not os.path.exists('samples'):
        os.makedirs('samples')

    # Parallel processing of files
    pool = multiprocessing.Pool()
    files = [os.path.join(path, file) for file in os.listdir(path)]
    read_files = [file for file in pool.map(process_file, files) if file]

    # Rest of the processing...
    # Extract unique sample IDs, separate files into R1 and R2, etc.

if __name__ == "__main__":
    main(sys.argv[1])
