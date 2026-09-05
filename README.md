# Temporal niche partitioning in the helminth community of *Kinosternon scorpioides*
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22349580.svg)](https://doi.org/10.5281/zenodo.22349580)

Analysis code for:

> Conga DF, Helen Costa J, Bejarano Alegre V, Magalhães Bezerra A, Maciel de Castro Cardoso Jaques A (2026). **Seasonal rainfall drives temporal niche partitioning in the helminth community of scorpion mud turtle (*Kinosternon scorpioides*) from Marajó Island.** *Journal of Helminthology*, 100, e15. https://doi.org/10.1017/S0022149X25101132

## What this repository contains

A reproducible R pipeline covering every statistical analysis and figure reported in the manuscript:

| Script | Purpose |
|---|---|
| `R/00_config.R` | Packages, file paths, colour palette |
| `R/01_data_loading_cleaning.R` | Reads the raw dataset, derives total load / infection status / richness |
| `R/02_descriptive_parasitology.R` | Prevalence, mean intensity, mean abundance (Bush et al. 1997) |
| `R/03_inferential_statistics.R` | Fisher's exact test, Mann-Whitney + FDR, negative binomial GLM (season effect on load) |
| `R/04_diversity_indices.R` | Species richness, Shannon and Simpson indices, dominance |
| `R/05_community_composition_permanova.R` | PERMANOVA on Bray-Curtis dissimilarity (community composition) |
| `R/06_coinfection_and_correlation.R` | Mono-/co-infection classification, richness-vs-load correlation |
| `R/07_figures.R` | All manuscript and supplementary figures (300 dpi PNG) |
| `run_all.R` | Runs the full pipeline end to end |
| `scripts/simulate_data.R` | Generates the bundled **simulated** demo dataset (see "Data availability" below) |

## Requirements

R >= 4.2. All required packages are listed and auto-installed by `R/00_config.R`:
`readxl, dplyr, tidyr, stringr, ggplot2, purrr, broom, janitor, MASS, emmeans, ggpubr, vegan, gridExtra`.
`scripts/simulate_data.R` additionally needs `writexl` (only required if you want to regenerate the demo dataset).

## Running the pipeline

```bash
git clone https://github.com/VanBejA/kinosternon-helminth-analysis.git
cd kinosternon-helminth-analysis
Rscript run_all.R
```

By default the script looks for the data at `data/KINOSTERNON_data.xlsx`. You can point it elsewhere without editing any code:

```bash
KISC_INPUT_XLSX=/path/to/your/data.xlsx Rscript run_all.R
```

## Data availability

**The dataset bundled with this repository (`data/KINOSTERNON_data_SIMULATED.xlsx`) is SIMULATED, not the original raw data.** It was generated with `scripts/simulate_data.R` to reproduce the published per-genus prevalence and mean-abundance values (Table 2 of the manuscript) so that anyone can run `run_all.R` end to end and see the pipeline work, without exposing the original records.

The original raw data are not bundled with this repository. *Kinosternon scorpioides* is subject to unregulated collection for the pet and bushmeat trade across parts of the Brazilian Amazon; to avoid facilitating targeting of the sampled populations, precise collection-site coordinates are withheld from public code/data releases. Original data are available from the corresponding author (D.F. Conga, david.conga@mamiraua.org.br) upon reasonable request, consistent with the manuscript's data availability statement. See `data/README.md` for the expected column layout so you can point the pipeline at your own (real or equivalent) dataset via `KISC_INPUT_XLSX`.

Because the simulated dataset matches only the aggregate genus-level prevalence/abundance and not the full covariance structure of the original data (e.g. exact co-infection patterns, the single high-burden outlier host, or the season-area confounding), **results from `run_all.R` on the simulated data will be qualitatively similar but not numerically identical** to the published Tables/Figures 2-8. The GLM result in `Table_GLM_coefficients.csv` and `Table_GLM_predictions.csv`, however, is expected to stay close to the published IRR given how the totals were constructed.

## Important methodological note

Collection site and season were not fully independent in the original sampling design (each site was visited in only one season), so `season` and `area` cannot be modelled together (see manuscript Discussion, "Limitations"). All models here use `season` alone, matching the published results.

## Authorship

This analysis pipeline (R code in this repository) was written by **Vanesa Bejarano Alegre**. The manuscript itself is co-authored by the five researchers listed above; please cite the paper (not just this repository) when referring to the study's scientific findings.

## Citation

If you use this code, please cite the paper above; if you build on the code itself, you can also cite this repository. A `CITATION.cff` file is included for GitHub's "Cite this repository" feature, with the paper's five authors under `preferred-citation` and the code authorship listed separately.

## License

Code released under the MIT License (see `LICENSE`), © Vanesa Bejarano Alegre. This licenses the *code* only; the manuscript text and figures remain © the authors / Cambridge University Press.
