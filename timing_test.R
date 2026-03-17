suppressPackageStartupMessages({ library(metafor); library(data.table) })
script_dir <- tryCatch(dirname(sys.frame(1)$ofile), error = function(e) {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
})
source(file.path(script_dir, "R", "ASE.R"))
set.seed(42)
t0 <- proc.time()
for (i in 1:100) {
  vi <- runif(3, 0.02, 0.10)
  yi <- rnorm(3, 0.3, sqrt(vi + 0.05))
  rma(yi, vi, method="DL")
  rma(yi, vi, method="REML")
  rma(yi, vi, method="REML", test="knha")
  rma(yi, vi, method="PM")
  ASE(yi, vi, outcome_type="binary", outcome_class="other", hksj=TRUE)
  ASE(yi, vi, outcome_type="binary", outcome_class="other", hksj=FALSE)
}
elapsed <- (proc.time() - t0)[3]
cat(sprintf("100 iterations: %.1f sec (%.1f ms/iter)\n", elapsed, 1000*elapsed/100))
cat(sprintf("Projected for 2000 x 24 scenarios: %.0f minutes\n", elapsed/100 * 2000 * 24 / 60))
