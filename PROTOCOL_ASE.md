# Research Protocol: The Adaptive Shrinkage Estimator (ASE)
**Project:** Developing a Next-Generation Heterogeneity Model for Meta-Analysis
**Data Source:** Pairwise70 (501 Cochrane Reviews)
**Goal:** Outperform REML and Paule-Mandel in small-k scenarios (k < 10).

---

## 1. The Problem: "The Zero-Heterogeneity Fallacy"
Standard heterogeneity estimators (DerSimonian-Laird, REML) are notoriously unreliable when the number of studies is small ($k < 10$).
-   **High Variance:** They fluctuate wildly.
-   **Negative Bias:** They often underestimate $	au^2$, sometimes collapsing to 0 even when heterogeneity exists.
-   **Consequence:** Confidence intervals are too narrow, leading to false positives (Type I errors).

## 2. The Solution: Adaptive Shrinkage (ASE)
We propose a **Data-Driven Empirical Bayes Estimator**. Instead of estimating $	au^2$ in a vacuum, we will:
1.  **Map the Landscape:** Use `Pairwise70` to build a "Heterogeneity Atlas" – distributions of $	au^2$ across medical specialties, outcome types, and intervention classes.
2.  **Learn Priors:** Train a Machine Learning model (Gamma Regression or Random Forest) to predict the *expected* heterogeneity ($\hat{	au}^2_{prior}$) based on meta-analysis characteristics (topic, sample size, outcome type).
3.  **Shrinkage:** Combine the observed REML estimate ($\hat{	au}^2_{REML}$) with the predicted prior ($\hat{	au}^2_{prior}$) using a weight $w$ that depends on the information content ($k$).
    $$ \hat{	au}^2_{ASE} = w \cdot \hat{	au}^2_{REML} + (1-w) \cdot \hat{	au}^2_{prior} $$
    *When $k$ is large, trust the data ($w 	o 1$). When $k$ is small, trust the prior ($w 	o 0$).*

## 3. Development Plan

### Phase 1: The Heterogeneity Atlas
-   Extract $	au^2$ and $I^2$ from all 4,424 meta-analyses in Pairwise70.
-   Analyze distributions by **Medical Domain** (e.g., Oncology vs. Psychiatry) and **Outcome** (Binary vs. Continuous).

### Phase 2: The "Prior" Prediction Model
-   Train a model to predict $	au^2$ using features available at the protocol stage.
-   Features: Domain, Intervention Type (Drug vs. Surgical), Outcome Type, Mean Sample Size.

### Phase 3: The Estimator Construction
-   Develop the mathematical shrinkage formula.
-   Implement the `ASE()` function in R.

### Phase 4: Benchmarking (The "Better Than All" Test)
-   **Simulation Study:** Compare ASE vs. REML, DL, SJ, and PM.
-   **Metrics:** Mean Squared Error (MSE), Bias, and Coverage Probability of the resulting pooled effect confidence intervals.

---
**Author:** Gemini CLI
**Date:** February 14, 2026
