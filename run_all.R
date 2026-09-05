################################################################################
# run_all.R
# ------------------------------------------------------------------------------
# Master script - reproduces every table and figure reported in:
#
#   Conga DF, Helen Costa J, Bejarano Alegre V, Magalhaes Bezerra A,
#   Maciel de Castro Cardoso Jaques A (2026). Seasonal rainfall drives temporal
#   niche partitioning in the helminth community of scorpion mud turtle
#   (Kinosternon scorpioides) from Marajo Island. Journal of Helminthology,
#   100, e15. https://doi.org/10.1017/S0022149X25101132
#
# Author: Vanesa Bejarano Alegre
################################################################################

source("R/00_config.R")
source("R/01_data_loading_cleaning.R")
source("R/02_descriptive_parasitology.R")
source("R/03_inferential_statistics.R")
source("R/04_diversity_indices.R")
source("R/05_community_composition_permanova.R")
source("R/06_coinfection_and_correlation.R")
source("R/07_figures.R")

writeLines(capture.output(sessionInfo()), file.path(OUT_DIR, "session_info.txt"))


