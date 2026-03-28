Mahmood Ahmad
Tahir Heart Institute
author@example.com

Adaptive Shrinkage Estimator for Heterogeneity in Small-Sample Meta-Analysis

Can outcome-specific empirical priors from the Cochrane evidence base stabilize heterogeneity estimation in small meta-analyses? The Adaptive Shrinkage Estimator draws on outcome-stratified priors derived from 17,236 Cochrane meta-analyses in the Pairwise70 Heterogeneity Atlas, spanning nine strata defined by outcome type and objectivity classification. ASE computes a precision-weighted average of the DerSimonian-Laird estimate and the empirical prior mean, with conflict-aware detection mechanism that increases data trust when observed heterogeneity deviates from the prior. Simulation across 24 scenarios showed ASE reduced median tau-squared MSE by 14 to 65 percent at k equals 3 (95% CI coverage 93.8 to 96.0 percent) under Hartung-Knapp-Sidik-Jonkman adjustment. Ablation confirmed that HKSJ drove coverage gains while ASE independently reduced tau-squared bias. The method converges to standard DerSimonian-Laird as k grows, with shrinkage weight exceeding 0.99 at k equals 20 and true tau-squared near zero. However, a limitation is that the variance approximation may be imprecise when within-study variances differ substantially across included studies.

Outside Notes

Type: methods
Primary estimand: Tau-squared MSE reduction
App: HeterogeneityASE R package v0.3.0
Data: Pairwise70 Heterogeneity Atlas (17,236 Cochrane meta-analyses)
Code: https://github.com/mahmood726-cyber/heterogeneity-ase
Version: 0.3.0
Validation: DRAFT

References

1. Borenstein M, Hedges LV, Higgins JPT, Rothstein HR. Introduction to Meta-Analysis. 2nd ed. Wiley; 2021.
2. Higgins JPT, Thompson SG, Deeks JJ, Altman DG. Measuring inconsistency in meta-analyses. BMJ. 2003;327(7414):557-560.
3. Cochrane Handbook for Systematic Reviews of Interventions. Version 6.4. Cochrane; 2023.

AI Disclosure

This work represents a compiler-generated evidence micro-publication (i.e., a structured, pipeline-based synthesis output). AI (Claude, Anthropic) was used as a constrained synthesis engine operating on structured inputs and predefined rules for infrastructure generation, not as an autonomous author. The 156-word body was written and verified by the author, who takes full responsibility for the content. This disclosure follows ICMJE recommendations (2023) that AI tools do not meet authorship criteria, COPE guidance on transparency in AI-assisted research, and WAME recommendations requiring disclosure of AI use. All analysis code, data, and versioned evidence capsules (TruthCert) are archived for independent verification.
