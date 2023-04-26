library(tidyverse)
library(readr)
library(tibble)
library(arrow)
library(r3dmol)
library(here)
library(Rpdb)
library(bio3d)
library(magrittr)
library(BiocManager)
library(ComplexHeatmap)
library(InteractiveComplexHeatmap)


### Load helper functions
source("helper_funs.R", local = TRUE)
### Load and process data
source("load_and_process_data.R", local = TRUE)
### Load module for 3d alignment/visualization and similar structure lookup
source("modules/similar_structures_mod.R", local = TRUE)
### prep the heatmap
#source("prep_heatmap.R", local = TRUE)
### Load module for heatmap
source("modules/prep_heatmap_mod.R", local = TRUE)

tm_df = read_parquet("data/TM_data_full.parquet")
#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
#meta = read_parquet("data/kinase_meta_updated_2023_update.parquet")
meta = load_metadata()