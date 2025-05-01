library(SigMA)

data_dir <- "/gpfs/data/courses/aio2025/yb2612/data/vcf"

files_use <- list.files(path = data_dir, full.names = TRUE, pattern = "gz$")

for (i in seq(1, length(files_use))) {
    new.file <- gsub(".gz", "", files_use[i])
    command <- paste("gunzip -c", files_use[i], ">", new.file)
    print(command)
    system(command) # being very explicit
}

output_dir = "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
dir.create(output_dir)
output_dir = "/gpfs/data/courses/aio2025/yb2612/data/outputs/extracted_vcfs"
dir.create(output_dir)
system(paste0("mv ", data_dir, "/*.vcf ", "/gpfs/data/courses/aio2025/yb2612/data/outputs/extracted_vcfs"))

genomes_matrix <- make_matrix(output_dir, file_type = "vcf", ref_genome_name = "hg38")


output_dir = "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
dir.create(output_dir)
genome_file <- "hereyougoyumi.csv"

genome_file <- paste0(output_dir, genome_file)

write.table(genomes,
    genome_file,
    sep = ",",
    row.names = F,
    col.names = T,
    quote = F
)
