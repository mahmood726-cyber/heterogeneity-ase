# Truth-recovery yardstick — heterogeneity-ase (ASE)

**Verdict: STRONG VALIDATION + the missing downstream evidence + a prior-data-
conflict robustness result. ASE's Empirical-Bayes shrinkage toward the Atlas prior
genuinely improves τ² estimation AND pooled-effect CI coverage, and it stays
robust even when the true τ² is far from the prior (at the honest cost of a
downward-biased τ² under conflict).**

## Method
ASE shrinks the τ² estimate toward an outcome-specific prior from the Pairwise70
Heterogeneity Atlas, with a conflict guard. The repo's own benchmark measures τ²
MSE/coverage across true-τ² values; this harness adds the **prior-data-conflict**
stress test (the map-priors analog) and reports the **downstream μ-coverage**
payoff. Uses `binary/objective`, whose Atlas prior is informative (mean τ²≈0.096,
var≈0.13) so shrinkage bites. The app's own `ASE()` is run unchanged (now that R
loads `metafor`/`data.table` via the `.Renviron` `R_LIBS_USER` fix). 400 sims/cell.

## Results (binary/objective; true μ=0.3; Atlas prior mean τ²=0.096)

| k  | true τ² | regime    | τ² MSE ASE/DL/REML        | μ cov ASE/DL/REML       | τ² bias ASE/DL  | conflict flagged |
|----|---------|-----------|---------------------------|-------------------------|-----------------|------------------|
| 5  | 0.096   | MATCH     | **0.0076** /0.0218/0.0253 | **0.932**/0.895/0.892   | −0.008 / +0.017 | 0.002 |
| 5  | 0.500   | CONFLICT  | **0.211** /0.244/0.254    | **0.943**/0.865/0.868   | −0.158 / +0.015 | 0.202 |
| 15 | 0.096   | MATCH     | **0.0039**/0.0047/0.0047  | **0.953**/0.930/0.927   | +0.001 / +0.004 | 0.000 |
| 15 | 0.500   | CONFLICT  | **0.042** /0.063/0.049    | **0.953**/0.927/0.935   | −0.122 / +0.007 | 0.117 |

## Findings (all measured)
1. **VALIDATION — shrinkage improves τ² estimation.** When the true τ² matches the
   Atlas prior, ASE has up to **2.9× lower τ² MSE** than DL/REML (0.0076 vs 0.0218
   at k=5). The gain is largest at small k (where DL/REML are noisiest) and shrinks
   as k grows — exactly the right behaviour.
2. **The missing downstream evidence — better μ coverage.** ASE's better τ² plus
   its HKSJ adjustment give **better-calibrated pooled-effect CIs**: μ coverage
   0.93–0.95 vs DL/REML 0.87–0.93 (+3–4pp at k=5). The repo benchmarked τ² MSE;
   this shows the τ² improvement actually propagates to the quantity clinicians
   read (the effect CI).
3. **ROBUST under prior-data conflict.** When the true τ² (0.5) is ~5× the prior
   (0.096), ASE does **not** collapse: it keeps lower τ² MSE than DL and **better μ
   coverage** (0.94–0.95 vs DL 0.87–0.93). Honest nuance: under conflict ASE's τ²
   is **biased low** (bias −0.12 to −0.16 — it shrinks toward the low prior),
   whereas DL is near-unbiased; but the HKSJ adjustment compensates so the
   *coverage* (the metric that matters) stays high. The conflict guard fires on
   12–20% of conflict replications (≈0 under match), helping limit the damage.
4. **Honest structural note.** For **continuous** outcomes the Atlas prior is
   diffuse (var≈150), so ASE's data weight → 1 and **ASE ≡ DL** (no shrinkage). The
   benefit is specific to outcome types with informative priors (binary). Worth
   surfacing so users don't expect a shrinkage gain on continuous outcomes.

## Recommendation
Report the μ-coverage advantage (not just τ² MSE) as ASE's headline benefit; note
that under strong conflict the τ² point estimate is conservative-low (coverage is
preserved by HKSJ); and document that continuous-outcome priors are diffuse so ASE
reduces to DL there.

## What did NOT transfer / what DID
ASE *is* an Empirical-Bayes shrinkage estimator, so the calibration/conflict idea
behind SBC applies directly (measured here as coverage-under-known-truth + a
conflict stress). NPE/conformal machinery not needed. Engine run unchanged.

## Reproduce
```
Rscript truth-recovery/harness.R 400
Rscript truth-recovery/test-truth-recovery.R
```
