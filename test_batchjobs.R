#from /share/data/dan_temp/lls_projects/batchjobs_test
# ./R-3.1.2/bin/R
#library(devtools)
#install_github("biodev/BatchJobs@exacloud_mods")

library(BatchJobs)
library(BiocParallel)

FUN <- function(i) system("hostname", intern=TRUE)

if(!file.exists("logs"))dir.create("logs")
use.resources <- list(memory='30 GB', cpus='5', log.dir=file.path(getwd(), "logs"))

param <- BatchJobsParam(4, resources=use.resources, progressbar=F, cleanup=F)
register(param)
## do work
xx <- bplapply(1:100, FUN)
table(unlist(xx))

#/mnt/tempwork/NGSdev/R-3.1.2/bin/R

library(BatchJobs)
library(BiocParallel)

use.resources <- list(memory='30 GB', cpus='5', log.dir=file.path(getwd(), "logs"))

param <- BatchJobsParam(4, resources=use.resources, progressbar=F, cleanup=F, work.dir="/mnt/tempwork/NGSdev/")
register(param)

source("fastq_summ.R")

base.dir <- "/mnt/lustre1/BeatAML/rnaseq/BeatAML/raw/BeatAML1/FlowCell1/150312_D00735_0028_AC62DEANXX/"

use.dirs <- list.files(base.dir, pattern="Sample_", full.names=T)

summarize.fastq(useDirs=use.dirs[1:5], out.dir="/mnt/lustre1/NGSdev/tests/BatchJobs_tests/test_lustre")

