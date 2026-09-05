################################################################################
# scripts/simulate_data.R
# ------------------------------------------------------------------------------
# Generates a SYNTHETIC dataset reproducing the published per-genus prevalence
# and mean-abundance values (see targets table below), for demonstration and
# pipeline-testing purposes only. This is NOT the original raw data used in
# the manuscript.
#
# Run from the repository root:
#   Rscript scripts/simulate_data.R
#   
# Author: Vanesa Bejarano Alegre | 
################################################################################

suppressPackageStartupMessages({
  library(dplyr)
  library(writexl)
})

set.seed(20260101)

GENERA <- c("serpinema", "spiroxys", "falcaustra", "nematophila")

# season, n_hosts, genus, n_infected, total_count
# total_count = round(mean_abundance * n_hosts) -> reproduces published MA exactly
targets <- tribble(
  ~season, ~n_hosts, ~genus,        ~n_infected, ~total_count,
  "Rainy", 10,       "serpinema",   5,           32,   # prevalence 50%, MA 3.2
  "Rainy", 10,       "spiroxys",    4,           10,   # prevalence 40%, MA 1.0
  "Rainy", 10,       "falcaustra",  2,           4,    # prevalence 20%, MA 0.4
  "Rainy", 10,       "nematophila", 1,           1,    # prevalence 10%, MA 0.1
  "Dry",   20,       "serpinema",   4,           13,   # prevalence 20%, MA 0.65
  "Dry",   20,       "spiroxys",    0,           0,    # prevalence 0%,  MA 0
  "Dry",   20,       "falcaustra",  2,           3,    # prevalence 10%, MA 0.15
  "Dry",   20,       "nematophila", 10,          11    # prevalence 50%, MA 0.55
)

#' Distribute `total_count` parasites across `n_infected` of `n_hosts`,
#' using skewed weights so the distribution shows realistic aggregation
#' (a few heavily infected hosts, most with low counts).
distribute_counts <- function(n_hosts, n_infected, total_count) {
  counts <- rep(0L, n_hosts)
  if (n_infected == 0 || total_count == 0) return(counts)

  infected_idx <- sample.int(n_hosts, n_infected)
  base <- rep(1L, n_infected)
  remaining <- total_count - n_infected

  if (remaining > 0) {
    weights <- rexp(n_infected, rate = 1)^2
    weights <- weights / sum(weights)
    extra <- floor(weights * remaining)
    drift <- remaining - sum(extra)
    if (drift > 0) {
      top_idx <- order(-weights)[seq_len(drift)]
      extra[top_idx] <- extra[top_idx] + 1
    }
    base <- base + extra
  }

  counts[infected_idx] <- base
  counts
}

build_season <- function(season_name, n_hosts) {
  cols <- lapply(GENERA, function(g) {
    row <- targets %>% filter(season == season_name, genus == g)
    if (nrow(row) == 0) return(rep(0L, n_hosts))
    distribute_counts(n_hosts, row$n_infected, row$total_count)
  })
  names(cols) <- GENERA
  as_tibble(cols)
}

rainy <- build_season("Rainy", 10) %>%
  mutate(season = "Chuva", area = "Ponta de Pedras")

dry <- build_season("Dry", 20) %>%
  mutate(season = "Seca",
         area = c(rep("Cachoeira do Arari", 6), rep("Santa Cruz do Arari", 14)))

df <- bind_rows(rainy, dry) %>%
  mutate(
    any_inf = as.integer(rowSums(across(all_of(GENERA))) > 0),
    id      = sprintf("KISC_%02d", row_number())
  )

# Sex: overall 17 F / 13 M, slightly higher among infected hosts (illustrative,
# matches the published - non-significant - trend; not used by the analysis).
sex_pool <- sample(c(rep("F", 17), rep("M", 13)))
df <- df %>%
  arrange(desc(any_inf)) %>%
  mutate(sex = sort(sex_pool)) %>%
  select(id, sex, area, season, all_of(GENERA))

if (!dir.exists("data")) dir.create("data")
write_xlsx(list(Hoja1 = df), "data/KINOSTERNON_data_SIMULATED.xlsx")

