# New Heterogeneity Model: a software tool for reviewer-auditable evidence synthesis

## Authors
- Mahmood Ahmad [1,2]
- Niraj Kumar [1]
- Bilaal Dar [3]
- Laiba Khan [1]
- Andrew Woo [4]
- Corresponding author: Andrew Woo (andy2709w@gmail.com)

## Affiliations
1. Royal Free Hospital
2. Tahir Heart Institute Rabwah
3. King's College Medical School
4. St George's Medical School

## Abstract
**Background:** Small meta-analyses provide weak information about between-study variance, yet heterogeneity estimators strongly influence pooled intervals and interpretation. Reviewers expect a heterogeneity software paper to show exactly where empirical priors help and where they can over-shrink.

**Methods:** This project implements an adaptive shrinkage estimator that borrows from a Pairwise70 heterogeneity atlas, combines data-driven and prior information about tau-squared, and pairs the estimate with HKSJ-style pooled inference and supporting reproducibility scripts.

**Results:** The local repository contains the methods manuscript, atlas-building scripts, supplementary-table generators, and submission artifacts documenting simulation performance and scope conditions for the estimator.

**Conclusions:** The software should be described as a pragmatic small-k heterogeneity aid with explicit caveats about shrinkage cost when the true heterogeneity is near zero or when prior mismatch is substantial.

## Keywords
heterogeneity; adaptive shrinkage; between-study variance; Pairwise70 atlas; software tool

## Introduction
The estimator is motivated by a common software-review problem: manuscripts propose new tau-squared estimators but do not ship the atlas, scripts, or validation path needed for reviewers to see how the prior was built and how the pooled results change under shrinkage.

The key comparison is against DerSimonian-Laird and related heterogeneity estimators, not against every downstream evidence-synthesis tool. The paper therefore focuses on where shrinkage reduces mean squared error and where it does not.

The manuscript structure below is deliberately aligned to common open-software review requests: the rationale is stated explicitly, at least one runnable example path is named, local validation artifacts are listed, and conclusions are bounded to the functions and outputs documented in the repository.

## Methods
### Software architecture and workflow
Core project files include `build_heterogeneity_atlas.R`, `generate_supplementary_tables.R`, the project manuscript, and reviewer-facing submission materials. The estimator combines empirical-prior construction with pooled-inference scripts.

### Installation, runtime, and reviewer reruns
The local implementation is packaged under `C:\Models\New_Heterogeneity_Model`. The manuscript identifies the local entry points, dependency manifest, fixed example input, and expected saved outputs so that reviewers can rerun the documented workflow without reconstructing it from scratch.

- Entry directory: `C:\Models\New_Heterogeneity_Model`.
- Detected documentation entry points: `README.md`, `f1000_artifacts/tutorial_walkthrough.md`.
- Detected environment capture or packaging files: `environment.yml`.
- Named worked-example paths in this draft: `PLOS_ONE_Manuscript_ASE.md` as the detailed method description; `PROTOCOL_ASE.md` for the design blueprint; `generate_supplementary_tables.R` for manuscript-linked tabulation.
- Detected validation or regression artifacts: `f1000_artifacts/validation_summary.md`, `tests/testthat.R`.
- Detected example or sample data files: `f1000_artifacts/example_dataset.csv`.

### Worked examples and validation materials
**Example or fixed demonstration paths**
- `PLOS_ONE_Manuscript_ASE.md` as the detailed method description.
- `PROTOCOL_ASE.md` for the design blueprint.
- `generate_supplementary_tables.R` for manuscript-linked tabulation.

**Validation and reporting artifacts**
- `F1000_Submission_Checklist_RealReview.md` and project manuscript materials.
- Saved simulation tables and supplementary outputs described in the manuscript.
- Atlas-building code that makes the empirical prior reproducible.

### Typical outputs and user-facing deliverables
- Adaptive tau-squared estimates for small meta-analyses.
- Simulation summaries of bias, MSE, and coverage.
- Supplementary tables supporting manuscript claims.

### Reviewer-informed safeguards
- Provides a named example workflow or fixed demonstration path.
- Documents local validation artifacts rather than relying on unsupported claims.
- Positions the software against existing tools without claiming blanket superiority.
- States limitations and interpretation boundaries in the manuscript itself.
- Requires explicit environment capture and public example accessibility in the released archive.

## Review-Driven Revisions
This draft has been tightened against recurring open peer-review objections taken from the supplied reviewer reports.
- Reproducibility: the draft names a reviewer rerun path and points readers to validation artifacts instead of assuming interface availability is proof of correctness.
- Validation: claims are anchored to local tests, validation summaries, simulations, or consistency checks rather than to unsupported assertions of performance.
- Comparators and niche: the manuscript now names the relevant comparison class and keeps the claimed niche bounded instead of implying universal superiority.
- Documentation and interpretation: the text expects a worked example, input transparency, and reviewer-verifiable outputs rather than a high-level feature list alone.
- Claims discipline: conclusions are moderated to the documented scope of New Heterogeneity Model and paired with explicit limitations.

## Use Cases and Results
The software outputs should be described in terms of concrete reviewer-verifiable workflows: running the packaged example, inspecting the generated results, and checking that the reported interpretation matches the saved local artifacts. In this project, the most important result layer is the availability of a transparent execution path from input to analysis output.

Representative local result: `f1000_artifacts/validation_summary.md` reports Example dataset used for walkthrough: data\output\cleaned_rds\CD000028_pub4_data.rds.

### Concrete local quantitative evidence
- `f1000_artifacts/validation_summary.md` reports Example dataset used for walkthrough: data\output\cleaned_rds\CD000028_pub4_data.rds.
- `data/output/advanced_model_summary.txt` reports Spline strongly better (delta AIC <= -10): 0.006332454.
- `data/output/extended_summary_2005.txt` reports prop_abs_delta_i2_le_10 prop_delta_tau2_gt0 median_delta_i2 mean_delta_i2.

## Discussion
Representative local result: `f1000_artifacts/validation_summary.md` reports Example dataset used for walkthrough: data\output\cleaned_rds\CD000028_pub4_data.rds.

The strongest reviewer-aligned framing is to present the method as a small-sample heterogeneity assistant. It improves stability in sparse settings but necessarily trades off some efficiency when the observed data are already sufficiently informative.

### Limitations
- The method depends on the relevance of the empirical heterogeneity atlas to the target review.
- Shrinkage can be mildly harmful when the true heterogeneity is close to zero and k is large.
- The contribution is a tau-estimation strategy, not a comprehensive evidence-synthesis platform.

## Software Availability
- Local source package: `New_Heterogeneity_Model` under `C:\Models`.
- Public repository: `https://github.com/mahmood726-cyber/heterogeneity-ase`.
- Public source snapshot: Fixed public commit snapshot available at `https://github.com/mahmood726-cyber/heterogeneity-ase/tree/8dfb16da14a463576131a1678860c49262dad892`.
- DOI/archive record: No project-specific DOI or Zenodo record URL was detected locally; archive registration pending.
- Environment capture detected locally: `environment.yml`.
- Reviewer-facing documentation detected locally: `README.md`, `f1000_artifacts/tutorial_walkthrough.md`.
- Reproducibility walkthrough: `f1000_artifacts/tutorial_walkthrough.md` where present.
- Validation summary: `f1000_artifacts/validation_summary.md` where present.
- Reviewer rerun manifest: `F1000_Reviewer_Rerun_Manifest.md`.
- Multi-persona review memo: `F1000_MultiPersona_Review.md`.
- Concrete submission-fix note: `F1000_Concrete_Submission_Fixes.md`.
- License: see the local `LICENSE` file.

## Data Availability
The project includes the atlas-building code, manuscript materials, and supplementary-table generators locally. Source review data derive from public Pairwise70 records.

## Reporting Checklist
Real-peer-review-aligned checklist: `F1000_Submission_Checklist_RealReview.md`.
Reviewer rerun companion: `F1000_Reviewer_Rerun_Manifest.md`.
Companion reviewer-response artifact: `F1000_MultiPersona_Review.md`.
Project-level concrete fix list: `F1000_Concrete_Submission_Fixes.md`.

## Declarations
### Competing interests
The authors declare that no competing interests were disclosed.

### Grant information
No specific grant was declared for this manuscript draft.

### Author contributions (CRediT)
| Author | CRediT roles |
|---|---|
| Mahmood Ahmad | Conceptualization; Software; Validation; Data curation; Writing - original draft; Writing - review and editing |
| Niraj Kumar | Conceptualization |
| Bilaal Dar | Conceptualization |
| Laiba Khan | Conceptualization |
| Andrew Woo | Conceptualization |

### Acknowledgements
The authors acknowledge contributors to open statistical methods, reproducible research software, and reviewer-led software quality improvement.

## References
1. DerSimonian R, Laird N. Meta-analysis in clinical trials. Controlled Clinical Trials. 1986;7(3):177-188.
2. Higgins JPT, Thompson SG. Quantifying heterogeneity in a meta-analysis. Statistics in Medicine. 2002;21(11):1539-1558.
3. Viechtbauer W. Conducting meta-analyses in R with the metafor package. Journal of Statistical Software. 2010;36(3):1-48.
4. Page MJ, McKenzie JE, Bossuyt PM, et al. The PRISMA 2020 statement: an updated guideline for reporting systematic reviews. BMJ. 2021;372:n71.
5. Fay C, Rochette S, Guyader V, Girard C. Engineering Production-Grade Shiny Apps. Chapman and Hall/CRC. 2022.
