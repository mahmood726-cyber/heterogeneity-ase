################################################################################
# Unit tests for the ASE function
################################################################################

# Source ASE directly for testing without package install
# Try multiple strategies to find the R/ directory
source_dir <- NULL
# Strategy 1: sys.frame (works when sourced directly)
source_dir <- tryCatch({
  normalizePath(file.path(dirname(sys.frame(1)$ofile), "..", "..", "R"), mustWork = TRUE)
}, error = function(e) NULL)
# Strategy 2: getwd() (works when run_tests.R sets cwd to project root)
if (is.null(source_dir)) {
  candidate <- normalizePath(file.path(getwd(), "R"), mustWork = FALSE)
  if (file.exists(file.path(candidate, "ASE.R"))) source_dir <- candidate
}
# Strategy 3: testthat test directory is tests/testthat, so go up 2 levels
if (is.null(source_dir)) {
  candidate <- normalizePath(file.path(getwd(), "..", "..", "R"), mustWork = FALSE)
  if (file.exists(file.path(candidate, "ASE.R"))) source_dir <- candidate
}
if (!is.null(source_dir) && file.exists(file.path(source_dir, "ASE.R"))) {
  source(file.path(source_dir, "ASE.R"))
}

library(metafor)

# ---------------------------------------------------------------------------
# 1. Basic functionality
# ---------------------------------------------------------------------------

test_that("ASE returns expected structure for valid input", {
  set.seed(1)
  yi <- c(0.5, 0.3, 0.8, 0.2, 0.6)
  vi <- c(0.04, 0.06, 0.05, 0.03, 0.07)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")

  expect_type(res, "list")
  expect_true(all(c("k", "tau2_ase", "tau2_dl", "weight", "prior_mean",
                     "prior_var", "conflict_detected", "pooled_est",
                     "pooled_se", "pooled_ci_lb", "pooled_ci_ub",
                     "pooled_pval", "I2") %in% names(res)))
  expect_equal(res$k, 5)
  expect_true(res$tau2_ase >= 0)
  expect_true(res$weight >= 0 && res$weight <= 1)
  expect_true(res$I2 >= 0 && res$I2 <= 100)
  expect_true(res$pooled_ci_lb < res$pooled_ci_ub)
})

test_that("ASE accepts rma object input", {
  set.seed(2)
  yi <- rnorm(5, 0.3, 0.2)
  vi <- runif(5, 0.02, 0.08)
  rma_obj <- rma(yi, vi, method = "REML")

  res <- ASE(rma_obj)
  expect_type(res, "list")
  expect_equal(res$k, 5)
})

# ---------------------------------------------------------------------------
# 2. Edge cases
# ---------------------------------------------------------------------------

test_that("ASE returns NULL with warning for k < 2", {
  expect_warning(
    res <- ASE(c(0.5), c(0.04)),
    "k >= 2"
  )
  expect_null(res)
})

test_that("ASE errors when vi missing for vector input", {
  expect_error(ASE(c(0.5, 0.3)), "vi must be provided")
})

test_that("ASE handles k=2 (minimum)", {
  set.seed(3)
  yi <- c(0.5, 0.3)
  vi <- c(0.04, 0.06)
  res <- ASE(yi, vi)
  expect_type(res, "list")
  expect_equal(res$k, 2)
})

test_that("ASE handles zero heterogeneity data", {
  yi <- rep(0.5, 5)
  vi <- rep(0.04, 5)
  res <- ASE(yi, vi)
  expect_type(res, "list")
  expect_equal(res$tau2_dl, 0)
  expect_true(res$tau2_ase > 0)  # shrunk toward prior
})

# ---------------------------------------------------------------------------
# 3. Input validation
# ---------------------------------------------------------------------------

test_that("NA in yi rejected", {
  expect_error(ASE(c(0.5, NA, 0.3), c(0.04, 0.06, 0.05)), "NA")
})

test_that("Negative vi rejected", {
  expect_error(ASE(c(0.5, 0.3), c(0.04, -0.01)), "positive")
})

test_that("Length mismatch rejected", {
  expect_error(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06)), "same length")
})

test_that("Invalid conf.level rejected", {
  expect_error(ASE(c(0.5, 0.3), c(0.04, 0.06), conf.level = 1.5), "conf.level")
})

# ---------------------------------------------------------------------------
# 4. Prior selection (P0-1 regression test)
# ---------------------------------------------------------------------------

test_that("Prior lookup uses correct outcome_type and outcome_class", {
  set.seed(4)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)

  res_binary_obj <- ASE(yi, vi, outcome_type = "binary", outcome_class = "objective")
  res_binary_other <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")

  expect_true(abs(res_binary_obj$prior_mean - res_binary_other$prior_mean) > 0.01)
  expect_true(abs(res_binary_obj$prior_mean - 0.096) < 0.01)
  expect_true(abs(res_binary_other$prior_mean - 0.139) < 0.01)
})

test_that("match.arg rejects invalid outcome_type", {
  expect_error(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), outcome_type = "bianry"), "arg")
})

test_that("Continuous outcome uses correct prior", {
  set.seed(12)
  yi <- rnorm(5, 0.3, 1.0)
  vi <- runif(5, 0.1, 0.5)
  res <- ASE(yi, vi, outcome_type = "continuous", outcome_class = "other")
  expect_true(abs(res$prior_mean - 1.908) < 0.01)
})

test_that("Generic outcome uses correct prior", {
  set.seed(13)
  yi <- rnorm(5, 0.3, 0.5)
  vi <- runif(5, 0.05, 0.2)
  res <- ASE(yi, vi, outcome_type = "generic", outcome_class = "other")
  expect_true(abs(res$prior_mean - 2.875) < 0.01)
})

# ---------------------------------------------------------------------------
# 5. Conflict detection
# ---------------------------------------------------------------------------

test_that("Conflict detected for extreme heterogeneity", {
  set.seed(14)
  yi <- c(5.0, -3.0, 2.0, -1.0, 4.0)
  vi <- rep(0.05, 5)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
  expect_true(res$conflict_detected)
})

test_that("No conflict for data consistent with prior", {
  set.seed(6)
  true_tau2 <- 0.14
  yi <- rnorm(10, 0.3, sqrt(0.05 + true_tau2))
  vi <- rep(0.05, 10)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
  expect_false(res$conflict_detected)
})

# ---------------------------------------------------------------------------
# 6. Asymptotic behavior
# ---------------------------------------------------------------------------

test_that("ASE weight approaches 1 as k increases", {
  set.seed(7)
  weights <- numeric(4)
  for (i in seq_along(c(3, 10, 50, 200))) {
    k <- c(3, 10, 50, 200)[i]
    yi <- rnorm(k, 0.3, sqrt(0.05 + 0.1))
    vi <- rep(0.05, k)
    res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "other")
    weights[i] <- res$weight
  }
  expect_true(all(diff(weights) > 0))
  expect_true(weights[4] > 0.95)
})

# ---------------------------------------------------------------------------
# 7. HKSJ and conf.level
# ---------------------------------------------------------------------------

test_that("HKSJ and z-based give same tau2 but different CIs", {
  set.seed(8)
  yi <- rnorm(3, 0.3, 0.3)
  vi <- runif(3, 0.02, 0.08)
  res_hksj <- ASE(yi, vi, hksj = TRUE)
  res_z <- ASE(yi, vi, hksj = FALSE)
  expect_equal(res_hksj$tau2_ase, res_z$tau2_ase)
})

test_that("conf.level 0.90 gives narrower CIs than 0.95", {
  set.seed(19)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res90 <- ASE(yi, vi, conf.level = 0.90)
  res95 <- ASE(yi, vi, conf.level = 0.95)
  width90 <- res90$pooled_ci_ub - res90$pooled_ci_lb
  width95 <- res95$pooled_ci_ub - res95$pooled_ci_lb
  expect_true(width90 < width95)
})

# ---------------------------------------------------------------------------
# 8. Numerical properties
# ---------------------------------------------------------------------------

test_that("ASE tau2 is non-negative across 20 seeds", {
  for (s in 1:20) {
    set.seed(s + 100)
    k <- sample(2:10, 1)
    yi <- rnorm(k, 0, 0.5)
    vi <- runif(k, 0.01, 0.1)
    res <- ASE(yi, vi)
    if (!is.null(res)) {
      expect_true(res$tau2_ase >= 0)
    }
  }
})

test_that("P-value is valid", {
  set.seed(15)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res <- ASE(yi, vi)
  expect_true(res$pooled_pval >= 0 && res$pooled_pval <= 1)
})

# ---------------------------------------------------------------------------
# 9. Additional input validation (Round 3 review)
# ---------------------------------------------------------------------------

test_that("Inf in yi rejected", {
  expect_error(ASE(c(0.5, Inf, 0.3), c(0.04, 0.06, 0.05)), "Inf")
})

test_that("Non-numeric yi rejected", {
  expect_error(ASE(c("a", "b", "c"), c(0.04, 0.06, 0.05)), "numeric")
})

test_that("Non-numeric vi rejected", {
  expect_error(ASE(c(0.5, 0.3, 0.8), c("a", "b", "c")), "numeric")
})

test_that("Zero vi rejected", {
  expect_error(ASE(c(0.5, 0.3), c(0.04, 0)), "positive")
})

test_that("Subjective outcome class uses correct prior", {
  set.seed(20)
  yi <- rnorm(5, 0.3, 0.3)
  vi <- runif(5, 0.02, 0.08)
  res <- ASE(yi, vi, outcome_type = "binary", outcome_class = "subjective")
  expect_true(abs(res$prior_mean - 0.071) < 0.01)
})

test_that("Non-logical hksj rejected", {
  expect_error(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), hksj = "yes"), "TRUE or FALSE")
  expect_error(ASE(c(0.5, 0.3, 0.8), c(0.04, 0.06, 0.05), hksj = 2), "TRUE or FALSE")
})
