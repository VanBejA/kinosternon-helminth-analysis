################################################################################
# 03_inferential_statistics.R
# ------------------------------------------------------------------------------
# Seasonal comparisons corresponding to the manuscript's "Statistical analysis"
# and "Seasonal patterns in infection parameters" sections:
#
#   1. Fisher's exact test on overall prevalence (Rainy vs Dry)
#   2. Mann-Whitney U test on total helminth load
#   3. Mann-Whitney U tests per genus, with Benjamini-Hochberg (FDR) correction
#   4. Negative binomial GLM (MASS::glm.nb) of total load ~ season
#
# IMPORTANT - study design note (see manuscript, Discussion/Limitations)
# 
# Author: Vanesa Bejarano Alegre
################################################################################


# ---- 1. Overall prevalence: Fisher's exact test ------------------------------

tab_prev     <- table(df$season, df$any_inf)
fisher_total <- fisher.test(tab_prev)
cat("  p =", round(fisher_total$p.value, 4),
    " OR =", round(fisher_total$estimate, 3),
    " 95% CI [", round(fisher_total$conf.int[1], 3), "-", round(fisher_total$conf.int[2], 3), "]\n\n")

# ---- 2. Total helminth load: Mann-Whitney U ---------------------------------


mw_total <- wilcox.test(total_load ~ season, data = df, exact = FALSE)


# ---- 3. Per-genus comparisons with FDR correction ---------------------------


mw_genus_list <- map(GENERA, ~ wilcox.test(df[[.x]] ~ df$season, exact = FALSE))
mw_table <- tibble(
  genus   = GENERA,
  W       = map_dbl(mw_genus_list, ~ unname(.x$statistic)),
  p_value = map_dbl(mw_genus_list, ~ .x$p.value)
) %>%
  mutate(
    p_adj_FDR   = p.adjust(p_value, method = "BH"),
    significant = if_else(p_adj_FDR < 0.05, "yes*", "no")
  )

write.csv(mw_table, file.path(OUT_DIR, "Table3_per_genus_tests.csv"), row.names = FALSE)
print(mw_table)


# ---- 4. Negative binomial GLM: total load ~ season --------------------------

m_nb <- glm.nb(total_load ~ season, data = df)
theta_value <- summary(m_nb)$theta

# Coefficients exponentiated to Incidence Rate Ratios (IRR)
nb_coefs <- tidy(m_nb, exponentiate = TRUE, conf.int = TRUE)
write.csv(nb_coefs, file.path(OUT_DIR, "Table_GLM_coefficients.csv"), row.names = FALSE)

dry_row      <- nb_coefs %>% filter(term == "seasonDry")
irr          <- dry_row$estimate
irr_low      <- dry_row$conf.low
irr_high     <- dry_row$conf.high
glm_p_value  <- dry_row$p.value
reduction_pct <- round((1 - irr) * 100, 0)

# Model-predicted mean load per season (used in Figures 2-3)
glm_predictions <- emmeans(m_nb, ~ season, type = "response") %>%
  as.data.frame() %>%
  rename(predicted_load = response, se = SE)

write.csv(glm_predictions, file.path(OUT_DIR, "Table_GLM_predictions.csv"), row.names = FALSE)


