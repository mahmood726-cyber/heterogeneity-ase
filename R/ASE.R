#' Adaptive Shrinkage Estimator (ASE)
#'
#' Estimates heterogeneity (tau-squared) using a Conflict-Aware Empirical Bayes
#' shrinkage approach. Borrows strength from outcome-specific priors derived from
#' 17,236 Cochrane meta-analyses (the Pairwise70 Heterogeneity Atlas).
#'
#' @param x Either a metafor::rma object or a numeric vector of effect sizes (yi).
#' @param vi Numeric vector of sampling variances (required if x is yi vector).
#' @param outcome_type One of "binary", "continuous", or "generic".
#' @param outcome_class One of "objective", "subjective", or "other".
#' @param hksj Logical: use Hartung-Knapp-Sidik-Jonkman adjustment (default TRUE).
#' @param conf.level Confidence level for the pooled effect CI (default 0.95).
#' @return A list with components:
#'   \describe{
#'     \item{k}{Number of studies}
#'     \item{tau2_ase}{ASE-estimated tau-squared (same scale as input effect sizes, squared)}
#'     \item{tau2_dl}{DerSimonian-Laird tau-squared estimate}
#'     \item{weight}{Empirical Bayes data weight w (0 = full prior, 1 = full data)}
#'     \item{prior_mean}{Prior mean tau-squared from the Heterogeneity Atlas}
#'     \item{prior_var}{Prior variance of tau-squared from the Heterogeneity Atlas}
#'     \item{conflict_detected}{Logical: TRUE if prior-data conflict was detected (>2 SD)}
#'     \item{pooled_est}{Pooled effect estimate (weighted mean using ASE tau-squared)}
#'     \item{pooled_se}{Standard error of pooled estimate (HKSJ-adjusted if hksj=TRUE)}
#'     \item{pooled_ci_lb}{Lower bound of the confidence interval}
#'     \item{pooled_ci_ub}{Upper bound of the confidence interval}
#'     \item{pooled_pval}{Two-sided p-value for pooled effect}
#'     \item{I2}{I-squared statistic (percentage, 0-100), based on ASE tau-squared.
#'       Note: this may differ from metafor::rma()$I2 which uses the DL or REML tau-squared.}
#'   }
#' @importFrom metafor rma
#' @importFrom data.table fread
#' @importFrom stats qt pt qnorm pnorm
#' @export
#' @examples
#' yi <- c(0.5, 0.3, 0.8)
#' vi <- c(0.04, 0.06, 0.05)
#' result <- ASE(yi, vi, outcome_type = "binary", outcome_class = "objective")
#' result$tau2_ase

# --- Prior cache (loaded once, reused across calls) ---
.ase_prior_cache <- new.env(parent = emptyenv())

.load_priors <- function() {
  if (!is.null(.ase_prior_cache$data)) return(.ase_prior_cache$data)

  # Try package inst/extdata first
  priors_path <- system.file("extdata", "granular_priors.csv", package = "HeterogeneityASE")

  # Development fallback: relative paths from working directory
  if (!nzchar(priors_path) || !file.exists(priors_path)) {
    candidates <- c(
      "inst/extdata/granular_priors.csv",
      "../inst/extdata/granular_priors.csv",
      "R/../inst/extdata/granular_priors.csv"
    )
    for (cp in candidates) {
      cp_norm <- tryCatch(normalizePath(cp, mustWork = TRUE), error = function(e) "")
      if (nzchar(cp_norm)) { priors_path <- cp_norm; break }
    }
  }

  if (nzchar(priors_path) && file.exists(priors_path)) {
    .ase_prior_cache$data <- data.table::fread(priors_path, showProgress = FALSE)
  }
  .ase_prior_cache$data
}

.get_prior <- function(outcome_type, outcome_class) {
  p_df <- .load_priors()
  if (is.null(p_df)) return(list(mu = 0.1386, var = 0.2876))

  ot <- outcome_type; oc <- outcome_class
  prior_row <- p_df[p_df$outcome_type == ot & p_df$outcome_class == oc, ]
  if (nrow(prior_row) == 0) prior_row <- p_df[p_df$outcome_type == ot, ][1, ]
  if (nrow(prior_row) == 0 || is.na(prior_row$mean_tau2[1])) prior_row <- p_df[1, ]

  mu <- prior_row$mean_tau2[1]
  v <- prior_row$var_tau2[1]
  if (is.na(mu)) mu <- 0.1386
  if (is.na(v) || v <= 0) v <- 0.2876
  list(mu = mu, var = v)
}

ASE <- function(x, vi = NULL, outcome_type = "binary", outcome_class = "other",
                hksj = TRUE, conf.level = 0.95) {

  # --- Input validation ---
  outcome_type <- match.arg(outcome_type, c("binary", "continuous", "generic"))
  outcome_class <- match.arg(outcome_class, c("objective", "subjective", "other"))

  if (!is.logical(hksj) || length(hksj) != 1 || is.na(hksj)) {
    stop("hksj must be TRUE or FALSE.")
  }

  if (!is.numeric(conf.level) || conf.level <= 0 || conf.level >= 1) {
    stop("conf.level must be a number between 0 and 1.")
  }

  if (inherits(x, "rma")) {
    yi <- as.numeric(x$yi)
    vi <- as.numeric(x$vi)
  } else {
    yi <- x
    if (is.null(vi)) stop("vi must be provided if x is not an rma object.")
  }

  # Validate yi and vi
  if (!is.numeric(yi)) stop("yi must be a numeric vector.")
  if (!is.numeric(vi)) stop("vi must be a numeric vector.")
  if (any(is.na(yi)) || any(is.na(vi))) {
    stop("yi and vi must not contain NA values.")
  }
  if (any(!is.finite(yi))) {
    stop("yi must not contain Inf or NaN values.")
  }
  if (any(!is.finite(vi))) {
    stop("vi must not contain Inf or NaN values.")
  }
  if (any(vi <= 0)) {
    stop("vi must contain only positive values.")
  }
  if (length(yi) != length(vi)) {
    stop("yi and vi must have the same length.")
  }

  k <- length(yi)
  if (k < 2) {
    warning("ASE requires k >= 2 studies. Returning NULL.")
    return(NULL)
  }

  # --- Get prior from cache ---
  prior <- .get_prior(outcome_type, outcome_class)
  mu_prior <- prior$mu
  var_prior <- prior$var

  # --- Observed data estimation via DerSimonian-Laird ---
  res_dl <- tryCatch(metafor::rma(yi, vi, method = "DL"), error = function(e) {
    warning("DL estimation failed: ", conditionMessage(e))
    NULL
  })
  if (is.null(res_dl)) return(NULL)

  tau2_dl <- res_dl$tau2
  mean_vi <- mean(vi)

  # Approximate variance of the DL estimator.
  # Based on chi-squared variance relationship: Var(Q) ~ 2*(k-1) for Q ~ chi2(k-1),
  # combined with the method-of-moments mapping from Q to tau2_DL.
  # This is a simplified equal-variance approximation; see Discussion for caveats.
  var_tau2_dl <- (2 / (k - 1)) * (tau2_dl + mean_vi)^2

  # --- Empirical Bayes weight ---
  # w = var_prior / (var_tau2_dl + var_prior)
  # When var_tau2_dl small (large k) -> w -> 1 (trust data)
  # When var_tau2_dl large (small k) -> w -> 0 (trust prior)
  # Note: w is the DATA weight, opposite to some EB conventions where w denotes prior weight.
  w_base <- var_prior / (var_tau2_dl + var_prior)

  # --- Conflict-aware adjustment ---
  sd_prior <- sqrt(var_prior)
  conflict_mag <- abs(tau2_dl - mu_prior) / sd_prior

  if (conflict_mag > 2) {
    conflict_factor <- 1 - exp(-(conflict_mag - 2))
    w <- w_base + (1 - w_base) * conflict_factor
    conflict_detected <- TRUE
  } else {
    w <- w_base
    conflict_detected <- FALSE
  }

  # --- ASE tau-squared ---
  tau2_ase <- max(0, w * tau2_dl + (1 - w) * mu_prior)

  # --- Pooled effect estimation ---
  wi_re <- 1 / (vi + tau2_ase)
  pooled_est <- sum(wi_re * yi) / sum(wi_re)

  alpha <- 1 - conf.level

  if (hksj && k >= 2) {
    # Hartung-Knapp-Sidik-Jonkman adjustment
    q_hksj <- sum(wi_re * (yi - pooled_est)^2) / (k - 1)
    pooled_se <- sqrt(q_hksj / sum(wi_re))
    t_crit <- qt(1 - alpha / 2, df = k - 1)
    pooled_ci_lb <- pooled_est - t_crit * pooled_se
    pooled_ci_ub <- pooled_est + t_crit * pooled_se
    pooled_pval <- 2 * pt(-abs(pooled_est / pooled_se), df = k - 1)
  } else {
    pooled_se <- sqrt(1 / sum(wi_re))
    z_crit <- qnorm(1 - alpha / 2)
    pooled_ci_lb <- pooled_est - z_crit * pooled_se
    pooled_ci_ub <- pooled_est + z_crit * pooled_se
    pooled_pval <- 2 * pnorm(-abs(pooled_est / pooled_se))
  }

  # I2 using "typical" within-study variance (Higgins-Thompson).
  # Note: uses ASE tau2, so will differ from metafor::rma()$I2.
  w_fe <- 1 / vi
  typical_vi <- (k - 1) * sum(w_fe) / (sum(w_fe)^2 - sum(w_fe^2))
  I2 <- max(0, (tau2_ase / (tau2_ase + typical_vi)) * 100)

  return(list(
    k = k,
    tau2_ase = tau2_ase,
    tau2_dl = tau2_dl,
    weight = w,
    prior_mean = mu_prior,
    prior_var = var_prior,
    conflict_detected = conflict_detected,
    pooled_est = pooled_est,
    pooled_se = pooled_se,
    pooled_ci_lb = pooled_ci_lb,
    pooled_ci_ub = pooled_ci_ub,
    pooled_pval = pooled_pval,
    I2 = I2
  ))
}
