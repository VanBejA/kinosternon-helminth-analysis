################################################################################
# 00_config.R
# ------------------------------------------------------------------------------
# Study:   Seasonal rainfall drives temporal niche partitioning in the helminth
#          community of scorpion mud turtle (Kinosternon scorpioides) from
#          Marajo Island
# Journal: Journal of Helminthology, 100:e15 (2026)
# DOI:     10.1017/S0022149X25101132
#
# Purpose: Global configuration - packages, file paths, and the colour palette
#          used consistently across every figure in the manuscript.
#
#Author: Vanesa Bejarano Alegre / nov 2025
################################################################################

# ---- 1. Packages -------------------------------------------------------------

required_packages <- c(
  "readxl",    # read Excel input
  "dplyr",     # data wrangling
  "tidyr",     # reshaping
  "stringr",   # string handling
  "ggplot2",   # plotting
  "purrr",     # functional iteration
  "broom",     # tidy model output
  "janitor",   # clean_names()
  "MASS",      # glm.nb() - negative binomial GLM
  "emmeans",   # marginal means / predictions from the GLM
  "ggpubr",    # multi-panel figure arrangement
  "vegan",     # diversity indices, PERMANOVA
  "gridExtra"
)

installed <- rownames(installed.packages())
missing_pkgs <- setdiff(required_packages, installed)
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs)
}

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(ggplot2)
  library(purrr)
  library(broom)
  library(janitor)
  library(MASS)
  library(emmeans)
  library(ggpubr)
  library(vegan)
  library(gridExtra)
})

# dplyr::select()/filter() are masked by MASS - pin them explicitly
select <- dplyr::select
filter <- dplyr::filter

theme_set(theme_bw(base_size = 12))

# ---- 2. Paths ------------------------------------------------------------
# Edit these three lines to point to your local copy of the data.
# The repository ships without raw data; see data/README.md.

IN_XLSX <- Sys.getenv("KISC_INPUT_XLSX", unset = "data/KINOSTERNON_data_SIMULATED.xlsx")
SHEET   <- Sys.getenv("KISC_SHEET",      unset = "Hoja1")
OUT_DIR <- Sys.getenv("KISC_OUTPUT_DIR", unset = "outputs")

if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

# ---- 3. Colour palette (identical across all manuscript figures) -------------

# Helminth genera
cols_species <- c(
  "Serpinema"   = "#462255",  # dark purple  - dominant nematode
  "Spiroxys"    = "#aa4465",  # red/pink     - rainy-season specialist
  "Falcaustra"  = "#ffa69e",  # salmon       - no clear seasonal pattern
  "Nematophila" = "#93e1d8"   # turquoise    - dry-season digenean
)

# Season
cols_season <- c("Rainy" = "#17c3b2", "Dry" = "#ffcb77")

# Helminth genus columns expected in the raw data (lower case, snake_case)
GENERA <- c("serpinema", "falcaustra", "nematophila", "spiroxys")

