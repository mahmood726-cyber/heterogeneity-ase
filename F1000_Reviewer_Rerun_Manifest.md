# New Heterogeneity Model: reviewer rerun manifest

This manifest is the shortest reviewer-facing rerun path for the local software package. It lists the files that should be sufficient to recreate one worked example, inspect saved outputs, and verify that the manuscript claims remain bounded to what the repository actually demonstrates.

## Reviewer Entry Points
- Project directory: `C:\Models\New_Heterogeneity_Model`.
- Preferred documentation start points: `README.md`, `f1000_artifacts/tutorial_walkthrough.md`.
- Detected public repository root: `https://github.com/mahmood726-cyber/heterogeneity-ase`.
- Detected public source snapshot: Fixed public commit snapshot available at `https://github.com/mahmood726-cyber/heterogeneity-ase/tree/8dfb16da14a463576131a1678860c49262dad892`.
- Detected public archive record: No project-specific DOI or Zenodo record URL was detected locally; archive registration pending.
- Environment capture files: `environment.yml`.
- Validation/test artifacts: `f1000_artifacts/validation_summary.md`, `tests/testthat.R`.

## Worked Example Inputs
- Manuscript-named example paths: `PLOS_ONE_Manuscript_ASE.md` as the detailed method description; `PROTOCOL_ASE.md` for the design blueprint; `generate_supplementary_tables.R` for manuscript-linked tabulation; f1000_artifacts/example_dataset.csv.
- Auto-detected sample/example files: `f1000_artifacts/example_dataset.csv`.

## Expected Outputs To Inspect
- Adaptive tau-squared estimates for small meta-analyses.
- Simulation summaries of bias, MSE, and coverage.
- Supplementary tables supporting manuscript claims.

## Minimal Reviewer Rerun Sequence
- Start with the README/tutorial files listed below and keep the manuscript paths synchronized with the public archive.
- Create the local runtime from the detected environment capture files if available: `environment.yml`.
- Run at least one named example path from the manuscript and confirm that the generated outputs match the saved validation materials.
- Quote one concrete numeric result from the local validation snippets below when preparing the final software paper.

## Local Numeric Evidence Available
- `f1000_artifacts/validation_summary.md` reports Example dataset used for walkthrough: data\output\cleaned_rds\CD000028_pub4_data.rds.
- `data/output/advanced_model_summary.txt` reports Spline strongly better (delta AIC <= -10): 0.006332454.
- `data/output/extended_summary_2005.txt` reports prop_abs_delta_i2_le_10 prop_delta_tau2_gt0 median_delta_i2 mean_delta_i2.
