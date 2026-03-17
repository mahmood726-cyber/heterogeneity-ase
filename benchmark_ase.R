#!/usr/bin/env Rscript
################################################################################
# ASE Comprehensive Benchmark Suite
#
# Compares ASE against DL, REML, PM, and HKSJ-corrected methods across:
# - Multiple true tau2 values: 0, 0.01, 0.05, 0.1, 0.25, 0.5
# - Multiple k values: 3, 5, 10, 20
# - 1000 Monte Carlo replications per scenario
#
# Metrics: bias, MSE, coverage probability (95% CI), CI width
#
# Author: Mahmood Ul Hassan
################################################################################

suppressPackageStartupMessages({
  library(metafor)
  library(data.table)
})

# Determine script directory robustly
script_dir <- tryCatch(
  dirname(sys.frame(1)$ofile),
  error = function(e) {
    # Fallback for Rscript: use commandArgs
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

set.seed(2026)
n_sims <- 1000  # MC SE for coverage ~0.7 pp at p=0.95
true_mu <- 0.3  # true pooled effect (log-OR scale)

# Simulation grid
k_values <- c(3, 5, 10, 20)
tau2_values <- c(0, 0.01, 0.05, 0.10, 0.25, 0.50)

cat("=== ASE Comprehensive Benchmark ===\n")
cat(sprintf("Replications: %d per scenario\n", n_sims))
cat(sprintf("k values: %s\n", paste(k_values, collapse=", ")))
cat(sprintf("True tau2 values: %s\n", paste(tau2_values, collapse=", ")))
cat(sprintf("True mu: %.1f\n\n", true_mu))

all_results <- list()

for (k in k_values) {
  for (true_tau2 in tau2_values) {
    cat(sprintf("Running k=%d, tau2=%.2f ... ", k, true_tau2))

    sim_results <- rbindlist(lapply(1:n_sims, function(s) {
      # Generate data from random-effects model
      vi <- runif(k, 0.02, 0.10)
      yi <- rnorm(k, true_mu, sqrt(vi + true_tau2))

      # --- DL ---
      fit_dl <- tryCatch(rma(yi, vi, method = "DL"), error = function(e) NULL)
      dl_tau2 <- if (!is.null(fit_dl)) fit_dl$tau2 else NA
      dl_cov <- if (!is.null(fit_dl)) (fit_dl$ci.lb <= true_mu & fit_dl$ci.ub >= true_mu) else NA
      dl_width <- if (!is.null(fit_dl)) (fit_dl$ci.ub - fit_dl$ci.lb) else NA

      # --- REML ---
      fit_reml <- tryCatch(rma(yi, vi, method = "REML"), error = function(e) NULL)
      reml_tau2 <- if (!is.null(fit_reml)) fit_reml$tau2 else NA
      reml_cov <- if (!is.null(fit_reml)) (fit_reml$ci.lb <= true_mu & fit_reml$ci.ub >= true_mu) else NA
      reml_width <- if (!is.null(fit_reml)) (fit_reml$ci.ub - fit_reml$ci.lb) else NA

      # --- REML + HKSJ (for fair comparison) ---
      fit_hksj <- tryCatch(rma(yi, vi, method = "REML", test = "knha"),
                           error = function(e) NULL)
      hksj_tau2 <- if (!is.null(fit_hksj)) fit_hksj$tau2 else NA
      hksj_cov <- if (!is.null(fit_hksj)) (fit_hksj$ci.lb <= true_mu & fit_hksj$ci.ub >= true_mu) else NA
      hksj_width <- if (!is.null(fit_hksj)) (fit_hksj$ci.ub - fit_hksj$ci.lb) else NA

      # --- PM ---
      fit_pm <- tryCatch(rma(yi, vi, method = "PM"), error = function(e) NULL)
      pm_tau2 <- if (!is.null(fit_pm)) fit_pm$tau2 else NA

      # --- ASE ---
      fit_ase <- tryCatch(
        ASE(yi, vi, outcome_type = "binary", outcome_class = "other", hksj = TRUE),
        error = function(e) NULL
      )
      ase_tau2 <- if (!is.null(fit_ase)) fit_ase$tau2_ase else NA
      ase_cov <- if (!is.null(fit_ase)) {
        (fit_ase$pooled_ci_lb <= true_mu & fit_ase$pooled_ci_ub >= true_mu)
      } else NA
      ase_width <- if (!is.null(fit_ase)) {
        (fit_ase$pooled_ci_ub - fit_ase$pooled_ci_lb)
      } else NA
      ase_weight <- if (!is.null(fit_ase)) fit_ase$weight else NA
      ase_conflict <- if (!is.null(fit_ase)) fit_ase$conflict_detected else NA

      # --- ASE without HKSJ (ablation) ---
      fit_ase_nohksj <- tryCatch(
        ASE(yi, vi, outcome_type = "binary", outcome_class = "other", hksj = FALSE),
        error = function(e) NULL
      )
      ase_nohksj_cov <- if (!is.null(fit_ase_nohksj)) {
        (fit_ase_nohksj$pooled_ci_lb <= true_mu & fit_ase_nohksj$pooled_ci_ub >= true_mu)
      } else NA
      ase_nohksj_width <- if (!is.null(fit_ase_nohksj)) {
        (fit_ase_nohksj$pooled_ci_ub - fit_ase_nohksj$pooled_ci_lb)
      } else NA

      data.table(
        sim = s,
        dl_tau2 = dl_tau2, reml_tau2 = reml_tau2, hksj_tau2 = hksj_tau2,
        pm_tau2 = pm_tau2, ase_tau2 = ase_tau2,
        dl_cov = as.numeric(dl_cov), reml_cov = as.numeric(reml_cov),
        hksj_cov = as.numeric(hksj_cov), ase_cov = as.numeric(ase_cov),
        ase_nohksj_cov = as.numeric(ase_nohksj_cov),
        ase_nohksj_width = ase_nohksj_width,
        dl_width = dl_width, reml_width = reml_width,
        hksj_width = hksj_width, ase_width = ase_width,
        ase_weight = ase_weight, ase_conflict = as.numeric(ase_conflict)
      )
    }))

    # Compute summary statistics
    compute_stats <- function(tau2_col, cov_col, width_col, true_tau2) {
      tau2_vals <- sim_results[[tau2_col]]
      cov_vals <- sim_results[[cov_col]]
      width_vals <- sim_results[[width_col]]
      list(
        bias = mean(tau2_vals - true_tau2, na.rm = TRUE),
        mse = mean((tau2_vals - true_tau2)^2, na.rm = TRUE),
        coverage = mean(cov_vals, na.rm = TRUE),
        ci_width = mean(width_vals, na.rm = TRUE),
        n_valid = sum(!is.na(tau2_vals))
      )
    }

    dl_stats <- compute_stats("dl_tau2", "dl_cov", "dl_width", true_tau2)
    reml_stats <- compute_stats("reml_tau2", "reml_cov", "reml_width", true_tau2)
    hksj_stats <- compute_stats("hksj_tau2", "hksj_cov", "hksj_width", true_tau2)
    ase_stats <- compute_stats("ase_tau2", "ase_cov", "ase_width", true_tau2)

    # PM tau2 stats (no pooled effect metrics)
    pm_tau2_vals <- sim_results$pm_tau2
    pm_bias <- mean(pm_tau2_vals - true_tau2, na.rm = TRUE)
    pm_mse <- mean((pm_tau2_vals - true_tau2)^2, na.rm = TRUE)

    # ASE-specific metrics
    ase_nohksj_cov <- mean(sim_results$ase_nohksj_cov, na.rm = TRUE)
    ase_nohksj_ci_width <- mean(sim_results$ase_nohksj_width, na.rm = TRUE)
    ase_mean_weight <- mean(sim_results$ase_weight, na.rm = TRUE)
    ase_conflict_rate <- mean(sim_results$ase_conflict, na.rm = TRUE)

    row <- data.table(
      k = k, true_tau2 = true_tau2,
      # tau2 bias
      dl_bias = round(dl_stats$bias, 6), reml_bias = round(reml_stats$bias, 6),
      pm_bias = round(pm_bias, 6), ase_bias = round(ase_stats$bias, 6),
      # tau2 MSE
      dl_mse = round(dl_stats$mse, 6), reml_mse = round(reml_stats$mse, 6),
      pm_mse = round(pm_mse, 6), ase_mse = round(ase_stats$mse, 6),
      # Coverage (pooled effect CI)
      dl_coverage = round(dl_stats$coverage, 4),
      reml_coverage = round(reml_stats$coverage, 4),
      hksj_coverage = round(hksj_stats$coverage, 4),
      ase_coverage = round(ase_stats$coverage, 4),
      ase_nohksj_coverage = round(ase_nohksj_cov, 4),
      ase_nohksj_ci_width = round(ase_nohksj_ci_width, 4),
      # CI width
      dl_ci_width = round(dl_stats$ci_width, 4),
      reml_ci_width = round(reml_stats$ci_width, 4),
      hksj_ci_width = round(hksj_stats$ci_width, 4),
      ase_ci_width = round(ase_stats$ci_width, 4),
      # ASE internals
      ase_mean_weight = round(ase_mean_weight, 4),
      ase_conflict_pct = round(100 * ase_conflict_rate, 1)
    )
    all_results[[length(all_results) + 1]] <- row

    cat(sprintf("ASE MSE=%.4f (DL=%.4f, REML=%.4f), ASE cov=%.1f%% (HKSJ=%.1f%%)\n",
                ase_stats$mse, dl_stats$mse, reml_stats$mse,
                100 * ase_stats$coverage, 100 * hksj_stats$coverage))
  }
}

results_dt <- rbindlist(all_results)

# Save results
output_path <- file.path(script_dir, "output", "benchmark_results_v2.csv")
dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
fwrite(results_dt, output_path)
cat(sprintf("\nResults saved to %s\n", output_path))

# Print summary table
cat("\n=== SUMMARY TABLE ===\n\n")
cat(sprintf("%-4s %-8s | %-10s %-10s %-10s %-10s | %-8s %-8s %-8s %-8s\n",
            "k", "tau2", "DL_MSE", "REML_MSE", "PM_MSE", "ASE_MSE",
            "DL_cov", "REML_cov", "HKSJ_cov", "ASE_cov"))
cat(paste(rep("-", 100), collapse = ""), "\n")
for (i in seq_len(nrow(results_dt))) {
  r <- results_dt[i, ]
  cat(sprintf("%-4d %-8.2f | %-10.6f %-10.6f %-10.6f %-10.6f | %-8.1f %-8.1f %-8.1f %-8.1f\n",
              r$k, r$true_tau2, r$dl_mse, r$reml_mse, r$pm_mse, r$ase_mse,
              100*r$dl_coverage, 100*r$reml_coverage, 100*r$hksj_coverage, 100*r$ase_coverage))
}

# Save session info for reproducibility
writeLines(capture.output(sessionInfo()),
           file.path(script_dir, "output", "session_info.txt"))
cat("Session info saved.\n")

cat("\n=== BENCHMARK COMPLETE ===\n")
