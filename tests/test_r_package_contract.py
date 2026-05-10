import shutil
import subprocess
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[1]


def test_package_metadata_and_exports_are_present():
    description = (ROOT / "DESCRIPTION").read_text(encoding="utf-8")
    namespace = (ROOT / "NAMESPACE").read_text(encoding="utf-8")
    source = (ROOT / "R" / "ASE.R").read_text(encoding="utf-8")

    assert "Package: HeterogeneityASE" in description
    assert "Adaptive Shrinkage Estimator" in description
    assert "export(ASE)" in namespace
    assert "ASE <- function" in source
    assert "conflict_detected" in source


def test_testthat_suite_and_priors_are_wired():
    runner = (ROOT / "tests" / "testthat.R").read_text(encoding="utf-8")
    assert 'test_check("HeterogeneityASE")' in runner
    assert (ROOT / "tests" / "testthat" / "test-ase.R").exists()
    assert (ROOT / "inst" / "extdata" / "granular_priors.csv").exists()


def test_r_testthat_suite_passes_when_rscript_is_available():
    rscript = shutil.which("Rscript")
    if rscript is None:
        pytest.skip("Rscript is not installed in this environment")
    subprocess.run([rscript, "tests/testthat.R"], cwd=ROOT, check=True)
