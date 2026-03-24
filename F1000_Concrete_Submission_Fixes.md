# New Heterogeneity Model: concrete submission fixes

This file converts the multi-persona review into repository-side actions that should be checked before external submission of the F1000 software paper for `New_Heterogeneity_Model`.

## Detectable Local State
- Documentation files detected: `README.md`, `f1000_artifacts/tutorial_walkthrough.md`.
- Environment lock or container files detected: `environment.yml`.
- Package manifests detected: `DESCRIPTION`.
- Example data files detected: `f1000_artifacts/example_dataset.csv`.
- Validation artifacts detected: `f1000_artifacts/validation_summary.md`, `tests/testthat.R`.
- Detected public repository root: `https://github.com/mahmood726-cyber/heterogeneity-ase`.
- Detected public source snapshot: Fixed public commit snapshot available at `https://github.com/mahmood726-cyber/heterogeneity-ase/tree/8dfb16da14a463576131a1678860c49262dad892`.
- Detected public archive record: No project-specific DOI or Zenodo record URL was detected locally; archive registration pending.

## High-Priority Fixes
- Check that the manuscript's named example paths exist in the public archive and can be run without repository archaeology.
- Confirm that the cited repository root (`https://github.com/mahmood726-cyber/heterogeneity-ase`) resolves to the same fixed public source snapshot used for submission.
- Archive the tagged release and insert the Zenodo DOI or record URL once it has been minted; no project-specific archive DOI was detected locally.
- Reconfirm the quoted benchmark or validation sentence after the final rerun so the narrative text matches the shipped artifacts.

## Numeric Evidence Available To Quote
- `f1000_artifacts/validation_summary.md` reports Example dataset used for walkthrough: data\output\cleaned_rds\CD000028_pub4_data.rds.
- `data/output/advanced_model_summary.txt` reports Spline strongly better (delta AIC <= -10): 0.006332454.
- `data/output/extended_summary_2005.txt` reports prop_abs_delta_i2_le_10 prop_delta_tau2_gt0 median_delta_i2 mean_delta_i2.

## Manuscript Files To Keep In Sync
- `F1000_Software_Tool_Article.md`
- `F1000_Reviewer_Rerun_Manifest.md`
- `F1000_MultiPersona_Review.md`
- `F1000_Submission_Checklist_RealReview.md` where present
- README/tutorial files and the public repository release metadata
