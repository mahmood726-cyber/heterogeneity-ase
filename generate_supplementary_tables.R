#!/usr/bin/env Rscript
################################################################################
# Generate Supplementary Tables S1-S3
################################################################################

script_dir <- tryCatch(
  dirname(sys.frame(1)$ofile),
  error = function(e) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) > 0) {
      dirname(normalizePath(sub("^--file=", "", file_arg[1])))
    } else {
      getwd()
    }
  }
)

source(file.path(script_dir, "R", "ASE.R"))

suppressPackageStartupMessages({
  library(metafor)
})

dat <- read.csv(file.path(script_dir, "output", "benchmark_results_v2.csv"),
                stringsAsFactors = FALSE)
out_dir <- file.path(script_dir, "output")

# ============================================================================
# S1 Table: Full simulation results including PM
# ============================================================================

s1 <- data.frame(
  k = dat$k,
  true_tau2 = dat$true_tau2,
  DL_bias = round(dat$dl_bias, 4),
  REML_bias = round(dat$reml_bias, 4),
  PM_bias = round(dat$pm_bias, 4),
  ASE_bias = round(dat$ase_bias, 4),
  DL_MSE = round(dat$dl_mse, 4),
  REML_MSE = round(dat$reml_mse, 4),
  PM_MSE = round(dat$pm_mse, 4),
  ASE_MSE = round(dat$ase_mse, 4),
  DL_coverage_pct = round(dat$dl_coverage * 100, 1),
  REML_coverage_pct = round(dat$reml_coverage * 100, 1),
  REML_HKSJ_coverage_pct = round(dat$hksj_coverage * 100, 1),
  ASE_HKSJ_coverage_pct = round(dat$ase_coverage * 100, 1),
  ASE_z_coverage_pct = round(dat$ase_nohksj_coverage * 100, 1),
  DL_CI_width = round(dat$dl_ci_width, 4),
  REML_CI_width = round(dat$reml_ci_width, 4),
  HKSJ_CI_width = round(dat$hksj_ci_width, 4),
  ASE_CI_width = round(dat$ase_ci_width, 4),
  ASE_weight = round(dat$ase_mean_weight, 3),
  Conflict_pct = round(dat$ase_conflict_pct, 1)
)

write.csv(s1, file.path(out_dir, "S1_Table_Full_Results.csv"), row.names = FALSE)
cat("S1 Table saved:", normalizePath(file.path(out_dir, "S1_Table_Full_Results.csv")), "\n")

# ============================================================================
# S2 Table: Ablation analysis (full k range)
# ============================================================================

s2 <- data.frame(
  k = dat$k,
  true_tau2 = dat$true_tau2,
  DL_z_coverage_pct = round(dat$dl_coverage * 100, 1),
  REML_HKSJ_coverage_pct = round(dat$hksj_coverage * 100, 1),
  ASE_z_coverage_pct = round(dat$ase_nohksj_coverage * 100, 1),
  ASE_HKSJ_coverage_pct = round(dat$ase_coverage * 100, 1),
  DL_z_CI_width = round(dat$dl_ci_width, 4),
  REML_HKSJ_CI_width = round(dat$hksj_ci_width, 4),
  ASE_HKSJ_CI_width = round(dat$ase_ci_width, 4)
)

write.csv(s2, file.path(out_dir, "S2_Table_Ablation.csv"), row.names = FALSE)
cat("S2 Table saved:", normalizePath(file.path(out_dir, "S2_Table_Ablation.csv")), "\n")

# ============================================================================
# S3 Table: Conflict threshold sensitivity (1 SD, 2 SD, 3 SD)
# ============================================================================

# Pre-generate datasets for each (k, tau2) combination, then apply all thresholds
# to the SAME simulated data. This ensures fair comparison across thresholds.
n_sims <- 1000
true_mu <- 0.3

mu_prior <- 0.139
var_prior <- 0.288
sd_prior <- sqrt(var_prior)

k_vals <- c(3, 5)
tau2_vals <- c(0.25, 0.50)
thresholds <- c(1, 2, 3)

results <- list()

for (k in k_vals) {
  for (true_tau2 in tau2_vals) {
    # Fixed seed per (k, tau2) pair for reproducibility
    set.seed(2026 + k * 100 + as.integer(true_tau2 * 100))

    # Pre-generate and store DL estimates for this scenario
    dl_estimates <- numeric(n_sims)
    mean_vis <- numeric(n_sims)
    valid <- logical(n_sims)

    for (sim in 1:n_sims) {
      vi <- runif(k, 0.02, 0.10)
      yi <- rnorm(k, true_mu, sqrt(vi + true_tau2))

      res_dl <- tryCatch(metafor::rma(yi, vi, method = "DL"), error = function(e) NULL)
      if (is.null(res_dl)) {
        valid[sim] <- FALSE
        next
      }
      valid[sim] <- TRUE
      dl_estimates[sim] <- res_dl$tau2
      mean_vis[sim] <- mean(vi)
    }

    # Now apply each threshold to the same pre-generated DL estimates
    for (thresh in thresholds) {
      bias_vals <- numeric(n_sims)
      mse_vals <- numeric(n_sims)
      conflict_count <- 0

      for (sim in 1:n_sims) {
        if (!valid[sim]) { bias_vals[sim] <- NA; mse_vals[sim] <- NA; next }

        tau2_dl <- dl_estimates[sim]
        mean_vi <- mean_vis[sim]

        var_tau2_dl <- (2 / (k - 1)) * (tau2_dl + mean_vi)^2
        w_base <- var_prior / (var_tau2_dl + var_prior)

        conflict_mag <- abs(tau2_dl - mu_prior) / sd_prior

        if (conflict_mag > thresh) {
          conflict_factor <- 1 - exp(-(conflict_mag - thresh))
          w <- w_base + (1 - w_base) * conflict_factor
          conflict_count <- conflict_count + 1
        } else {
          w <- w_base
        }

        tau2_ase <- max(0, w * tau2_dl + (1 - w) * mu_prior)
        bias_vals[sim] <- tau2_ase - true_tau2
        mse_vals[sim] <- (tau2_ase - true_tau2)^2
      }

      results[[length(results) + 1]] <- data.frame(
        k = k,
        true_tau2 = true_tau2,
        threshold_SD = thresh,
        ASE_MSE = round(mean(mse_vals, na.rm = TRUE), 4),
        ASE_bias = round(mean(bias_vals, na.rm = TRUE), 4),
        Conflict_pct = round(conflict_count / n_sims * 100, 1)
      )
    }
  }
}

s3 <- do.call(rbind, results)
write.csv(s3, file.path(out_dir, "S3_Table_Sensitivity.csv"), row.names = FALSE)
cat("S3 Table saved:", normalizePath(file.path(out_dir, "S3_Table_Sensitivity.csv")), "\n")
