################################################################################
# 06_coinfection_and_correlation.R
# ------------------------------------------------------------------------------
# 1. Classifies hosts as uninfected / mono-infected / co-infected and compares
#    the frequency of each class between seasons.
# 2. Tests the relationship between helminth species richness and total
#    parasite burden (Spearman's rank correlation), used to discuss potential
#    facilitative interactions among species (see manuscript Discussion).
#
# Auhtor: Vanesa Bejarano Alegre
################################################################################



df <- df %>%
  mutate(
    infection_type = case_when(
      riqueza == 0 ~ "Uninfected",
      riqueza == 1 ~ "Monoinfection",
      riqueza >= 2 ~ "Coinfection"
    )
  )

coinfection_table <- df %>%
  group_by(season, infection_type) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = season, values_from = n, values_fill = 0)

write.csv(coinfection_table, file.path(OUT_DIR, "Table7_coinfection_frequencies.csv"), row.names = FALSE)


n_mono <- sum(df$riqueza == 1)
n_co   <- sum(df$riqueza >= 2)


# ---- Richness vs total load: Spearman correlation ---------------------------

cor_test <- cor.test(df$total_load, df$riqueza, method = "spearman")

