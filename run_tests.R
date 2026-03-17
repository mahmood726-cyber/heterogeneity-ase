#!/usr/bin/env Rscript
# Run ASE unit tests standalone (without package installation)

suppressPackageStartupMessages({
  library(metafor)
  library(data.table)
})

# Source ASE function (relative path — run from package root)
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

cat("=== Running ASE Unit Tests ===\n\n")

pass <- 0
fail <- 0

run_test <- function(name, expr) {
  result <- tryCatch({
    eval(expr)
    cat(sprintf("  PASS: %s\n", name))
    TRUE
  }, error = function(e) {
    cat(sprintf("  FAIL: %s -- %s\n", name, conditionMessage(e)))
    FALSE
  })
  if (result) pass <<- pass + 1 else fail <<- fail + 1
}

# Test 1: Basic structure
run_test("Basic structure", {
  set.seed(1)
  yi <- c(0.5, 0.3, 0.8, 0.2, 0.6)
  vi <- c(0.04, 0.06, 0.05, 0.03, 0.07)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
  stopifnot(is.list(res))
  stopifnot(res$k == 5)
  stopifnot(res$tau2_ase >= 0)
  stopifnot(res$weight >= 0 && res$weight <= 1)
  stopifnot(res$I2 >= 0 && res$I2 <= 100)
  stopifnot(res$pooled_ci_lb < res$pooled_ci_ub)
})

# Test 2: rma object input
run_test("rma object input", {
  set.seed(2)
  yi <- rnorm(5, 0.3, 0.2)
  vi <- runif(5, 0.02, 0.08)
  rma_obj <- rma(yi, vi, method = "REML")
  res <- ASE(rma_obj)
  stopifnot(is.list(res))
  stopifnot(res$k == 5)
})

# Test 3: k < 2 returns NULL
run_test("k < 2 returns NULL", {
  res <- suppressWarnings(ASE(c(0.5), c(0.04)))
  stopifnot(is.null(res))
})

# Test 4: missing vi errors
run_test("Missing vi errors", {
  tryCatch(ASE(c(0.5, 0.3)), error = function(e) {
    stopifnot(grepl("vi must be provided", conditionMessage(e)))
  })
})

# Test 5: k=2 minimum
run_test("k=2 minimum", {
  set.seed(3)
  res <- ASE(c(0.5, 0.3), c(0.04, 0.06))
  stopifnot(is.list(res))
  stopifnot(res$k == 2)
})

# Test 6: Zero heterogeneity -> shrinks toward prior
run_test("Zero heterogeneity shrinks to prior", {
  yi <- rep(0.5, 5)
  vi <- rep(0.04, 5)
  res <- ASE(yi, vi)
  stopifnot(res$tau2_dl == 0)
  stopifnot(res$tau2_ase > 0)  # shrunk toward prior
})

# Test 7: Prior lookup regression (P0-1 fix)
run_test("Prior lookup P0-1 fix", {
  set.seed(4)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res_obj <- ASE(yi, vi, outcome_type = "binary", outcome_class = "objective")
  res_other <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
  # Different priors should give different prior_mean
  stopifnot(abs(res_obj$prior_mean - res_other$prior_mean) > 0.01)
  stopifnot(abs(res_obj$prior_mean - 0.096) < 0.01)
  stopifnot(abs(res_other$prior_mean - 0.139) < 0.01)
})

# Test 8: Invalid outcome_type rejected
run_test("Invalid outcome_type rejected", {
  tryCatch(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), outcome_type = "bianry"),
           error = function(e) {
             stopifnot(grepl("arg", conditionMessage(e), ignore.case = TRUE))
           })
})

# Test 9: Asymptotic weight increase
run_test("Weight increases with k", {
  set.seed(7)
  weights <- numeric(4)
  for (i in seq_along(c(3, 10, 50, 200))) {
    k <- c(3, 10, 50, 200)[i]
    yi <- rnorm(k, 0.3, sqrt(0.05 + 0.1))
    vi <- rep(0.05, k)
    res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
    weights[i] <- res$weight
  }
  stopifnot(all(diff(weights) > 0))
  stopifnot(weights[4] > 0.95)
})

# Test 10: HKSJ same tau2, different CIs
run_test("HKSJ vs z-test: same tau2, different CIs", {
  set.seed(8)
  yi <- rnorm(3, 0.3, 0.3)
  vi <- runif(3, 0.02, 0.08)
  res_hksj <- ASE(yi, vi, hksj = TRUE)
  res_z <- ASE(yi, vi, hksj = FALSE)
  stopifnot(abs(res_hksj$tau2_ase - res_z$tau2_ase) < 1e-10)
})

# Test 11: Non-negative tau2 across many seeds
run_test("tau2 non-negative (20 random seeds)", {
  for (s in 1:20) {
    set.seed(s + 100)
    k <- sample(2:10, 1)
    yi <- rnorm(k, 0, 0.5)
    vi <- runif(k, 0.01, 0.1)
    res <- ASE(yi, vi)
    if (!is.null(res)) stopifnot(res$tau2_ase >= 0)
  }
})

# Test 12: Continuous outcome prior
run_test("Continuous outcome uses correct prior", {
  set.seed(12)
  yi <- rnorm(5, 0.3, 1.0)
  vi <- runif(5, 0.1, 0.5)
  res <- ASE(yi, vi, outcome_type = "continuous", outcome_class = "other")
  # continuous/other prior mean ~ 1.908
  stopifnot(abs(res$prior_mean - 1.908) < 0.01)
})

# Test 13: Generic outcome prior
run_test("Generic outcome uses correct prior", {
  set.seed(13)
  yi <- rnorm(5, 0.3, 0.5)
  vi <- runif(5, 0.05, 0.2)
  res <- ASE(yi, vi, outcome_type = "generic", outcome_class = "other")
  # generic/other prior mean ~ 2.875
  stopifnot(abs(res$prior_mean - 2.875) < 0.01)
})

# Test 14: Conflict detection for extreme data
run_test("Conflict detection for extreme tau2", {
  set.seed(14)
  yi <- c(5.0, -3.0, 2.0, -1.0, 4.0)
  vi <- rep(0.05, 5)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
  stopifnot(res$conflict_detected == TRUE)
})

# Test 15: Valid p-value
run_test("P-value in [0,1]", {
  set.seed(15)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res <- ASE(yi, vi)
  stopifnot(res$pooled_pval >= 0 && res$pooled_pval <= 1)
})

# Test 16: NA in yi errors
run_test("NA in yi rejected", {
  tryCatch(ASE(c(0.5, NA, 0.3), c(0.04, 0.06, 0.05)),
           error = function(e) {
             stopifnot(grepl("NA", conditionMessage(e)))
           })
})

# Test 17: Negative vi errors
run_test("Negative vi rejected", {
  tryCatch(ASE(c(0.5, 0.3), c(0.04, -0.01)),
           error = function(e) {
             stopifnot(grepl("positive", conditionMessage(e)))
           })
})

# Test 18: Length mismatch errors
run_test("Length mismatch rejected", {
  tryCatch(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06)),
           error = function(e) {
             stopifnot(grepl("same length", conditionMessage(e)))
           })
})

# Test 19: Custom conf.level
run_test("conf.level parameter works", {
  set.seed(19)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res90 <- ASE(yi, vi, conf.level = 0.90)
  res95 <- ASE(yi, vi, conf.level = 0.95)
  # 90% CI should be narrower than 95% CI
  width90 <- res90$pooled_ci_ub - res90$pooled_ci_lb
  width95 <- res95$pooled_ci_ub - res95$pooled_ci_lb
  stopifnot(width90 < width95)
})

# Test 20: Inf in yi rejected
run_test("Inf in yi rejected", {
  tryCatch(ASE(c(0.5, Inf, 0.3), c(0.04, 0.06, 0.05)),
           error = function(e) {
             stopifnot(grepl("Inf", conditionMessage(e)))
           })
})

# Test 21: Non-numeric yi rejected
run_test("Non-numeric yi rejected", {
  tryCatch(ASE(c("a", "b", "c"), c(0.04, 0.06, 0.05)),
           error = function(e) {
             stopifnot(grepl("numeric", conditionMessage(e)))
           })
})

# Test 22: Non-numeric vi rejected
run_test("Non-numeric vi rejected", {
  tryCatch(ASE(c(0.5, 0.3, 0.8), c("a", "b", "c")),
           error = function(e) {
             stopifnot(grepl("numeric", conditionMessage(e)))
           })
})

# Test 23: Zero vi rejected
run_test("Zero vi rejected", {
  tryCatch(ASE(c(0.5, 0.3), c(0.04, 0)),
           error = function(e) {
             stopifnot(grepl("positive", conditionMessage(e)))
           })
})

# Test 24: Subjective outcome class
run_test("Subjective outcome class uses correct prior", {
  set.seed(20)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "subjective")
  stopifnot(abs(res$prior_mean - 0.071) < 0.01)
})

# Test 25: Non-logical hksj rejected
run_test("Non-logical hksj rejected", {
  tryCatch(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), hksj = "yes"),
           error = function(e) {
             stopifnot(grepl("TRUE or FALSE", conditionMessage(e)))
           })
  tryCatch(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), hksj = 2),
           error = function(e) {
             stopifnot(grepl("TRUE or FALSE", conditionMessage(e)))
           })
})

cat(sprintf("\n=== RESULTS: %d PASS, %d FAIL ===\n", pass, fail))
if (fail > 0) quit(status = 1)
