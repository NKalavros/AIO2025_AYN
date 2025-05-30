# https://github.com/parklab/SigMA/wiki/Quick-start

packages <- c(
    "BSgenome",
    "BSgenome.Hsapiens.UCSC.hg19",
    "BSgenome.Hsapiens.UCSC.hg38",
    "GenomicRanges",
    "IRanges",
    "VariantAnnotation"
)

if (getRversion() >= "3.6.0") {
    if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager", repos = "http://cran.us.r-project.org")
    }
    BiocManager::install(packages)
}
if (getRversion() < "3.6.0" & getRversion() >= "3.5.0") {
    source("https://bioconductor.org/biocLite.R")
    biocLite(packages)
}

devtools::install_github("parklab/SigMA")
