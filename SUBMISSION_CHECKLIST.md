# PLOS ONE Submission Checklist -- HeterogeneityASE

Updated: 2026-03-24
Manuscript: `PLOS_ONE_Manuscript_ASE.md`
Package: `C:\Models\New_Heterogeneity_Model`

## Verification Status (automated checks)

- [x] **Tests**: 25/25 PASS (standalone `run_tests.R`) + 25/25 PASS (testthat `test_dir()`)
- [x] **Figures exist** (TIFF 300 dpi + PNG):
  - `output/Figure1_MSE_comparison.tiff` (82 KB, 2250x1800)
  - `output/S1_Fig_Coverage.tiff` (92 KB)
  - `output/S2_Fig_Weight.tiff` (77 KB)
- [x] **Supplementary tables exist**:
  - `output/S1_Table_Full_Results.csv` (24 data rows -- all 24 scenarios + header)
  - `output/S2_Table_Ablation.csv` (24 data rows)
  - `output/S3_Table_Sensitivity.csv` (12 data rows -- 3 thresholds x 4 k values)
- [x] **Benchmark results**: `output/benchmark_results_v2.csv` (24 scenarios)
- [x] **References**: 18 references, all cited in body, numbered sequentially [1]-[18]
- [x] **Abstract**: 289 words (PLOS ONE limit: 300)
- [x] **Required sections present**: Abstract, Introduction, Materials and methods, Results, Discussion, Conclusions, Data availability statement, Funding, Competing interests, Ethics statement, Author contributions, Acknowledgments, References, Supporting information
- [x] **Granular priors bundled**: `inst/extdata/granular_priors.csv` (9 strata)
- [x] **R package structure**: DESCRIPTION, NAMESPACE, R/ASE.R, man/, tests/

## Placeholders Requiring User Action

The following placeholders MUST be filled before submission:

### 1. Author Identity (3 placeholders in manuscript)

| Placeholder | Location | Action |
|---|---|---|
| `0009-0003-7781-4478` | Line 3 of manuscript | Replace with your ORCID (e.g., `0000-0001-2345-6789`) |
| `[CITY_COUNTRY_PLACEHOLDER]` | Line 5 of manuscript | Replace with your city, country (e.g., `London, United Kingdom`) |
| `mahmood.ahmad2@nhs.net` | Line 7 of manuscript | Replace with your email address |

### 2. Author Identity in DESCRIPTION (R package)

| Placeholder | Location | Action |
|---|---|---|
| `CORRESPONDING_mahmood.ahmad2@nhs.net` | `DESCRIPTION` line 7 | Replace with your email |
| `0009-0003-7781-4478` | `DESCRIPTION` line 9 | Replace with your ORCID |

### 3. Zenodo DOI (3 occurrences in manuscript)

| Placeholder | Location | Action |
|---|---|---|
| `[ZENODO_DOI_PLACEHOLDER]` | Line 112 (Software implementation) | Replace with Zenodo DOI after deposit |
| `[ZENODO_DOI_PLACEHOLDER]` | Line 232 (Data availability statement) | Replace with same Zenodo DOI |
| `[PAIRWISE70_DOI_PLACEHOLDER]` | Line 252 (Acknowledgments) | Replace with Pairwise70 dataset Zenodo DOI |
| `[PAIRWISE70_DOI_PLACEHOLDER]` | Line 278 (Reference [12]) | Replace with same Pairwise70 DOI |

## Steps to Submit

1. **Fill all placeholders** listed above (5 unique values needed: ORCID, email, city/country, Zenodo DOI, Pairwise70 DOI)
2. **Deposit on Zenodo**:
   - Create a Zenodo deposit containing the full R package (zip of this directory)
   - Include: R source, benchmark scripts, Heterogeneity Atlas CSV, figures, supplementary tables
   - Record the DOI and fill `[ZENODO_DOI_PLACEHOLDER]`
3. **Deposit Pairwise70 on Zenodo** (if not already done):
   - The Pairwise70 dataset from 501 Cochrane reviews
   - Record the DOI and fill `[PAIRWISE70_DOI_PLACEHOLDER]`
4. **Convert manuscript** to PLOS ONE submission format:
   - PLOS ONE accepts Word (.docx) or LaTeX
   - Figures must be uploaded separately as TIFF/EPS (300+ dpi) -- already generated
   - Supporting Information files (S1-S3 Tables, S1-S2 Figs) uploaded separately
5. **Upload to PLOS ONE Editorial Manager**:
   - Manuscript file (.docx or .tex)
   - Figure files (3 TIFF files from `output/`)
   - Supporting Information (3 CSV files + 2 TIFF files from `output/`)
   - S1 File: R package source code (zip)
   - Cover letter
6. **Complete PLOS ONE submission form**:
   - Data availability: Zenodo DOI
   - Funding: "The author received no specific funding for this work"
   - Competing interests: "The author has declared that no competing interests exist"
   - Ethics: Computational simulations only, no human participants

## Code Fixes Applied This Session

1. **R/ASE.R**: Added `../../inst/extdata/granular_priors.csv` to prior file search paths, fixing prior lookup when running from `tests/testthat/` directory via `test_dir()`
2. **tests/testthat/test-ase.R**: Improved ASE.R source resolution with 3-strategy fallback (sys.frame, getwd, parent directory traversal) so `testthat::test_dir()` works without package installation
