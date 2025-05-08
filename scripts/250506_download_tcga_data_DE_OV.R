covar.use <- NULL
var.use <- "Status"
thres <- threshold <- 5
study_name <- "OV"

# Add option for setenv broom size to enlarge it
Sys.setenv("VROOM_CONNECTION_SIZE" = 2**20)
options(timeout = 3600)
library(UCSCXenaTools)
library(DESeq2)
library(dplyr)

# Grab the query from Xena and download
df_todo <- XenaGenerate(subset = XenaCohorts == "TCGA TARGET GTEx") %>% XenaFilter(filterDatasets = "TcgaTargetGtex_gene_expected_count")
XenaQuery(df_todo) %>%
    XenaDownload("/gpfs/scratch/nk4167/xena_cache") -> xe_download
# Load it in, make genenames correct
cli <- XenaPrepare(xe_download)
cli <- as.data.frame(cli)
temp.rownames <- unlist(cli[, 1])
cli <- cli[, 2:ncol(cli)]
rownames(cli) <- temp.rownames
# Grab metadata
df_todo <- XenaGenerate(subset = XenaCohorts == "TCGA TARGET GTEx") %>% XenaFilter(filterDatasets = "phenotype")
XenaQuery(df_todo) %>%
    XenaDownload(destdir = "/gpfs/scratch/nk4167/xena_cache") -> xe_download
# Load it in
pdata <- XenaPrepare(xe_download)
pdata <- as.data.frame(pdata)
# Subset to pancreas
print(table(pdata[["_primary_site"]], pdata[["_study"]]))
pancreas_samples <- unlist(pdata[["_primary_site"]]) == "Ovary"
pdata <- pdata[pancreas_samples, ]
common.samples <- intersect(pdata$sample, colnames(cli))
pdata <- pdata[pdata$sample %in% common.samples, ]
cli <- cli[, common.samples]
# Subset between tissues
pdata$Status <- unlist(pdata[["_sample_type"]])
pdata$Status[grepl("Tissue", unlist(pdata[["_sample_type"]]))] <- "Normal"
# Remove metastatics
# cli = cli[,pdata$Status != "Metastatic"]
# pdata = pdata[pdata$Status != "Metastatic",]
# Annoate genes from ensembl to hugo
counts <- cli
library(org.Hs.eg.db)
species <- "human"
my.org <- org.Hs.eg.db
annot.genes <- bitr(substr(rownames(counts), 1, 15), fromType = "ENSEMBL", toType = c("SYMBOL", "GENENAME"), OrgDb = org.Hs.eg.db, drop = F)

annot.genes <- annot.genes[!duplicated(annot.genes$ENSEMBL, fromLast = T), ]
# Remove unneeded genes, remove duplicated genes, recreate rownames
keep.genes <- !is.na(annot.genes$SYMBOL)
counts <- counts[keep.genes, ]
annot.genes <- annot.genes[keep.genes, ]
keep.genes2 <- !duplicated(annot.genes$SYMBOL, fromLast = T)
counts <- counts[keep.genes2, ]
annot.genes <- annot.genes[keep.genes2, ]
rownames(counts) <- annot.genes$SYMBOL[match(substr(rownames(counts), 1, 15), annot.genes$ENSEMBL)]
# Fix for DESeq2
rownames(pdata) <- pdata$sample
counts <- round(counts, 0)
saveRDS(counts, paste0("/gpfs/data/courses/aio2025/yb2612/data/TCGAGTEx_", study_name, "_counts.RDS"))
saveRDS(pdata, paste0("/gpfs/data/courses/aio2025/yb2612/data/TCGAGTEx_", study_name, "_pdata.RDS"))

pdata[["Study"]] <- unlist(pdata[, "_study"])

print(table(pdata[["Study"]], pdata[["Status"]]))

# Fix names for R
pdata$Status <- make.names(pdata$Status)
cond1 <- "Normal"
cond2 <- "Primary.Tumor"
#### Independent filtering ####
temp.human <- counts
temp.metadata <- pdata
rownames(temp.metadata) <- temp.metadata$sample
thres <- threshold
# Generate DESeq2 object
if (is.null(covar.use)) {
    dds_obj <- DESeqDataSetFromMatrix(temp.human,
        colData = temp.metadata,
        design = as.formula(paste("~ 0", var.use, sep = "+"))
    )
} else {
    dds_obj <- DESeqDataSetFromMatrix(temp.human,
        colData = temp.metadata,
        design = as.formula(paste("~ 0", covar.use, var.use, sep = "+"))
    )
}
all.medians <- rowMedians(as.matrix(counts(dds_obj)))
# Adding the per group medians here:
counts.split <- split(as.data.frame(t(counts(dds_obj))), as.factor(unlist(colData(dds_obj)[[var.use]])))
medians.group <- lapply(counts.split, function(x) colMedians(as.matrix(x)))
minMedianperGroup <- thres
low.express <- medians.group[[1]] < minMedianperGroup & medians.group[[2]] < minMedianperGroup
dds_obj.fil <- dds_obj[!low.express, ]
dds_obj.fil <- DESeq(dds_obj.fil)
dds_obj.res <- results(dds_obj.fil, contrast = c(var.use, cond1, cond2), tidy = T)
dds_obj.res$qvalue <- qvalue::qvalue(dds_obj.res$pvalue)$qvalue
dds_obj.res <- dds_obj.res[!is.na(dds_obj.res$qvalue), ]
print(dim(dds_obj.res))
print(sum(dds_obj.res$qvalue < 0.05))
filename <- paste("/gpfs/data/courses/aio2025/yb2612/data/outputs/DESeq2", study_name, "_", var.use, "_", cond1, "_vs_", cond2, "_MedianCounts_", thres, "_results.csv", sep = "")
write.csv(dds_obj.res, filename)
