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
