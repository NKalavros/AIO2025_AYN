
cd /gpfs/data/courses/aio2025/yb2612/data/outputs/extracted_vcfs
grep -P "\tN\t" *

mamba install -c conda-forge bcftools


cd /gpfs/data/courses/aio2025/yb2612/data/vcf
# Process all .vcf.gz files in the current directory
for file in *.vcf.gz; do
  # Define output name, e.g., originalname_N_alleles.vcf
  output_file="${file%.vcf.gz}_N_alleles.vcf"

  echo "Processing $file -> $output_file"

  # Run bcftools
  bcftools view -i 'REF~"N" || ALT~"N"' "$file" -o "$output_file"

  # Optional: Check if the output file is empty (except header) and remove if so
  # (Requires checking lines that don't start with '#')
  if [ $(bcftools view "$output_file" | grep -cv '^#') -eq 0 ]; then
     echo "  No 'N' alleles found in $file. Removing empty output."
     rm "$output_file"
  fi
done

echo "Finished processing all files."

ls *vcf