print("Setting up...")
import os
import hashlib
import pandas as pd
import sys

# Get command-line arguments
manifest_file = sys.argv[1]
token_file = sys.argv[2]

# Set your custom download directory here
download_dir = "/gpfs/data/courses/aio2025/yb2612/data/maf"
gdc_dir = "~/yumi/lib/yumi_miniconda/bin/gdc-client"
os.makedirs(download_dir, exist_ok=True)  # Create it if it doesn't exist

verified_checksums = []
invalid_checksums = []

print("Using manifest_file:", manifest_file)
print("Using token_file:", token_file)
print("Downloading to:", download_dir)

def download_gdcdtt(uuid, token_file):
    gdc_path = os.path.expanduser(gdc_dir)
    cmd = f"{gdc_path} download -d {download_dir} -t {token_file} {uuid}"
    print("Running command:", cmd)  # Debug print
    result = os.system(cmd)
    print(f"gdc-client exited with code {result}")

def get_md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def verify_and_download(row):
    uuid = row['id']
    md5 = row['md5']
    filename = row['filename']
    target_path = os.path.join(download_dir, filename)

    # Check if the file exists
    # print("Checking if file exists...")
    if os.path.exists(target_path):
        # Verify the MD5 checksum
        if get_md5(target_path) == md5:
            # print(f"File {filename} already exists and is verified.")
            verified_checksums.append(filename)
            return
        else:
            print(f"File {filename} exists but MD5 does not match. Deleting...")
            invalid_checksums.append(filename)
            os.remove(target_path)
    else:
        print("File does not exist yet.")

    # Download the file
    print(f"Downloading {filename}...")
    download_gdcdtt(uuid, token_file)

    # Move files from the UUID folder to the main download directory
    uuid_folder = os.path.join(download_dir, uuid)
    if os.path.exists(uuid_folder) and os.path.isdir(uuid_folder):
        print(f"Found UUID folder: {uuid_folder}")
        for file in os.listdir(uuid_folder):
            file_path = os.path.join(uuid_folder, file)
            dest_path = os.path.join(download_dir, file)
            if os.path.isfile(file_path):
                print(f"Moving {file_path} to {dest_path}")
                os.rename(file_path, dest_path)
            else:
                print(f"Skipping non-file: {file_path}")
        
        remaining = os.listdir(uuid_folder)
        if remaining:
            print(f"UUID folder not empty after moving files: {remaining}")
        else:
            os.rmdir(uuid_folder)
            print(f"Removed empty folder: {uuid_folder}")

    # Verify the MD5 checksum again after download
    print("Verifying MD5 checksum...")
    if os.path.exists(target_path) and get_md5(target_path) == md5:
        print(f"Downloaded {filename} and verified successfully.")
        verified_checksums.append(filename)
    else:
        print(f"Downloaded {filename} but MD5 does not match. Please check the download.")
        invalid_checksums.append(filename)
        
# Read the manifest file
manifest_df = pd.read_csv(manifest_file, sep="\t", header=0)
print("First 5 entries in manifest:")
print(manifest_df.head(5))

# Check if the required columns are present
required_columns = ['id', 'md5', 'filename']
if not all(col in manifest_df.columns for col in required_columns):
    raise ValueError(f"Manifest file must contain the following columns: {', '.join(required_columns)}")

print("Starting download...")

# download every row in manifest
for index, row in manifest_df.iterrows():
    verify_and_download(row)

print("Finished!")

print("\nVerified checksums:")
if verified_checksums:
    for f in verified_checksums:
        print(f"- {f}")
else:
    print("No files verified successfully.")

print("\nInvalid checksums:")
if invalid_checksums:
    for f in invalid_checksums:
        print(f"- {f}")
else:
    print("No files had checksum issues.")
