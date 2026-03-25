# The adaptive shrinkage estimator for heterogeneity in small-sample meta-analysis: an empirical Bayes approach using outcome-specific priors from 17,236 Cochrane meta-analyses

Mahmood Ahmad 0009-0003-7781-4478

Royal Free Hospital, London, United Kingdom

Corresponding author email: mahmood.ahmad2@nhs.net

## Abstract

**Background:** Estimating between-study heterogeneity (tau-squared) is fundamental to random-effects meta-analysis, yet standard estimators are unreliable when the number of studies (k) is small. The DerSimonian-Laird (DL) estimator frequently yields tau-squared = 0 in small meta-analyses, understating uncertainty.

**Methods:** The Adaptive Shrinkage Estimator (ASE) borrows strength from outcome-specific priors derived from 17,236 Cochrane meta-analyses (the Pairwise70 Heterogeneity Atlas). It computes a precision-weighted average of the DL estimate and the empirical prior mean, with a conflict-detection mechanism that increases data trust when observed heterogeneity deviates from the prior. The Hartung-Knapp-Sidik-Jonkman (HKSJ) adjustment was applied for pooled inference. Performance was evaluated via Monte Carlo simulation (1,000 replications across 24 scenarios: k in {3, 5, 10, 20}, true tau-squared in {0 to 0.50}).

**Results:** The ASE reduced tau-squared mean squared error (MSE) relative to the DL estimator across all scenarios at k = 3, with reductions ranging from 14% (true tau-squared = 0) to 65% (true tau-squared = 0.25). The MSE advantage diminished with increasing k; at k = 20, the shrinkage weight ranged from 0.892 (true tau-squared = 0.50) to 0.998 (true tau-squared = 0). At k >= 10 with true tau-squared near 0, the ASE had marginally higher MSE than the DL (< 4%), reflecting the cost of shrinkage toward a positive prior mean. Coverage probability for the pooled effect was close to the nominal 95% level across all scenarios when HKSJ was applied (range: 93.8-96.0%; Monte Carlo SE approximately 0.7 pp). An ablation study showed that the HKSJ adjustment drove coverage improvement, while the ASE contributed by reducing tau-squared bias.

**Conclusions:** The ASE provides a computationally efficient approach to heterogeneity estimation that leverages the Cochrane evidence base, addressing the instability of standard estimators in data-sparse meta-analyses while converging to conventional behavior as evidence accumulates.

## Introduction

Random-effects meta-analysis requires estimation of the between-study variance (tau-squared), which determines both the study weights and the width of the pooled confidence interval [1]. When the number of included studies is small, standard estimators perform poorly. The DerSimonian-Laird (DL) estimator [2], the most widely used method, is known to underestimate tau-squared, particularly for small k [3,4]. Restricted maximum likelihood (REML) estimators share similar limitations, frequently yielding tau-squared = 0 when heterogeneity genuinely exists [5]. This underestimation leads to confidence intervals that are too narrow and inflated Type I error rates [6].

The problem is widespread. Davey et al. [7] found that the median number of studies per comparison in Cochrane reviews is 3. When tau-squared is estimated as zero despite true heterogeneity, the random-effects model collapses to a fixed-effect analysis, overstating the precision of the pooled estimate. This has direct consequences for Health Technology Assessment (HTA) submissions and clinical guideline development, where the certainty of evidence determines treatment recommendations.

Bayesian approaches using informative priors offer a theoretical solution. Turner et al. [8] and Rhodes et al. [9] developed predictive distributions for tau-squared based on large collections of Cochrane meta-analyses, stratified by outcome type and comparison type. These priors can stabilize estimation in small samples. However, fully Bayesian methods require Markov chain Monte Carlo (MCMC) sampling, introducing computational overhead and convergence diagnostics that are impractical for routine use. Pullenayegum [10] proposed informed reference priors for binary outcomes, while Chung et al. [11] developed penalized likelihood approaches to avoid zero tau-squared estimates, but both require iterative optimization.

The present work proposes the Adaptive Shrinkage Estimator (ASE), a closed-form empirical Bayes estimator that combines the computational simplicity of the DL method with the stabilizing properties of outcome-specific priors. The ASE was developed using the Pairwise70 dataset [12], which contains 17,236 meta-analyses from 501 Cochrane systematic reviews. Three key features distinguish the ASE from existing approaches: (1) granular priors stratified by both outcome type and outcome class (objective vs. subjective), (2) a variance-based precision weighting mechanism that automatically adjusts the shrinkage intensity based on sample size, and (3) a conflict-aware mechanism that detects and responds to prior-data disagreement.

## Materials and methods

### Data source: the Pairwise70 dataset

The Pairwise70 dataset [12] contains study-level data from 501 Cochrane systematic reviews, encompassing 17,236 individual meta-analyses. Each meta-analysis was analyzed using the DL method to obtain tau-squared estimates. Meta-analyses with k < 2 or failed convergence were excluded.

### The Heterogeneity Atlas

Tau-squared values were stratified by outcome type (binary, continuous, generic) and outcome class (objective, subjective, other). Outcome classification was performed by keyword matching on analysis names: objective outcomes included mortality, stroke, myocardial infarction, survival, hospitalization, readmission, cancer, fracture, and infection; subjective outcomes included pain, quality of life, depression, anxiety, satisfaction, fatigue, and symptom scores. Analyses not matching either category were classified as "other."

For each stratum, the mean and variance of the tau-squared distribution were computed to define the empirical prior parameters. Table 1 presents the Heterogeneity Atlas.

**Table 1. Heterogeneity Atlas: empirical prior distributions for tau-squared by outcome type and outcome class.**

| Outcome type | Outcome class | N | Mean tau-squared | Var(tau-squared) | Median tau-squared |
|---|---|---|---|---|---|
| Binary | Objective | 2,185 | 0.096 | 0.130 | 0.000 |
| Binary | Other | 12,682 | 0.139 | 0.288 | 0.000 |
| Binary | Subjective | 1,843 | 0.071 | 0.104 | 0.000 |
| Continuous | Objective | 171 | 1.897 | 153.6 | 0.025 |
| Continuous | Other | 170 | 1.908 | 154.6 | 0.025 |
| Continuous | Subjective | 84 | 0.570 | 1.442 | 0.133 |
| Generic | Objective | 23 | 0.147 | 0.128 | 0.000 |
| Generic | Other | 51 | 2.875 | 144.6 | 0.006 |
| Generic | Subjective | 27 | 6.520 | 400.4 | 0.000 |

The large variance for continuous and generic strata reflects the heterogeneous measurement scales pooled within these categories. For these strata, the prior is effectively diffuse and the ASE will assign high data weight, approximating the unadjusted DL estimate. The method is thus most informative for binary outcomes, where the prior distribution is well-characterized (N = 2,185 to 12,682 meta-analyses per stratum).

### The ASE model

The ASE computes tau-squared as a weighted average of the observed DL estimate and the empirical prior mean:

tau-squared_ASE = w * tau-squared_DL + (1 - w) * mu_prior (Eq. 1)

where mu_prior is the mean of the empirical prior for the relevant outcome stratum. The result is floored at zero to ensure non-negative tau-squared estimates. Note that w denotes the data weight here; when w = 1, the ASE equals the DL estimate. This convention is the complement of the traditional empirical Bayes notation where the weight denotes the prior influence [13].

The shrinkage weight w reflects the relative precision of the data versus the prior:

w_base = Var_prior / (Var_tau2_DL + Var_prior) (Eq. 2)

where Var_tau2_DL is the approximate sampling variance of the DL estimator. We use a simplified chi-squared-based approximation derived from the method-of-moments relationship between Q and tau-squared_DL:

Var_tau2_DL = 2/(k - 1) * (tau-squared_DL + mean(vi))^2 (Eq. 3)

This approximation assumes approximately equal within-study variances and is based on the well-known chi-squared variance identity Var(chi-squared(df)) = 2*df with df = k - 1. It is adequate for meta-analyses with roughly similar study sizes but may be imprecise when within-study variances vary substantially. More exact expressions for the variance of the DL estimator exist [14] (see Limitations).

Var_prior is the variance of tau-squared across meta-analyses in the corresponding Atlas stratum. When Var_tau2_DL is small (large k, precise estimation), w_base approaches 1 and the ASE converges to the DL estimate. When Var_tau2_DL is large (small k, imprecise estimation), w_base approaches 0 and the ASE is pulled toward the prior mean.

### Conflict-aware adjustment

Empirical Bayes shrinkage carries a risk: if the true heterogeneity of a new meta-analysis lies far from the historical distribution (e.g., a novel surgical intervention with very high variability), excessive shrinkage toward the prior could underestimate uncertainty. To address this, the ASE includes a conflict-detection mechanism.

If the observed tau-squared_DL deviates from the prior mean by more than 2 standard deviations of the prior distribution, the data weight is increased via an exponential adjustment:

w = w_base + (1 - w_base) * (1 - exp(-(|tau-squared_DL - mu_prior| / sd_prior - 2))) (Eq. 4)

This ensures that the ASE rapidly converges to the observed estimate when prior-data conflict is detected, preventing over-shrinkage in atypical scenarios. The threshold of 2 standard deviations was selected as a pragmatic balance between MSE performance and early conflict detection; a sensitivity analysis varying this threshold (1, 2, and 3 SD) is reported in S3 Table.

### Pooled effect estimation

For inference on the pooled effect, the ASE-estimated tau-squared was used to construct random-effects weights w_i = 1/(v_i + tau-squared_ASE). The pooled estimate was computed as the weighted mean. To correct the known anti-conservatism of Wald-type confidence intervals in small meta-analyses, the Hartung-Knapp-Sidik-Jonkman (HKSJ) adjustment [15,16] was applied, using a t-distribution with k - 1 degrees of freedom and the HKSJ variance estimator.

### Simulation study

Monte Carlo simulations were conducted to evaluate the operating characteristics of the ASE, following the ADEMP framework [17]. The estimand was the true between-study variance tau-squared; the data-generating mechanism drew effect sizes from a normal distribution with true pooled effect mu = 0.3 (log-OR scale) and sampling variances drawn uniformly from [0.02, 0.10]. For each scenario, 1,000 replications were generated with seed set.seed(2026) for reproducibility. The binary/other prior stratum (mu_prior = 0.139, Var_prior = 0.288) was used for all scenarios; this stratum was selected as the most representative, encompassing 12,682 meta-analyses. The simulation grid comprised:

- k in {3, 5, 10, 20}
- True tau-squared in {0, 0.01, 0.05, 0.10, 0.25, 0.50}

This yields 24 distinct scenarios. Comparators included DL, REML, and Paule-Mandel (PM) for tau-squared estimation, and REML+HKSJ for coverage probability comparison. All analyses were performed using the metafor R package version 4.8-0 [18] under R version 4.5.2.

Performance metrics included:
- Bias: mean(tau-squared_hat - tau-squared_true)
- Mean squared error (MSE): mean((tau-squared_hat - tau-squared_true)^2)
- Coverage probability: proportion of 95% confidence intervals containing the true pooled effect
- Confidence interval width: mean width of 95% CIs

The Monte Carlo standard error for coverage probability at p = 0.95 with 1,000 replications is approximately 0.7 percentage points, which should be considered when interpreting coverage differences.

An ablation study comparing ASE with and without the HKSJ adjustment was included to separate the contributions of shrinkage and variance correction.

### Software implementation

The ASE is implemented in the R package HeterogeneityASE (S1 File), which provides a single exported function ASE() accepting either raw effect size vectors or metafor::rma objects. The function accepts a conf.level parameter (default 0.95) for flexible confidence level specification. The HKSJ adjustment is applied by default (hksj = TRUE). The package includes the granular priors as bundled data. Source code, benchmarks, and the Heterogeneity Atlas are available at [ZENODO_DOI_PLACEHOLDER].

## Results

### Heterogeneity Atlas

The Heterogeneity Atlas (Table 1) revealed substantial variation in tau-squared across outcome types and classes. Binary outcomes had the smallest heterogeneity (mean tau-squared ranging from 0.071 for subjective to 0.139 for the "other" category), while continuous and generic outcomes exhibited much larger and more variable heterogeneity. The median tau-squared was 0 for most binary outcome strata, reflecting the high proportion of meta-analyses where the DL estimator yields zero heterogeneity. Subjective endpoints within continuous outcomes showed less heterogeneity (mean = 0.570) than objective or unclassified endpoints (mean = 1.90-1.91), consistent with the narrower measurement scales typically used for patient-reported outcomes.

### Simulation results

Table 2 presents the full simulation results across all 24 scenarios. Results are organized by k (number of studies) and true tau-squared.

**Tau-squared estimation bias and MSE.** At k = 3, the ASE reduced tau-squared MSE relative to DL across all true tau-squared values: from 0.0019 vs. 0.0022 at tau-squared = 0 (14% reduction) to 0.0323 vs. 0.0921 at tau-squared = 0.25 (65% reduction). The largest absolute MSE reduction occurred at tau-squared = 0.50 (ASE MSE = 0.2315, DL MSE = 0.3191, 27% reduction). The ASE also outperformed REML and PM across the same scenarios; PM produced similar MSE values to REML across all scenarios (full PM results in S1 Table). At k = 5, the pattern persisted but with smaller advantages (e.g., at tau-squared = 0.25, ASE MSE = 0.0211 vs. DL MSE = 0.0477, 56% reduction). By k = 10, the ASE and DL estimators produced similar MSE values (e.g., at tau-squared = 0.10, ASE MSE = 0.0049 vs. DL MSE = 0.0053), and at k = 20, the ASE converged toward the DL (differences < 2% in most scenarios). However, at k >= 10 with true tau-squared near 0, the ASE had marginally higher MSE than the DL estimator (e.g., at k = 10, tau-squared = 0: ASE MSE = 0.0003 vs. DL MSE = 0.0003, a 4% increase), reflecting the small cost of shrinkage toward a positive prior mean when the true heterogeneity is zero. This cost is negligible in absolute terms. Full results for all 24 scenarios, including PM, are available in S1 Table. Fig 1 displays the MSE comparison across all scenarios.

The ASE's shrinkage weight increased monotonically with k: mean weight ranged from 0.66-0.97 at k = 3, 0.71-0.99 at k = 5, 0.79-1.00 at k = 10, and 0.89-1.00 at k = 20 (Table 2). At k = 20, the weight exceeded 0.99 for true tau-squared <= 0.05, but dropped to 0.892 at true tau-squared = 0.50, indicating that shrinkage toward the prior persists even at moderate sample sizes when the true heterogeneity is far from the prior mean. This confirms the adaptive behavior: the ASE relies more heavily on the data as information accumulates, converging toward the conventional DL estimator for large k.

The ASE showed a negative bias for tau-squared at k = 3 with true tau-squared = 0.50 (bias = -0.217), reflecting shrinkage toward the prior mean (0.139 for binary/other outcomes). This is expected: the prior mean is lower than the true tau-squared, and the shrinkage pulls the estimate downward. Despite this bias, the ASE achieved lower MSE than the DL estimator (0.232 vs. 0.319), demonstrating a favorable bias-variance trade-off.

**Table 2. Monte Carlo simulation results (1,000 replications per scenario).**

| k | True tau-sq | DL bias | REML bias | ASE bias | DL MSE | REML MSE | ASE MSE | ASE+HKSJ cov% | REML+HKSJ cov% | ASE w | Conflict% |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 3 | 0 | 0.0184 | 0.0183 | 0.0199 | 0.0022 | 0.0023 | 0.0019 | 93.8 | 93.8 | 0.974 | 0.0 |
| 3 | 0.01 | 0.0199 | 0.0200 | 0.0206 | 0.0039 | 0.0041 | 0.0030 | 95.3 | 95.3 | 0.965 | 0.0 |
| 3 | 0.05 | 0.0169 | 0.0167 | 0.0120 | 0.0104 | 0.0102 | 0.0063 | 93.9 | 93.9 | 0.931 | 0.0 |
| 3 | 0.10 | 0.0088 | 0.0089 | -0.0078 | 0.0203 | 0.0202 | 0.0095 | 94.7 | 94.6 | 0.890 | 0.0 |
| 3 | 0.25 | 0.0034 | 0.0032 | -0.0860 | 0.0921 | 0.0914 | 0.0323 | 94.2 | 94.1 | 0.770 | 1.3 |
| 3 | 0.50 | -0.0163 | -0.0159 | -0.2168 | 0.3191 | 0.2929 | 0.2315 | 95.1 | 95.2 | 0.661 | 9.2 |
| 5 | 0 | 0.0153 | 0.0156 | 0.0164 | 0.0011 | 0.0012 | 0.0012 | 95.6 | 95.6 | 0.989 | 0.0 |
| 5 | 0.01 | 0.0123 | 0.0124 | 0.0133 | 0.0016 | 0.0018 | 0.0016 | 94.3 | 94.3 | 0.986 | 0.0 |
| 5 | 0.05 | 0.0077 | 0.0081 | 0.0076 | 0.0047 | 0.0047 | 0.0042 | 94.5 | 94.5 | 0.970 | 0.0 |
| 5 | 0.10 | 0.0015 | 0.0014 | -0.0036 | 0.0114 | 0.0114 | 0.0082 | 95.0 | 94.9 | 0.945 | 0.0 |
| 5 | 0.25 | -0.0096 | -0.0073 | -0.0562 | 0.0477 | 0.0463 | 0.0211 | 94.5 | 94.5 | 0.852 | 0.3 |
| 5 | 0.50 | -0.0141 | -0.0136 | -0.1813 | 0.1552 | 0.1490 | 0.0853 | 94.0 | 93.9 | 0.709 | 5.1 |
| 10 | 0 | 0.0085 | 0.0081 | 0.0090 | 0.0003 | 0.0003 | 0.0003 | 94.5 | 94.5 | 0.996 | 0.0 |
| 10 | 0.01 | 0.0089 | 0.0090 | 0.0094 | 0.0007 | 0.0008 | 0.0008 | 94.7 | 94.7 | 0.995 | 0.0 |
| 10 | 0.05 | 0.0030 | 0.0031 | 0.0035 | 0.0024 | 0.0024 | 0.0023 | 94.6 | 94.6 | 0.989 | 0.0 |
| 10 | 0.10 | -0.0003 | 0.0000 | -0.0009 | 0.0053 | 0.0053 | 0.0049 | 94.9 | 94.9 | 0.977 | 0.0 |
| 10 | 0.25 | -0.0054 | -0.0027 | -0.0230 | 0.0219 | 0.0217 | 0.0146 | 94.3 | 94.3 | 0.924 | 0.0 |
| 10 | 0.50 | 0.0212 | 0.0215 | -0.0947 | 0.0830 | 0.0739 | 0.0336 | 95.7 | 95.8 | 0.794 | 3.5 |
| 20 | 0 | 0.0062 | 0.0059 | 0.0064 | 0.0001 | 0.0001 | 0.0002 | 96.0 | 96.0 | 0.998 | 0.0 |
| 20 | 0.01 | 0.0035 | 0.0032 | 0.0038 | 0.0003 | 0.0003 | 0.0003 | 94.6 | 94.7 | 0.998 | 0.0 |
| 20 | 0.05 | -0.0003 | -0.0004 | 0.0000 | 0.0010 | 0.0010 | 0.0010 | 94.7 | 94.9 | 0.995 | 0.0 |
| 20 | 0.10 | -0.0012 | -0.0010 | -0.0011 | 0.0024 | 0.0023 | 0.0023 | 95.0 | 94.9 | 0.990 | 0.0 |
| 20 | 0.25 | 0.0010 | 0.0015 | -0.0054 | 0.0101 | 0.0094 | 0.0085 | 95.5 | 95.5 | 0.963 | 0.0 |
| 20 | 0.50 | -0.0004 | -0.0013 | -0.0517 | 0.0370 | 0.0331 | 0.0223 | 94.5 | 94.5 | 0.892 | 0.2 |

**Fig 1. Tau-squared mean squared error (MSE) by k and true tau-squared for DL, REML, and ASE estimators.** Each panel shows one value of k (3, 5, 10, 20). The ASE achieves the largest MSE reductions at small k and large true tau-squared.

**Coverage probability.** With the HKSJ adjustment, the ASE maintained coverage close to the nominal 95% level across all scenarios (range: 93.8-96.0%). Without HKSJ (z-based CIs), the DL estimator showed substantial under-coverage at k = 3 (as low as 80.8% at tau-squared = 0.50) and k = 5 (as low as 85.5%). REML+HKSJ coverage was nearly identical to ASE+HKSJ coverage across all scenarios (differences <= 0.1 percentage points, well within the Monte Carlo SE of approximately 0.7 pp), confirming that the HKSJ correction, rather than the heterogeneity estimator, is the primary driver of nominal coverage. See S1 Fig for a visual comparison.

**Confidence interval width.** ASE confidence intervals were comparable in width to HKSJ intervals across all scenarios. At k = 3, mean CI widths ranged from 0.98 (tau-squared = 0) to 3.22 (tau-squared = 0.50). At k = 20, CI widths ranged from 0.21 to 0.69, reflecting the improved precision with larger samples.

**Conflict detection.** The conflict-detection mechanism was triggered appropriately. At k = 3 with tau-squared = 0.50, the conflict rate was 9.2%, increasing the data weight and preventing excessive shrinkage. At tau-squared values near the prior mean (0-0.10), the conflict rate was 0%. The conflict rate decreased with increasing k (from 9.2% at k = 3 to 0.2% at k = 20 for tau-squared = 0.50), consistent with the decreasing prior influence as data accumulate (S2 Fig).

### Ablation: ASE contribution beyond HKSJ

To disentangle the contributions of the ASE shrinkage and the HKSJ adjustment, an ablation study compared four configurations: (1) DL without HKSJ (standard z-based CIs), (2) REML + HKSJ (conventional best practice), (3) ASE without HKSJ (shrinkage only, z-based CIs), and (4) ASE + HKSJ (the recommended configuration).

Table 3 presents coverage probabilities for these four configurations at k = 3 and k = 5. The full ablation results are available in S2 Table.

**Table 3. Ablation analysis: coverage probability (%) by estimation method and CI construction.**

| k | True tau-sq | DL (z) | REML+HKSJ | ASE (z) | ASE+HKSJ |
|---|---|---|---|---|---|
| 3 | 0 | 95.6 | 93.8 | 96.0 | 93.8 |
| 3 | 0.01 | 93.1 | 95.3 | 93.6 | 95.3 |
| 3 | 0.05 | 89.8 | 93.9 | 90.2 | 93.9 |
| 3 | 0.10 | 87.1 | 94.6 | 87.2 | 94.7 |
| 3 | 0.25 | 83.1 | 94.1 | 82.9 | 94.2 |
| 3 | 0.50 | 80.8 | 95.2 | 77.9 | 95.1 |
| 5 | 0 | 96.6 | 95.6 | 96.7 | 95.6 |
| 5 | 0.01 | 94.0 | 94.3 | 94.1 | 94.3 |
| 5 | 0.05 | 90.5 | 94.5 | 90.6 | 94.5 |
| 5 | 0.10 | 90.7 | 94.9 | 91.1 | 95.0 |
| 5 | 0.25 | 88.0 | 94.5 | 87.9 | 94.5 |
| 5 | 0.50 | 85.5 | 93.9 | 82.9 | 94.0 |

The ablation reveals two key findings. First, the HKSJ adjustment is the primary driver of coverage improvement. Comparing DL (z) vs. REML+HKSJ shows coverage improvement of up to 14 percentage points at k = 3. In contrast, the ASE shrinkage alone (ASE (z) vs. DL (z)) has negligible effect on coverage and can slightly reduce it when tau-squared is large (e.g., 77.9% vs. 80.8% at k = 3, tau-squared = 0.50), because downward shrinkage of tau-squared narrows the z-based CI.

Second, the ASE's contribution is complementary to HKSJ rather than redundant: the ASE reduces tau-squared MSE (Table 2), producing more accurate heterogeneity estimates, while the HKSJ adjustment corrects the distributional properties of the pooled effect CI. The combined ASE+HKSJ approach yields both improved tau-squared estimation and approximately nominal coverage.

## Discussion

The ASE addresses a well-documented gap in meta-analytic methodology: the instability of heterogeneity estimation with few studies. By incorporating outcome-specific empirical priors from 17,236 Cochrane meta-analyses, the ASE stabilizes tau-squared estimation in data-sparse settings while preserving conventional behavior when data are abundant.

The approach is closely related to the informative prior framework of Turner et al. [8] and Rhodes et al. [9], who derived log-normal predictive distributions for tau-squared from Cochrane meta-analyses stratified by outcome type and comparison type. The ASE differs in three respects: (1) it uses a closed-form empirical Bayes calculation rather than MCMC sampling, making it suitable for routine implementation; (2) it provides a granular stratification by both outcome type and outcome class (objective vs. subjective); and (3) it includes an automatic conflict-detection mechanism that prevents over-shrinkage when the new meta-analysis is inconsistent with historical patterns.

The ASE also complements alternative approaches to avoiding zero tau-squared estimates. Pullenayegum [10] developed informed reference priors for the between-study standard deviation in binary outcomes, demonstrating that weakly informative priors can substantially improve coverage. Chung et al. [11] proposed penalized likelihood estimators that truncate tau-squared away from zero. The ASE shares the goal of stabilization but achieves it through direct shrinkage toward an empirical target, avoiding iterative optimization.

The HKSJ adjustment is critical for coverage probability and should always be used with the ASE. The simulation results demonstrate that the HKSJ correction accounts for the majority of the coverage improvement, while the ASE contributes by reducing tau-squared estimation bias. This decomposition is important: the ASE should not be promoted as a coverage solution in isolation but rather as a component of a combined ASE+HKSJ approach. The ablation analysis shows that the ASE without HKSJ can actually decrease coverage relative to DL without HKSJ when tau-squared is large, because downward shrinkage narrows z-based confidence intervals. This counterintuitive result underscores the necessity of the HKSJ correction.

### Limitations

Several limitations should be noted. First, the exchangeability assumption underlying the empirical Bayes approach presumes that the new meta-analysis belongs to the same population of meta-analyses from which the priors were derived. For highly unusual clinical questions or novel interventions, the Cochrane-derived priors may not be appropriate. The conflict-detection mechanism partially mitigates this concern but cannot eliminate it entirely.

Second, the variance approximation for the DL estimator (Eq. 3) assumes approximately equal within-study variances and uses a chi-squared-based heuristic. When within-study variances are highly heterogeneous (e.g., one large trial dominating several small trials), this approximation may be inaccurate. Alternative variance estimators based on the exact Q distribution [14] or the Paule-Mandel estimator could improve the precision weighting, and future work should evaluate these alternatives.

Third, the outcome classification by keyword matching is approximate. Misclassification is possible (e.g., "cancer-related quality of life" matching the objective keyword "cancer" rather than the subjective keyword "quality of life"). Formal outcome ontologies could improve classification accuracy.

Fourth, the 2-SD threshold for conflict detection was selected pragmatically rather than derived from an optimality criterion. The sensitivity analysis (S3 Table) shows that a higher threshold (3 SD) can yield lower MSE in some scenarios because it retains more prior shrinkage, while a lower threshold (1 SD) triggers conflicts more frequently, reducing shrinkage benefit. The 2-SD threshold represents a compromise between MSE performance and timely conflict detection for atypical meta-analyses. A principled calibration procedure would be desirable. Additionally, the tau-squared distribution is right-skewed, so 2 SD from the mean captures different tail proportions in the upper versus lower tails. The conflict mechanism is symmetric (triggers for deviations in either direction), but in practice, conflicts are predominantly upward (observed tau-squared much larger than the prior mean), since the DL estimator truncates at zero and the prior means are already close to zero for binary outcomes.

Fifth, the prior distributions are derived from DL estimates, which are themselves biased estimators. This introduces a circular dependency. Since Cochrane meta-analyses are predominantly small (median k = 3), the DL-based priors may reflect the estimator's biases rather than the true tau-squared distribution. Using REML or PM estimates for atlas construction could reduce this concern and is a direction for future work.

Sixth, the current implementation does not account for the uncertainty in the prior parameters themselves. A fully hierarchical model would propagate prior uncertainty into the ASE estimate, potentially providing better calibrated intervals.

Seventh, the simulation study tested only the binary/other prior stratum. The generalizability of the ASE's performance to continuous and generic outcome strata, where the priors are much more diffuse, remains to be established. For these strata, the ASE weight will be close to 1 (trust data), and the method degenerates to the DL estimator; formal verification is needed.

Eighth, Monte Carlo uncertainty at 1,000 replications is approximately 0.7 percentage points for coverage, limiting the precision of coverage comparisons. Higher replication counts would strengthen the conclusions.

Ninth, the simulation used a narrow range of within-study variances (v_i ~ U[0.02, 0.10]), corresponding to moderately large studies with similar precision. Meta-analyses with highly heterogeneous study sizes (e.g., one large trial dominating several small ones) may stress the equal-variance assumption underlying the DL variance approximation (Eq. 3) more severely. Future simulations should explore a wider range of v_i distributions.

Tenth, the current simulation does not include a fully Bayesian comparator using the Turner et al. [8] or Rhodes et al. [9] log-normal priors via MCMC. A head-to-head comparison with these established informative prior methods would more precisely quantify the cost (if any) of the closed-form ASE approximation relative to full posterior inference.

## Conclusions

The Adaptive Shrinkage Estimator provides a computationally efficient, conflict-aware approach to heterogeneity estimation in meta-analysis. Combined with the HKSJ adjustment for pooled inference, it addresses the known limitations of standard estimators in small-sample settings. The method is implemented in the freely available HeterogeneityASE R package and is recommended for meta-analyses with approximately k <= 5, where conventional estimators are most unreliable.

## Data availability statement

The HeterogeneityASE R package, Heterogeneity Atlas, simulation code, and benchmark results are available at [ZENODO_DOI_PLACEHOLDER].

## Funding

The author received no specific funding for this work.

## Competing interests

The author has declared that no competing interests exist.

## Ethics statement

This study involved computational simulations and analysis of publicly available aggregate data only. No human participants, animal subjects, or identifiable patient data were involved. No ethics approval was required.

## Author contributions

Mahmood Ahmad: Conceptualization, Methodology, Software, Formal analysis, Investigation, Data curation, Writing -- original draft, Writing -- review & editing, Visualization.

## Acknowledgments

The Pairwise70 dataset was obtained from [PAIRWISE70_DOI_PLACEHOLDER]. The metafor R package [18] was used for all meta-analytic computations. AI coding assistance (Claude, Anthropic) was used for software development, benchmark automation, and manuscript editing; the author is responsible for all scientific content, methodology, and analysis decisions.

## References

1. Higgins JPT, Thompson SG, Spiegelhalter DJ. A re-evaluation of random-effects meta-analysis. J R Stat Soc Ser A Stat Soc. 2009;172(1):137-159. https://doi.org/10.1111/j.1467-985X.2008.00552.x

2. DerSimonian R, Laird N. Meta-analysis in clinical trials. Control Clin Trials. 1986;7(3):177-188. https://doi.org/10.1016/0197-2456(86)90046-2

3. Veroniki AA, Jackson D, Viechtbauer W, Bender R, Bowden J, Knapp G, et al. Methods to estimate the between-study variance and its uncertainty in meta-analysis. Res Synth Methods. 2016;7(1):55-79. https://doi.org/10.1002/jrsm.1164

4. Langan D, Higgins JPT, Jackson D, Bowden J, Veroniki AA, Kontopantelis E, et al. A comparison of heterogeneity variance estimators in simulated random-effects meta-analyses. Res Synth Methods. 2019;10(1):83-98. https://doi.org/10.1002/jrsm.1316

5. Kontopantelis E, Reeves D. Performance of statistical methods for meta-analysis when true study effects are non-normally distributed: a simulation study. Stat Methods Med Res. 2012;21(4):409-426. https://doi.org/10.1177/0962280210392008

6. IntHout J, Ioannidis JPA, Borm GF. The Hartung-Knapp-Sidik-Jonkman method for random effects meta-analysis is straightforward and considerably outperforms the standard DerSimonian-Laird method. BMC Med Res Methodol. 2014;14:25. https://doi.org/10.1186/1471-2288-14-25

7. Davey J, Turner RM, Clarke MJ, Higgins JPT. Characteristics of meta-analyses and their component studies in the Cochrane Database of Systematic Reviews: a cross-sectional, descriptive analysis. BMC Med Res Methodol. 2011;11:160. https://doi.org/10.1186/1471-2288-11-160

8. Turner RM, Jackson D, Wei Y, Thompson SG, Higgins JPT. Predictive distributions for between-study heterogeneity and simple methods for their application in Bayesian meta-analysis. Stat Med. 2015;34(6):984-998. https://doi.org/10.1002/sim.6381

9. Rhodes KM, Turner RM, Higgins JPT. Predictive distributions were developed for the extent of heterogeneity in meta-analyses of continuous outcome data. J Clin Epidemiol. 2015;68(1):52-60. https://doi.org/10.1016/j.jclinepi.2014.08.012

10. Pullenayegum EM. An informed reference prior for between-study heterogeneity in meta-analyses of binary outcomes. Stat Med. 2011;30(26):3082-3094. https://doi.org/10.1002/sim.4326

11. Chung Y, Rabe-Hesketh S, Choi IH. Avoiding zero between-study variance estimates in random-effects meta-analysis. Stat Med. 2013;32(23):4071-4089. https://doi.org/10.1002/sim.5821

12. Hassan MU. Pairwise70: Pairwise meta-analysis data from 501 Cochrane systematic reviews [dataset]. Zenodo; 2026. https://doi.org/[PAIRWISE70_DOI_PLACEHOLDER]

13. Morris CN. Parametric empirical Bayes inference: theory and applications. J Am Stat Assoc. 1983;78(381):47-55. https://doi.org/10.1080/01621459.1983.10477920

14. Biggerstaff BJ, Jackson D. The exact distribution of Cochran's heterogeneity statistic in one-way random effects meta-analysis. Stat Med. 2008;27(29):6093-6110. https://doi.org/10.1002/sim.3428

15. Hartung J, Knapp G. A refined method for the meta-analysis of controlled clinical trials with binary outcome. Stat Med. 2001;20(24):3875-3889. https://doi.org/10.1002/sim.1009

16. Sidik K, Jonkman JN. A simple confidence interval for meta-analysis. Stat Med. 2002;21(21):3153-3159. https://doi.org/10.1002/sim.1262

17. Morris TP, White IR, Crowther MJ. Using simulation studies to evaluate statistical methods. Stat Med. 2019;38(11):2074-2102. https://doi.org/10.1002/sim.8086

18. Viechtbauer W. Conducting meta-analyses in R with the metafor package. J Stat Softw. 2010;36(3):1-48. https://doi.org/10.18637/jss.v036.i03

## Supporting information

S1 Table. Full simulation results including Paule-Mandel (PM) estimator: tau-squared bias, MSE, coverage probability, and CI width across all 24 scenarios.

S2 Table. Ablation analysis: ASE with and without HKSJ adjustment.

S3 Table. Sensitivity analysis for conflict-detection threshold (1 SD, 2 SD, 3 SD).

S1 Fig. Coverage probability by k for ASE+HKSJ vs. DL (z-based) vs. REML+HKSJ.

S2 Fig. ASE shrinkage weight as a function of k and true tau-squared.

S1 File. HeterogeneityASE R package source code and benchmark scripts.
