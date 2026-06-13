# ============================================================
# harness.R -- Truth-recovery yardstick for ASE (heterogeneity-ase).
#
# ASE shrinks the tau^2 estimate toward an outcome-specific PRIOR from the
# Pairwise70 Heterogeneity Atlas (Empirical Bayes), with a conflict guard. The
# repo's own benchmark measures tau^2 MSE + coverage across true tau^2 values;
# this harness adds the missing PRIOR-DATA-CONFLICT stress test (the map-priors
# analog): when the true tau^2 MATCHES the Atlas prior, does shrinkage help; and
# when it is FAR from the prior (conflict), does ASE avoid being dragged to the
# wrong value (does the conflict guard protect coverage)?
#
# Uses binary/objective, whose Atlas prior is informative (mean tau2 ~0.096,
# var ~0.13) so shrinkage actually bites (the continuous prior is diffuse,
# var~150, so ASE == DL there -- reported separately).
#
# Truth-first: every number is produced from seeded simulation here.
# Run:  Rscript truth-recovery/harness.R 400
# ============================================================
suppressMessages(library(metafor)); suppressMessages(library(data.table))
this <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
source(file.path(dirname(this), "..", "R", "ASE.R"))

args <- commandArgs(TRUE)
NSIM <- if (length(args) >= 1) as.integer(args[1]) else 400
TRUE_MU <- 0.3
PRIOR_MEAN <- 0.096   # binary/objective Atlas prior mean tau2

gen <- function(k, true_tau2, seed) {
  set.seed(seed)
  vi <- runif(k, 0.02, 0.20)
  yi <- rnorm(k, TRUE_MU, sqrt(vi + true_tau2))
  list(yi = yi, vi = vi)
}

run_cell <- function(k, true_tau2) {
  tau_err <- list(ASE = c(), DL = c(), REML = c())
  cov <- list(ASE = c(), DL = c(), REML = c())
  conflict_rate <- c()
  for (s in 1:NSIM) {
    d <- gen(k, true_tau2, 2000 + s)
    fit_dl <- tryCatch(rma(yi = d$yi, vi = d$vi, method = "DL"), error = function(e) NULL)
    fit_rl <- tryCatch(rma(yi = d$yi, vi = d$vi, method = "REML"), error = function(e) NULL)
    fit_ase <- tryCatch(ASE(d$yi, d$vi, outcome_type = "binary", outcome_class = "objective", hksj = TRUE),
                        error = function(e) NULL)
    if (!is.null(fit_dl)) { tau_err$DL <- c(tau_err$DL, fit_dl$tau2 - true_tau2)
      cov$DL <- c(cov$DL, fit_dl$ci.lb <= TRUE_MU & fit_dl$ci.ub >= TRUE_MU) }
    if (!is.null(fit_rl)) { tau_err$REML <- c(tau_err$REML, fit_rl$tau2 - true_tau2)
      cov$REML <- c(cov$REML, fit_rl$ci.lb <= TRUE_MU & fit_rl$ci.ub >= TRUE_MU) }
    if (!is.null(fit_ase)) { tau_err$ASE <- c(tau_err$ASE, fit_ase$tau2_ase - true_tau2)
      cov$ASE <- c(cov$ASE, fit_ase$pooled_ci_lb <= TRUE_MU & fit_ase$pooled_ci_ub >= TRUE_MU)
      conflict_rate <- c(conflict_rate, isTRUE(fit_ase$conflict_detected)) }
  }
  mse <- function(e) round(mean(e^2), 5); bias <- function(e) round(mean(e), 4)
  list(k = k, true_tau2 = true_tau2,
       tau2_mse = sapply(tau_err, mse), tau2_bias = sapply(tau_err, bias),
       coverage = sapply(cov, function(z) round(mean(z), 3)),
       conflict = round(mean(conflict_rate), 3))
}

cat(sprintf("\n# Truth-recovery yardstick -- ASE (heterogeneity-ase)  nsim=%d\n", NSIM))
cat(sprintf("binary/objective Atlas prior mean tau2 = %.3f ; true mu = %.1f\n\n", PRIOR_MEAN, TRUE_MU))
cells <- list(c(5, 0.0), c(5, PRIOR_MEAN), c(5, 0.5),
              c(15, 0.0), c(15, PRIOR_MEAN), c(15, 0.5))
cat(sprintf("%3s %9s %6s | %26s | %26s | %18s | %8s\n",
            "k", "true_t2", "regime", "tau2 MSE (ASE/DL/REML)", "mu cov (ASE/DL/REML)", "tau2 bias ASE/DL", "conflict"))
for (cl in cells) {
  r <- run_cell(cl[1], cl[2])
  regime <- if (abs(cl[2] - PRIOR_MEAN) < 1e-6) "MATCH" else if (cl[2] > PRIOR_MEAN) "CONFLICT+" else "below"
  cat(sprintf("%3d %9.3f %6s | %8.5f %8.5f %8.5f | %7.3f %7.3f %7.3f | %8.4f %8.4f | %8.3f\n",
              r$k, r$true_tau2, regime,
              r$tau2_mse["ASE"], r$tau2_mse["DL"], r$tau2_mse["REML"],
              r$coverage["ASE"], r$coverage["DL"], r$coverage["REML"],
              r$tau2_bias["ASE"], r$tau2_bias["DL"], r$conflict))
}
cat("\n(tau2 MSE/coverage of true mu; conflict = fraction ASE flagged prior-data conflict)\n")
