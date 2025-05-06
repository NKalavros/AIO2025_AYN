library(SigMA)
library(data.table)
data_dir <- "/gpfs/data/courses/aio2025/yb2612/data/maf"

files_use <- list.files(path = data_dir, full.names = TRUE, pattern = "gz$")

for (i in seq(1, length(files_use))) {
    new.file <- gsub(".gz", "", files_use[i])
    command <- paste("gunzip -c", files_use[i], ">", new.file)
    print(command)
    system(command) # being very explicit
}

output_dir <- "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
dir.create(output_dir)
output_dir <- "/gpfs/data/courses/aio2025/yb2612/data/outputs/extracted_mafs"
dir.create(output_dir)
system(paste0("mv ", data_dir, "/*.maf ", "/gpfs/data/courses/aio2025/yb2612/data/outputs/extracted_mafs"))

genomes_matrix <- make_matrix(output_dir, file_type = "maf", ref_genome_name = "hg38")


output_dir <- "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
dir.create(output_dir)
genome_file <- "hereyougoyumi.csv"

genome_file <- paste0(output_dir, genome_file)

write.table(genomes_matrix,
    genome_file,
    sep = ",",
    row.names = T,
    col.names = T,
    quote = F
)

# Load the manifest
sample_manifest <- fread("/gpfs/data/courses/aio2025/yb2612/data/maf/gdc_sample_sheet.2025-04-17.tsv", data.table = F)
sample.names <- unlist(lapply(strsplit(sample_manifest[["Case ID"]], ","), function(x) x[1]))
length(unique(sample.names))
sample.names <- make.unique(sample.names)

colnames(genomes_matrix) <- sample.names


output_dir <- "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
dir.create(output_dir)
genome_file <- "hereyougoyumi2.csv"

genome_file <- paste0(output_dir, genome_file)

write.table(genomes_matrix,
    genome_file,
    sep = ",",
    row.names = T,
    col.names = T,
    quote = F
)

rownames(genomes_matrix)


genomes_matrix <- read.csv("/gpfs/data/courses/aio2025/yb2612/data/outputs/hereyougoyumi2.csv", row.names = 1)
sample_manifest <- fread("/gpfs/data/courses/aio2025/yb2612/data/maf/gdc_sample_sheet.2025-04-17.tsv", data.table = F)

print(table(sample_manifest[["Project ID"]]))
# TCGA-BRCA TCGA-CESC   TCGA-OV TCGA-UCEC

tumors <- c(
    "TCGA-CESC",
    "TCGA-BRCA",
    "TCGA-OV",
    "TCGA-UCEC"
)
res.all <- list()
for (i in tumors) {
    print(i)
    genomes_matrix.project <- genomes_matrix[, sample_manifest[["Project ID"]] == i]
    print(dim(genomes_matrix.project))
    output_dir <- "/gpfs/data/courses/aio2025/yb2612/data/outputs/"
    dir.create(output_dir)
    project_dir <- paste0("/gpfs/data/courses/aio2025/yb2612/data/outputs/", i, "_sigma/")
    dir.create(project_dir)
    write.table(genomes_matrix.project,
        paste0(project_dir, i, ".csv"),
        sep = ",",
        row.names = T,
        col.names = T,
        quote = F
    )
    if (i == "TCGA-BRCA") {
        tumor_type <- "breast"
    } else if (i == "TCGA-CESC") {
        tumor_type <- "cervix"
    } else if (i == "TCGA-OV") {
        tumor_type <- "ovary"
    } else if (i == "TCGA-UCEC") {
        tumor_type <- "uterus"
    }
    res <- run(paste0(project_dir, i, ".csv"),
        output_file = paste0(project_dir, i, ".res"),
        tumor_type = tumor_type,
        do_assign = T,
        do_mva = T,
        catalog_name = "cosmic_v3p2_inhouse",
        data = c("tcga_mc3"),
        check_msi = TRUE,
        add_sig3 = TRUE
    )
    saveRDS(res, file = paste0(project_dir, i, ".rds"))
    res.all[[i]] <- res
}


# Get all directories
library(data.table)
library(SigMA)
project_dir <- paste0("/gpfs/data/courses/aio2025/yb2612/data/outputs/")
# Get res files in here recursively by subsetting .res suffixes
res_files <- list.files(project_dir, pattern = "\\.res$", full.names = TRUE, recursive = TRUE)
# Load them with fread
res_data <- lapply(res_files, function(x) {
    res <- fread(x, data.table = F)
    return(res)
})
names(res_data) <- unlist(lapply(res_files, function(x) gsub(".res", "", basename(x))))


df <- res_data[[tumors]]


df <- llh_max_characteristics(df, "cervix", "cosmic_v3p2_inhouse")
df_exps_clusters <- get_sig_exps(df = df, col_exps = "cluster_exps_all", col_sigs = "cluster_sigs_all")
colnames(df_exps_clusters) <- paste0("clust_", colnames(df_exps_clusters))
df <- cbind(df, df_exps_clusters)
df$tumor <- "cervix"
lite <- lite_df(df)
df_exps <- get_sig_exps(df = lite, col_exps = "sigs_all", col_sigs = "exps_all")

lite$Signature_3_l_rat
lite$Signature_3_mva
lite$pass_mva_strict
lite$sigs_all
