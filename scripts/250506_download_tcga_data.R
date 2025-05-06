# Add option for setenv broom size to enlarge it
Sys.setenv("VROOM_CONNECTION_SIZE" = 2**20)
library(UCSCXenaTools)
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
    XenaDownload(destdir = "/data/scratch/nikolas") -> xe_download
# Load it in
pdata <- XenaPrepare(xe_download)
pdata <- as.data.frame(pdata)
# Subset to pancreas
pancreas_samples <- unlist(pdata[["_primary_site"]]) == "Endometrium"
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
saveRDS(counts, "/gpfs/data/courses/aio2025/yb2612/data/TCGAGTEx_UCEC_counts.RDS")
saveRDS(pdata, "/gpfs/data/courses/aio2025/yb2612/data/TCGAGTEx_UCEC_pdata.RDS")
