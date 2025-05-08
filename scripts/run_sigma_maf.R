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
    res$tumor <- gsub(".res", "", basename(x))
    return(res)
})
names(res_data) <- unlist(lapply(res_files, function(x) gsub(".res", "", basename(x))))
res.all.lite <- lapply(res_data, lite_df)

res.all.lite <- lapply(res.all.lite, function(df) {
    y <- df
    df_exps <- get_sig_exps(df = df, col_exps = "sigs_all", col_sigs = "exps_all")
    y <- cbind(y, df_exps)
    return(y)
})


for (i in seq(1, length(res.all.lite))) {
    write.csv(res.all.lite[[i]], file = paste0("/gpfs/data/courses/aio2025/yb2612/data/outputs/SigMA", names(res.all.lite)[i], ".csv"), row.names = F)
    print(paste0("Saved ", names(res.all.lite)[i], ".csv"))
}

res.all.lite.cluster <- lapply(res.all.lite, function(df) {
    y <- df
    df_exps_clusters <- get_sig_exps(df = df, col_exps = "cluster_exps_all", col_sigs = "cluster_sigs_all")
    colnames(df_exps_clusters) <- paste0("clust_", colnames(df_exps_clusters))
    y <- cbind(df, df_exps_clusters)
    return(y)
})



combine_signature_data <- function(signature_vectors, value_vectors, sample_names = NULL) {
    # Check if inputs are valid
    if (length(signature_vectors) != length(value_vectors)) {
        stop("The number of signature vectors must match the number of value vectors")
    }

    n_samples <- length(signature_vectors)

    # If sample names aren't provided, create default names
    if (is.null(sample_names)) {
        sample_names <- paste0("Column_", 1:n_samples)
    }

    # Get all unique signatures across all vectors
    all_signatures <- unique(unlist(signature_vectors))

    # Create an empty dataframe with rows for each unique signature
    result_df <- data.frame(
        Signature = all_signatures,
        stringsAsFactors = FALSE
    )

    # For each sample, add its values to the dataframe
    for (i in 1:n_samples) {
        signatures <- signature_vectors[[i]]
        values <- value_vectors[[i]]

        # Convert values to numeric if they're character strings
        values <- as.numeric(values)

        # Create a temporary dataframe for this sample
        temp_df <- data.frame(
            Signature = signatures,
            Value = values,
            stringsAsFactors = FALSE
        )

        # Rename the Value column to the sample name
        colnames(temp_df)[2] <- sample_names[i]

        # Merge with the result dataframe
        result_df <- merge(result_df, temp_df, by = "Signature", all = TRUE)
    }

    # Set row names to signatures and optionally remove the Signature column
    # (commented out in case you want to keep it as a column)
    # rownames(result_df) <- result_df$Signature
    # result_df$Signature <- NULL

    return(result_df)
}

res.all.lite.splitsigs <- lapply(res.all.lite, function(df) {
    sig.names <- strsplit(df$sigs_all, ".", fixed = T)
    sig.exps <- strsplit(df$exps_all, "_", fixed = T)
    df_all <- combine_signature_data(sig.names, sig.exps)
    rownames(df_all) <- df_all$Signature
    df_all$Signature <- NULL
    df_all <- t(df_all)
    # Grab the columns starting exp_ in it from df
    df.extra <- df[, grepl("exp_", colnames(df))]
    # Rbind it to what we have
    df_all <- cbind(df_all, df.extra)
})

# Convert to actual names
res.all.lite.splitsigs <- lapply(res.all.lite.splitsigs, function(df) {
    y <- df
    rownames(y) <- rownames(genomes_matrix)
    return(y)
})
# Convert to trinucleotide format
res.all.lite.splitsigs <- lapply(res.all.lite.splitsigs, function(df) {
    y <- df
    from <- rownames(y)
    return(y)
})

# Convert 4-letter context (like "caaa") to trinucleotide format (like "A[C>A]A")
to_trinuc <- function(row_label) {
    base_map <- c("a" = "A", "c" = "C", "g" = "G", "t" = "T")
    ref <- base_map[substr(row_label, 1, 1)]
    alt <- base_map[substr(row_label, 2, 2)]
    flanking_left <- base_map[substr(row_label, 3, 3)]
    flanking_right <- base_map[substr(row_label, 4, 4)]
    return(paste0(flanking_left, "[", ref, ">", alt, "]", flanking_right))
}

# Apply the conversion to row names in each data frame
res.all.lite.splitsigs <- lapply(res.all.lite.splitsigs, function(df) {
    y <- df
    rownames(y) <- sapply(rownames(y), to_trinuc)
    return(y)
})


for (i in seq(1, length(res.all.lite.splitsigs))) {
    write.csv(res.all.lite[[i]], file = paste0("/gpfs/data/courses/aio2025/yb2612/data/outputs/250506_UseThis_SigMA", names(res.all.lite)[i], ".csv"), row.names = T)
    print(paste0("Saved ", names(res.all.lite)[i], ".csv"))
}
