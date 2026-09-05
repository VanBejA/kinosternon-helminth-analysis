################################################################################
# 07_figures.R
# ------------------------------------------------------------------------------
# Generates all publication-ready figures (300 dpi PNG) used in the manuscript
# and its supplementary material.
#
#Author:Vanesa Bejarano Alegre
################################################################################


theme_manuscript <- function() {
  theme_bw(base_size = 14) +
    theme(
      plot.title       = element_text(hjust = 0.5, face = "bold", size = 16),
      axis.title       = element_text(face = "bold", size = 14),
      axis.text        = element_text(size = 12, color = "black"),
      panel.grid.major = element_line(color = "gray90"),
      panel.grid.minor = element_blank(),
      panel.border     = element_rect(color = "black", linewidth = 1)
    )
}

# ---- Figure 1: Temporal niche partitioning (prevalence + abundance panel) ---
# Reproduces the manuscript's main Figure 1: prevalence (top) and mean
# abundance (bottom) for each genus, split by season.

prevalence_long <- map_dfr(GENERA, function(g) {
  df %>%
    mutate(any_g = as.integer(.data[[g]] > 0)) %>%
    group_by(season) %>%
    summarise(prevalence_pct = 100 * mean(any_g), .groups = "drop") %>%
    mutate(genus = str_to_title(g))
})

abundance_long <- map_dfr(GENERA, function(g) {
  df %>%
    group_by(season) %>%
    summarise(mean_abundance = mean(.data[[g]]), .groups = "drop") %>%
    mutate(genus = str_to_title(g))
})

fig1_top <- ggplot(prevalence_long, aes(x = season, y = prevalence_pct, fill = genus)) +
  geom_col(position = "dodge", color = "black", linewidth = 0.4) +
  geom_text(aes(label = sprintf("%.0f%%", prevalence_pct)),
            position = position_dodge(width = 0.9), vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_fill_manual(values = cols_species, name = "Helminth genus") +
  labs(x = NULL, y = "Prevalence (%)") +
  theme_manuscript()

fig1_bottom <- ggplot(abundance_long, aes(x = season, y = mean_abundance, fill = genus)) +
  geom_col(position = "dodge", color = "black", linewidth = 0.4) +
  geom_text(aes(label = sprintf("%.2f", mean_abundance)),
            position = position_dodge(width = 0.9), vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_fill_manual(values = cols_species, guide = "none") +
  labs(x = "Season", y = "Mean abundance") +
  theme_manuscript()

fig1 <- ggarrange(fig1_top, fig1_bottom, ncol = 1, nrow = 2, heights = c(1, 1),
                   common.legend = TRUE, legend = "right")
ggsave(file.path(OUT_DIR, "Fig1_temporal_niche_partitioning.png"), fig1, width = 9, height = 9, dpi = 300)


# ---- Figure 2: GLM predicted mean helminth load (barplot with 95% CI) ------

fig2 <- ggplot(glm_predictions, aes(x = season, y = predicted_load, fill = season)) +
  geom_col(color = "black", linewidth = 1, width = 0.6) +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL), width = 0.15, linewidth = 1) +
  geom_text(aes(label = paste0(round(predicted_load, 2), " +/- ", round(se, 2))),
            vjust = -0.6, size = 5, fontface = "bold") +
  scale_fill_manual(values = cols_season) +
  labs(x = "Season", y = "Predicted mean helminth load") +
  theme_manuscript() +
  theme(legend.position = "none") +
  ylim(0, max(glm_predictions$predicted_load + glm_predictions$se) * 1.4) +
  annotate("text", x = 1.5, y = max(glm_predictions$predicted_load) * 1.3,
           label = sprintf("IRR = %.2f\np = %.3f\ntheta = %.2f", irr, glm_p_value, theta_value),
           size = 4.5, fontface = "bold")

ggsave(file.path(OUT_DIR, "Fig2_GLM_predicted_load.png"), fig2, width = 6, height = 6, dpi = 300)


# ---- Figure 3: Observed total helminth load (boxplot + jitter) -------------

fig3 <- ggplot(df, aes(x = season, y = total_load, fill = season)) +
  geom_jitter(width = 0.15, alpha = 0.4, size = 2) +
  geom_boxplot(outlier.shape = NA, width = 0.5, alpha = 0.8, color = "black", linewidth = 0.7) +
  scale_fill_manual(values = cols_season) +
  labs(x = "Season", y = "Total helminth load") +
  theme_manuscript() +
  theme(legend.position = "none") +
  annotate("text", x = 1.5, y = max(df$total_load) * 0.95,
           label = sprintf("IRR = %.2f, 95%% CI [%.2f-%.2f]\np = %.3f", irr, irr_low, irr_high, glm_p_value),
           size = 4)

ggsave(file.path(OUT_DIR, "Fig3_observed_load_boxplot.png"), fig3, width = 6, height = 6, dpi = 300)


# ---- Supplementary Fig S1: Shannon diversity by season ----------------------

figS1 <- ggplot(df, aes(x = season, y = shannon, fill = season)) +
  geom_jitter(width = 0.15, alpha = 0.4, size = 2) +
  geom_boxplot(outlier.shape = NA, width = 0.5, alpha = 0.8, color = "black", linewidth = 0.7) +
  scale_fill_manual(values = cols_season) +
  labs(x = "Season", y = "Shannon diversity index") +
  theme_manuscript() +
  theme(legend.position = "none") +
  annotate("text", x = 1.5, y = max(df$shannon) * 0.95,
           label = paste0("p = ", round(test_shannon$p.value, 3)), size = 4)

ggsave(file.path(OUT_DIR, "FigS1_shannon_diversity.png"), figS1, width = 6, height = 5, dpi = 300)


# ---- Supplementary Fig S2: Species richness by season ----------------------

figS2 <- ggplot(df, aes(x = season, y = riqueza, fill = season)) +
  geom_jitter(width = 0.15, height = 0.1, alpha = 0.4, size = 2) +
  geom_boxplot(outlier.shape = NA, width = 0.5, alpha = 0.8, color = "black", linewidth = 0.7) +
  scale_fill_manual(values = cols_season) +
  scale_y_continuous(breaks = 0:max(df$riqueza)) +
  labs(x = "Season", y = "Helminth species richness") +
  theme_manuscript() +
  theme(legend.position = "none") +
  annotate("text", x = 1.5, y = max(df$riqueza) * 0.95,
           label = paste0("p = ", round(test_richness$p.value, 3)), size = 4)

ggsave(file.path(OUT_DIR, "FigS2_species_richness.png"), figS2, width = 6, height = 5, dpi = 300)


# ---- Supplementary Fig S3: Per-genus abundance panel (2x2) ------------------

genus_plots <- map2(GENERA, str_to_title(GENERA), function(g, g_cap) {
  p_val  <- mw_table %>% filter(genus == g) %>% pull(p_adj_FDR)
  p_text <- if_else(p_val < 0.05, paste0("p = ", sprintf("%.4f", p_val), " *"), paste0("p = ", sprintf("%.3f", p_val)))

  ggplot(df, aes(x = season, y = .data[[g]])) +
    geom_jitter(width = 0.15, alpha = 0.4, size = 2, color = cols_species[g_cap]) +
    geom_boxplot(outlier.shape = NA, width = 0.5, alpha = 0.7,
                 fill = cols_species[g_cap], color = "black", linewidth = 0.6) +
    labs(x = "Season", y = paste0(g_cap, " abundance"), title = g_cap) +
    theme_bw(base_size = 12) +
    theme(
      plot.title       = element_text(hjust = 0.5, face = "bold", size = 13),
      panel.grid.minor = element_blank(),
      axis.title       = element_text(face = "bold", size = 10)
    ) +
    annotate("text", x = 1.5, y = max(df[[g]]) * 0.85, label = p_text, size = 3.2)
})

figS3 <- ggarrange(plotlist = genus_plots, ncol = 2, nrow = 2)
ggsave(file.path(OUT_DIR, "FigS3_abundance_by_genus.png"), figS3, width = 10, height = 8, dpi = 300)


# ---- Supplementary Fig S4: Richness vs total load correlation --------------

figS4 <- ggplot(df, aes(x = riqueza, y = total_load, color = season)) +
  geom_point(size = 3.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1.2) +
  scale_color_manual(values = cols_season, name = "Season") +
  labs(x = "Helminth species richness", y = "Total helminth load") +
  theme_manuscript() +
  annotate("text", x = max(df$riqueza) * 0.65, y = max(df$total_load) * 0.95,
           label = paste0("Spearman rho = ", round(cor_test$estimate, 3),
                           "\np = ", sprintf("%.4f", cor_test$p.value)),
           size = 4.5, fontface = "bold")

ggsave(file.path(OUT_DIR, "FigS4_richness_vs_load.png"), figS4, width = 8, height = 6, dpi = 300)

