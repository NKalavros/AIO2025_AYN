import os
import hashlib
import pandas as pd
import sys

manifest_file = sys.argv[1]
token_file = sys.argv[2]


def get_md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def download_gdcdtt(uuid, token_file):
    # Placeholder function for downloading from GDC DTT
    os.system(f"gdc-client download -t {token_file} {uuid}")

def verify_and_download(row):
    uuid = row['id']
    md5 = row['md5']
    filename = row['filename']

    # Check if the file exists
    if os.path.exists(filename):
        # Verify the MD5 checksum
        if get_md5(filename) == md5:
            print(f"File {filename} already exists and is verified.")
            return
        else:
            print(f"File {filename} exists but MD5 does not match. Deleting...")
            os.remove(filename)

    # Download the file
    print(f"Downloading {filename}...")
    download_gdcdtt(uuid, token_file)
    # The file is downloaded within a subfolder based on the UUID. Move every file under the UUID folder out of it
    uuid_folder = os.path.join(os.getcwd(), uuid)
    if os.path.exists(uuid_folder) and os.path.isdir(uuid_folder):
        for file in os.listdir(uuid_folder):
            file_path = os.path.join(uuid_folder, file)
            if os.path.isfile(file_path):
                os.rename(file_path, os.path.join(os.getcwd(), file))
        os.rmdir(uuid_folder)
    
    # Verify the MD5 checksum again after download
    if get_md5(filename) == md5:
        print(f"Downloaded {filename} and verified successfully.")
    else:
        print(f"Downloaded {filename} but MD5 does not match. Please check the download.")


# Read the manifest file
manifest_df = pd.read_csv(manifest_file, sep="\t", header=0)

# Check if the required columns are present
required_columns = ['id', 'md5', 'filename']
if not all(col in manifest_df.columns for col in required_columns):
    raise ValueError(f"Manifest file must contain the following columns: {', '.join(required_columns)}")

# Iterate over each row in the manifest file
for index, row in manifest_df.iterrows():
    verify_and_download(row)
