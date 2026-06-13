# Rscript truth-recovery/test-truth-recovery.R   (exit 0 = all pass)
# Fast measured invariants for the ASE truth-recovery yardstick. Seeded; reduced
# nsim so it runs in ~1 min. Full grid in harness.R / REPORT.md.
suppressMessages(library(metafor)); suppressMessages(library(data.table))
this <- sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])
source(file.path(dirname(this), "..", "R", "ASE.R"))

NSIM <- 150; TRUE_MU <- 0.3; PRIOR_MEAN <- 0.096
gen <- function(k, t2, seed) { set.seed(seed); vi <- runif(k, 0.02, 0.20); list(yi = rnorm(k, TRUE_MU, sqrt(vi + t2)), vi = vi) }

measure <- function(k, t2) {
  aMSE <- dMSE <- c(); aCov <- dCov <- c(); aBias <- c()
  for (s in 1:NSIM) {
    d <- gen(k, t2, 2000 + s)
    fd <- tryCatch(rma(yi = d$yi, vi = d$vi, method = "DL"), error = function(e) NULL)
    fa <- tryCatch(ASE(d$yi, d$vi, outcome_type = "binary", outcome_class = "objective", hksj = TRUE), error = function(e) NULL)
    if (!is.null(fd)) { dMSE <- c(dMSE, (fd$tau2 - t2)^2); dCov <- c(dCov, fd$ci.lb <= TRUE_MU & fd$ci.ub >= TRUE_MU) }
    if (!is.null(fa)) { aMSE <- c(aMSE, (fa$tau2_ase - t2)^2); aCov <- c(aCov, fa$pooled_ci_lb <= TRUE_MU & fa$pooled_ci_ub >= TRUE_MU); aBias <- c(aBias, fa$tau2_ase - t2) }
  }
  list(aMSE = mean(aMSE), dMSE = mean(dMSE), aCov = mean(aCov), dCov = mean(dCov), aBias = mean(aBias))
}

ok <- TRUE
report <- function(name, cond, detail) { cat(sprintf("%-4s %s  %s\n", if (cond) "PASS" else "FAIL", name, detail)); if (!cond) ok <<- FALSE }

m <- measure(5, PRIOR_MEAN)   # prior-match
report("match: ASE tau2 MSE < DL (shrinkage helps)", m$aMSE < m$dMSE, sprintf("(ASE %.5f vs DL %.5f)", m$aMSE, m$dMSE))
report("match: ASE mu coverage >= DL (downstream payoff)", m$aCov >= m$dCov - 0.005, sprintf("(ASE %.3f vs DL %.3f)", m$aCov, m$dCov))

c <- measure(5, 0.5)          # prior-data conflict
report("conflict: ASE stays robust on coverage (>=0.90 and >= DL)", c$aCov > 0.90 && c$aCov >= c$dCov, sprintf("(ASE %.3f vs DL %.3f)", c$aCov, c$dCov))
report("conflict: ASE tau2 is biased LOW (honest -- shrinks toward prior)", c$aBias < -0.05, sprintf("(ASE tau2 bias %.4f)", c$aBias))

cat(if (ok) "\nAll measured invariants hold.\n" else "\nSOME INVARIANTS FAILED.\n")
quit(status = if (ok) 0 else 1)
