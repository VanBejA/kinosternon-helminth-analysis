################################################################################
# 05_community_composition_permanova.R
# ------------------------------------------------------------------------------
# Tests whether helminth ASSEMBLAGE STRUCTURE (i.e. relative species
# composition, not just richness or overall load) differs between seasons.
#
# Author: Vanesa Bejarano alegre
################################################################################


df_infected   <- df %>% filter(any_inf == 1)
comm_infected <- as.matrix(df_infected[, GENERA])

if (nrow(df_infected) >= 5) {
  permanova_result <- adonis2(
    comm_infected ~ season,
    data = df_infected,
    method = "bray",
    permutations = 999
  )

  cat("PERMANOVA (n =", nrow(df_infected), "infected hosts)\n")
  cat("  R2 =", round(permanova_result$R2[1], 4),
      " F =", round(permanova_result$F[1], 3),
      " p =", round(permanova_result$`Pr(>F)`[1], 4), "\n\n")

  write.csv(as.data.frame(permanova_result), file.path(OUT_DIR, "Table6_PERMANOVA.csv"))
} 
