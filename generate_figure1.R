#!/usr/bin/env Rscript
################################################################################
# Generate Figure 1: Tau-squared MSE comparison (4-panel)
#
# Produces a publication-quality 4-panel figure for PLOS ONE submission.
# Each panel = one value of k (3, 5, 10, 20).
# Lines: DL, REML, ASE
################################################################################

# Determine script directory
script_dir <- tryCatch(
  dirname(sys.frame(1)$ofile),
  error = function(e) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) > 0) {
      dirname(normalizePath(sub("^--file=", "", file_arg[1])))
    } else {
      getwd()
    }
  }
)

# Read benchmark results
csv_path <- file.path(script_dir, "output", "benchmark_results_v2.csv")
dat <- read.csv(csv_path, stringsAsFactors = FALSE)

# Output path
out_dir <- file.path(script_dir, "output")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

fig_path <- file.path(out_dir, "Figure1_MSE_comparison.tiff")

# PLOS ONE requires TIFF, 300 dpi minimum, width 5.2" (single col) or 7.5" (full page)
tiff(fig_path, width = 7.5, height = 6, units = "in", res = 300, compression = "lzw")

par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1), oma = c(0, 0, 0, 0))

k_vals <- c(3, 5, 10, 20)
panel_labels <- c("A", "B", "C", "D")

for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]

  tau2_vals <- sub$true_tau2
  dl_mse <- sub$dl_mse
  reml_mse <- sub$reml_mse
  ase_mse <- sub$ase_mse

  y_max <- max(c(dl_mse, reml_mse, ase_mse)) * 1.1

  plot(tau2_vals, dl_mse, type = "b", pch = 1, lty = 2, col = "grey50",
       xlab = expression("True " * tau^2),
       ylab = expression("MSE of " * hat(tau)^2),
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(0, y_max),
       cex.lab = 1.1, cex.main = 1.2, cex.axis = 0.9,
       lwd = 1.5)

  lines(tau2_vals, reml_mse, type = "b", pch = 2, lty = 3, col = "grey50", lwd = 1.5)
  lines(tau2_vals, ase_mse, type = "b", pch = 16, lty = 1, col = "black", lwd = 2)

  if (i == 1) {
    legend("topleft",
           legend = c("DL", "REML", "ASE"),
           pch = c(1, 2, 16),
           lty = c(2, 3, 1),
           col = c("grey50", "grey50", "black"),
           lwd = c(1.5, 1.5, 2),
           cex = 0.9, bg = "white")
  }
}

dev.off()

cat("Figure 1 saved to:", normalizePath(fig_path), "\n")

# Also generate PNG for quick preview
png_path <- file.path(out_dir, "Figure1_MSE_comparison.png")
png(png_path, width = 7.5, height = 6, units = "in", res = 150)

par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1), oma = c(0, 0, 0, 0))

for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]

  tau2_vals <- sub$true_tau2
  dl_mse <- sub$dl_mse
  reml_mse <- sub$reml_mse
  ase_mse <- sub$ase_mse

  y_max <- max(c(dl_mse, reml_mse, ase_mse)) * 1.1

  plot(tau2_vals, dl_mse, type = "b", pch = 1, lty = 2, col = "grey50",
       xlab = expression("True " * tau^2),
       ylab = expression("MSE of " * hat(tau)^2),
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(0, y_max),
       cex.lab = 1.1, cex.main = 1.2, cex.axis = 0.9,
       lwd = 1.5)

  lines(tau2_vals, reml_mse, type = "b", pch = 2, lty = 3, col = "grey50", lwd = 1.5)
  lines(tau2_vals, ase_mse, type = "b", pch = 16, lty = 1, col = "black", lwd = 2)

  if (i == 1) {
    legend("topleft",
           legend = c("DL", "REML", "ASE"),
           pch = c(1, 2, 16),
           lty = c(2, 3, 1),
           col = c("grey50", "grey50", "black"),
           lwd = c(1.5, 1.5, 2),
           cex = 0.9, bg = "white")
  }
}

dev.off()

cat("PNG preview saved to:", normalizePath(png_path), "\n")
