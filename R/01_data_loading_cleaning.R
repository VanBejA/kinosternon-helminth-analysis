################################################################################
# 01_data_loading_cleaning.R
# ------------------------------------------------------------------------------
# Loads the raw parasitological dataset and derives the variables used
# throughout the analysis: total helminth load, infection status, and
# species richness per host.
#
#Author: Vanesa Bejarano Alegre
#
################################################################################

raw <- read_xlsx(IN_XLSX, sheet = SHEET) %>% clean_names()

# Detect the season column regardless of Portuguese/Spanish spelling
col_season_raw <- names(raw)[str_detect(names(raw), regex("estacao|estaci[oó]n|season", ignore_case = TRUE))][1]

df <- raw %>%
  mutate(
    across(all_of(GENERA), ~ suppressWarnings(as.integer(as.numeric(.)))),
    across(all_of(GENERA), ~ replace_na(., 0L))
  ) %>%
  mutate(
    season_raw = .data[[col_season_raw]] %>% as.character(),
    season_lc  = season_raw %>% str_to_lower() %>% str_trim(),
    season     = case_when(
      season_lc %in% c("chuva", "chuvosa", "chuvoso", "rainy", "lluvia", "lluvioso") ~ "Rainy",
      season_lc %in% c("seca", "dry", "seco") ~ "Dry",
      TRUE ~ str_to_title(season_lc)
    )
  ) %>%
  mutate(
    total_load = rowSums(across(all_of(GENERA))),
    any_inf    = as.integer(total_load > 0),
    riqueza    = rowSums(across(all_of(GENERA), ~ . > 0))
  )

