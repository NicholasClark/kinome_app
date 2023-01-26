library(shiny)
library(readr)
library(r3dmol)
library(InteractiveComplexHeatmap)

meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

ui <- fluidPage(

  mod_similar_structures_ui("similar1"),
	#textOutput("text1"),
	
	InteractiveComplexHeatmapOutput("heatmap"),
	#mod_heatmap_ui("heatmap1"),
	dataTableOutput('tm_max_dt')
)