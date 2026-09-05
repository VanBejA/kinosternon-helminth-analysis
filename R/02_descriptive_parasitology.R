################################################################################
# 02_descriptive_parasitology.R
# ------------------------------------------------------------------------------
# Standard parasitological parameters following Bush et al. (1997):
#   - Prevalence (P%)       : proportion of hosts infected
#   - Mean Abundance (MA)   : mean parasites per host EXAMINED (includes zeros)
#   - Mean Intensity (MI)   : mean parasites per host INFECTED (excludes zeros)
#
# Author: Vanesa Bejarano Alegre
################################################################################

prevalence <- function(x) mean(x > 0, na.rm = TRUE)
abundance  <- function(x) mean(x, na.rm = TRUE)
intensity  <- function(x) {
  infected <- x[x > 0]
  if (length(infected) == 0) return(0)
  mean(infected, na.rm = TRUE)
}

summarize_parasite <- function(data, var, by = "season") {
  data %>%
    group_by(across(all_of(by))) %>%
    summarise(
      n           = n(),
      prevalence  = prevalence(.data[[var]]),
      abundance   = abundance(.data[[var]]),
      intensity   = intensity(.data[[var]]),
      .groups = "drop"
    ) %>%
    mutate(prevalence_pct = round(100 * prevalence, 1)) %>%
    select(all_of(by), n, prevalence_pct, abundance, intensity)
}

# ---- Table 1: overall infection metrics by season ---------------------------

table1_overall <- df %>%
  group_by(season) %>%
  summarise(
    n              = n(),
    n_infected     = sum(any_inf),
    prevalence_pct = round(100 * mean(any_inf), 1),
    mean_load      = round(mean(total_load), 2),
    sd_load        = round(sd(total_load), 2),
    median_load    = median(total_load),
    .groups = "drop"
  )

write.csv(table1_overall, file.path(OUT_DIR, "Table1_overall_infection_parameters.csv"), row.names = FALSE)

# ---- Table 2: per-species prevalence/intensity/abundance --------------------

species_lookup <- c(
  serpinema   = "Serpinema pelliculatus",
  spiroxys    = "Spiroxys figueiredoi",
  falcaustra  = "Falcaustra sanjuanensis",
  nematophila = "Nematophila grandis"
)

table2_by_species <- map_dfr(GENERA, ~ summarize_parasite(df, .x) %>%
  mutate(
    group   = if_else(.x == "nematophila", "Digenea", "Nematoda"),
    species = species_lookup[[.x]],
    genus   = str_to_title(.x)
  )) %>%
  select(group, species, genus, season, prevalence_pct, intensity, abundance) %>%
  arrange(group, species, season) %>%
  rename(Season = season, `P (%)` = prevalence_pct, MI = intensity, MA = abundance)

write.csv(table2_by_species, file.path(OUT_DIR, "Table2_species_infection_parameters.csv"), row.names = FALSE)

