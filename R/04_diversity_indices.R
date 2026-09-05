################################################################################
# 04_diversity_indices.R
# ------------------------------------------------------------------------------
# Host-level community diversity metrics: species richness, Shannon diversity
# (emphasises evenness) and Simpson's index (emphasises dominance), compared
# between seasons with Mann-Whitney U tests.
#
# Author: Vanesa Bejarano Alegre
################################################################################


comm_matrix <- as.matrix(df[, GENERA])

df <- df %>%
  mutate(
    shannon = diversity(comm_matrix, index = "shannon"),
    simpson = diversity(comm_matrix, index = "simpson")
  )

diversity_summary <- df %>%
  group_by(season) %>%
  summarise(
    n              = n(),
    richness_mean  = round(mean(riqueza), 2),
    richness_sd    = round(sd(riqueza), 2),
    shannon_mean   = round(mean(shannon), 3),
    shannon_sd     = round(sd(shannon), 3),
    simpson_mean   = round(mean(simpson), 3),
    simpson_sd     = round(sd(simpson), 3),
    .groups = "drop"
  )

write.csv(diversity_summary, file.path(OUT_DIR, "Table4_diversity_indices.csv"), row.names = FALSE)
print(diversity_summary)
cat("\n")

test_richness <- wilcox.test(riqueza ~ season, data = df, exact = FALSE)
test_shannon  <- wilcox.test(shannon ~ season, data = df, exact = FALSE)


# ---- Species dominance (relative contribution to total helminth count) -----

total_per_genus <- colSums(comm_matrix)
dominance_table <- data.frame(
  genus      = str_to_title(names(total_per_genus)),
  n_total    = total_per_genus,
  percentage = round(total_per_genus / sum(total_per_genus) * 100, 1)
) %>% arrange(desc(percentage))

write.csv(dominance_table, file.path(OUT_DIR, "Table5_species_dominance.csv"), row.names = FALSE)
