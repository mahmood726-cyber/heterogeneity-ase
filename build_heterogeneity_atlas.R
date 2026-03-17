#!/usr/bin/env Rscript
################################################################################
# Build the Heterogeneity Atlas: granular empirical priors for tau-squared
#
# Reads the Pairwise70 meta-analysis results and computes outcome-specific
# prior distributions (mean and variance of tau-squared) stratified by
# outcome type (binary/continuous/generic) and outcome class
# (objective/subjective/other).
#
# Input:  data/output/remediation_analysis_results.csv
# Output: inst/extdata/granular_priors.csv (shipped with package)
#         output/granular_heterogeneity_priors.csv (development copy)
#
# Author: Mahmood Ul Hassan
################################################################################

suppressPackageStartupMessages({
  library(data.table)
})

# Determine script directory
script_dir <- tryCatch(
  dirname(sys.frame(1)$ofile),
  error = function(e) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) > 0) dirname(normalizePath(sub("^--file=", "", file_arg[1])))
    else getwd()
  }
)

input_file <- file.path(script_dir, "data", "output", "remediation_analysis_results.csv")
output_dir <- file.path(script_dir, "output")
pkg_dir <- file.path(script_dir, "inst", "extdata")

stopifnot(file.exists(input_file))
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(pkg_dir, showWarnings = FALSE, recursive = TRUE)

cat("Loading meta-analysis data for Heterogeneity Atlas...\n")
data <- fread(input_file)
cat(sprintf("  Total rows: %d\n", nrow(data)))

# Filter valid entries
valid_data <- data[k_used >= 2 & meta_status == "ok" & !is.na(tau2)]
cat(sprintf("  Valid meta-analyses (k >= 2, ok, non-NA tau2): %d\n", nrow(valid_data)))

# Classify outcomes by keyword matching on analysis name
obj_keywords <- "mortality|death|stroke|infarction|survival|hospitalization|readmission|cancer|fracture|infection"
sub_keywords <- "pain|quality of life|depression|anxiety|satisfaction|fatigue|score|scale|well-being|symptom"

valid_data[, outcome_class := fifelse(
  grepl(obj_keywords, tolower(analysis_name)), "objective",
  fifelse(grepl(sub_keywords, tolower(analysis_name)), "subjective", "other")
)]

# Compute per-stratum statistics
granular_priors <- valid_data[, .(
  N = .N,
  mean_tau2 = mean(tau2),
  var_tau2 = var(tau2),
  median_tau2 = median(tau2)
), by = .(outcome_type, outcome_class)]

# Handle sparse strata: merge any stratum with N < 5 into its parent outcome_type
sparse <- granular_priors[N < 5]
if (nrow(sparse) > 0) {
  cat(sprintf("\nMerging %d sparse strata (N < 5) into parent outcome_type:\n", nrow(sparse)))
  for (i in seq_len(nrow(sparse))) {
    ot <- sparse$outcome_type[i]
    oc <- sparse$outcome_class[i]
    cat(sprintf("  %s/%s (N=%d) -> merging into %s/other\n", ot, oc, sparse$N[i], ot))
    # Re-compute the parent stratum by merging this stratum's data
    parent <- valid_data[outcome_type == ot & outcome_class != oc]
    merged <- valid_data[outcome_type == ot]
    granular_priors <- granular_priors[!(outcome_type == ot & outcome_class == oc)]
    # Update the "other" or largest stratum
    other_row <- granular_priors[outcome_type == ot & outcome_class == "other"]
    if (nrow(other_row) > 0) {
      merged_data <- valid_data[outcome_type == ot & (outcome_class == "other" | outcome_class == oc)]
      granular_priors[outcome_type == ot & outcome_class == "other",
        `:=`(N = nrow(merged_data), mean_tau2 = mean(merged_data$tau2),
             var_tau2 = var(merged_data$tau2), median_tau2 = median(merged_data$tau2))]
    }
  }
}

# Sort for readability
granular_priors <- granular_priors[order(outcome_type, outcome_class)]

cat("\nGranular Empirical Priors:\n")
print(granular_priors)

# Save
fwrite(granular_priors, file.path(output_dir, "granular_heterogeneity_priors.csv"))
fwrite(granular_priors, file.path(pkg_dir, "granular_priors.csv"))
cat(sprintf("\nSaved to:\n  %s\n  %s\n",
            file.path(output_dir, "granular_heterogeneity_priors.csv"),
            file.path(pkg_dir, "granular_priors.csv")))
cat("\nHeterogeneity Atlas build complete.\n")
