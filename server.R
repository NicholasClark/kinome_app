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

### define helper functions
source("helper_funs.R")


server <- function(input, output, session) {
  source("load_data.R")
	
	
	#### TM-max matrix/data table output
	output$tm_max_dt = renderDataTable(tm_max_data())
	
	callModule(mod_similar_structures_server, id = "similar1")
	
	#tm_max_mat_react = reactive(tm_max_mat)
	
	#callModule(mod_heatmap_server, id = "heatmap1", ht = Heatmap(tm_max_mat[1:20,1:20]))
	
	makeInteractiveComplexHeatmap(input, output, session, Heatmap(tm_max_mat[1:20,1:20]) %>% draw(), "heatmap")
}
