# HeterogeneityASE

## Installation
Use the dependency files in this directory (for example `requirements.txt`, `environment.yml`, `DESCRIPTION`, or equivalent project-specific files) to create a clean local environment before running analyses.
Document any package-version mismatch encountered during first run.

Adaptive Shrinkage Estimator for heterogeneity (tau-squared) in meta-analysis.

## Overview

The ASE uses outcome-specific empirical Bayes priors derived from 17,066 Cochrane meta-analyses to stabilize heterogeneity estimation in small-sample meta-analyses (k < 10). It combines the DerSimonian-Laird estimate with a conflict-aware shrinkage mechanism and the Hartung-Knapp-Sidik-Jonkman adjustment for pooled inference.

## Quick start

```r
# Install dependencies
install.packages(c("metafor", "data.table"))

# Source the ASE function
source("R/ASE.R")

# Example: 3-study meta-analysis
yi <- c(0.5, 0.3, 0.8)
vi <- c(0.04, 0.06, 0.05)
result <- ASE(yi, vi, outcome_type = "binary", outcome_class = "objective")

# Results
result$tau2_ase       # Shrinkage-stabilized tau-squared
result$tau2_dl        # Original DL estimate
result$weight         # Data weight (0 = full prior, 1 = full data)
result$pooled_est     # Pooled effect estimate
result$pooled_ci_lb   # 95% CI lower bound (HKSJ-adjusted)
result$pooled_ci_ub   # 95% CI upper bound
result$I2             # I-squared statistic
```

## Run benchmarks

```bash
Rscript benchmark_ase.R
# Runs 5,000 simulations across 24 scenarios (k x tau2 grid)
# Output: output/benchmark_results_v2.csv
```

## Run tests

```bash
Rscript run_tests.R
# Expected: 15/15 PASS
```

## File structure

| File | Description |
|------|-------------|
| `R/ASE.R` | Core ASE function (exported) |
| `inst/extdata/granular_priors.csv` | Heterogeneity Atlas (9 outcome strata) |
| `benchmark_ase.R` | Comprehensive simulation benchmark |
| `build_heterogeneity_atlas.R` | Prior generation from Pairwise70 data |
| `run_tests.R` | Unit test suite (15 tests) |
| `PLOS_ONE_Manuscript_ASE.md` | Manuscript for PLOS ONE |

## Requirements

- R >= 4.0
- metafor >= 4.0
- data.table >= 1.14

## Manuscript

Hassan MU. The adaptive shrinkage estimator for heterogeneity in small-sample meta-analysis: an empirical Bayes approach using outcome-specific priors from 17,066 Cochrane meta-analyses. [Manuscript in preparation for PLOS ONE].

## License

MIT
