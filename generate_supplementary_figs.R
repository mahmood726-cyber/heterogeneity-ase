#!/usr/bin/env Rscript
################################################################################
# Generate S1 Fig (Coverage) and S2 Fig (Shrinkage Weight)
################################################################################

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

dat <- read.csv(file.path(script_dir, "output", "benchmark_results_v2.csv"),
                stringsAsFactors = FALSE)
out_dir <- file.path(script_dir, "output")

k_vals <- c(3, 5, 10, 20)
panel_labels <- c("A", "B", "C", "D")

# ============================================================================
# S1 Fig: Coverage probability
# ============================================================================

tiff(file.path(out_dir, "S1_Fig_Coverage.tiff"),
     width = 7.5, height = 6, units = "in", res = 300, compression = "lzw")
par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1))

for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]

  tau2_vals <- sub$true_tau2
  dl_cov <- sub$dl_coverage * 100
  hksj_cov <- sub$hksj_coverage * 100
  ase_cov <- sub$ase_coverage * 100

  y_range <- range(c(dl_cov, hksj_cov, ase_cov))
  y_min <- min(75, y_range[1] - 2)
  y_max <- max(100, y_range[2] + 1)

  plot(tau2_vals, dl_cov, type = "b", pch = 1, lty = 2, col = "grey50",
       xlab = expression("True " * tau^2),
       ylab = "Coverage probability (%)",
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(y_min, y_max),
       cex.lab = 1.1, cex.main = 1.2, cex.axis = 0.9, lwd = 1.5)

  lines(tau2_vals, hksj_cov, type = "b", pch = 2, lty = 3, col = "grey50", lwd = 1.5)
  lines(tau2_vals, ase_cov, type = "b", pch = 16, lty = 1, col = "black", lwd = 2)
  abline(h = 95, lty = 4, col = "darkgrey", lwd = 1)

  if (i == 1) {
    legend("bottomleft",
           legend = c("DL (z-based)", "REML+HKSJ", "ASE+HKSJ", "Nominal 95%"),
           pch = c(1, 2, 16, NA),
           lty = c(2, 3, 1, 4),
           col = c("grey50", "grey50", "black", "darkgrey"),
           lwd = c(1.5, 1.5, 2, 1),
           cex = 0.8, bg = "white")
  }
}

dev.off()
cat("S1 Fig saved to:", normalizePath(file.path(out_dir, "S1_Fig_Coverage.tiff")), "\n")

# ============================================================================
# S2 Fig: ASE shrinkage weight
# ============================================================================

tiff(file.path(out_dir, "S2_Fig_Weight.tiff"),
     width = 7.5, height = 6, units = "in", res = 300, compression = "lzw")
par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1))

for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]

  tau2_vals <- sub$true_tau2
  ase_w <- sub$ase_mean_weight

  plot(tau2_vals, ase_w, type = "b", pch = 16, lty = 1, col = "black",
       xlab = expression("True " * tau^2),
       ylab = "ASE data weight (w)",
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(0.5, 1.02),
       cex.lab = 1.1, cex.main = 1.2, cex.axis = 0.9, lwd = 2)

  abline(h = 1, lty = 4, col = "darkgrey", lwd = 1)
}

dev.off()
cat("S2 Fig saved to:", normalizePath(file.path(out_dir, "S2_Fig_Weight.tiff")), "\n")

# PNG previews
for (fig in c("S1_Fig_Coverage", "S2_Fig_Weight")) {
  tiff_path <- file.path(out_dir, paste0(fig, ".tiff"))
  png_path <- file.path(out_dir, paste0(fig, ".png"))

  # Re-read from TIFF is complex; just regenerate as PNG
}

# Quick PNG versions
png(file.path(out_dir, "S1_Fig_Coverage.png"),
    width = 7.5, height = 6, units = "in", res = 150)
par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1))
for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]
  tau2_vals <- sub$true_tau2
  dl_cov <- sub$dl_coverage * 100
  hksj_cov <- sub$hksj_coverage * 100
  ase_cov <- sub$ase_coverage * 100
  y_range <- range(c(dl_cov, hksj_cov, ase_cov))
  y_min <- min(75, y_range[1] - 2)
  y_max <- max(100, y_range[2] + 1)
  plot(tau2_vals, dl_cov, type = "b", pch = 1, lty = 2, col = "grey50",
       xlab = expression("True " * tau^2), ylab = "Coverage probability (%)",
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(y_min, y_max), cex.lab = 1.1, cex.main = 1.2, lwd = 1.5)
  lines(tau2_vals, hksj_cov, type = "b", pch = 2, lty = 3, col = "grey50", lwd = 1.5)
  lines(tau2_vals, ase_cov, type = "b", pch = 16, lty = 1, col = "black", lwd = 2)
  abline(h = 95, lty = 4, col = "darkgrey", lwd = 1)
  if (i == 1) {
    legend("bottomleft",
           legend = c("DL (z-based)", "REML+HKSJ", "ASE+HKSJ", "Nominal 95%"),
           pch = c(1, 2, 16, NA), lty = c(2, 3, 1, 4),
           col = c("grey50", "grey50", "black", "darkgrey"),
           lwd = c(1.5, 1.5, 2, 1), cex = 0.8, bg = "white")
  }
}
dev.off()

png(file.path(out_dir, "S2_Fig_Weight.png"),
    width = 7.5, height = 6, units = "in", res = 150)
par(mfrow = c(2, 2), mar = c(4.5, 4.5, 2.5, 1))
for (i in seq_along(k_vals)) {
  k <- k_vals[i]
  sub <- dat[dat$k == k, ]
  tau2_vals <- sub$true_tau2
  ase_w <- sub$ase_mean_weight
  plot(tau2_vals, ase_w, type = "b", pch = 16, lty = 1, col = "black",
       xlab = expression("True " * tau^2), ylab = "ASE data weight (w)",
       main = paste0(panel_labels[i], ") k = ", k),
       ylim = c(0.5, 1.02), cex.lab = 1.1, cex.main = 1.2, lwd = 2)
  abline(h = 1, lty = 4, col = "darkgrey", lwd = 1)
}
dev.off()

cat("PNG previews saved.\n")
