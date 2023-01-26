library(shiny)
library(readr)
library(r3dmol)
library(InteractiveComplexHeatmap)

meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

ui <- fluidPage(

	### Dropdown boxes for alignment
	selectInput("kinase_align1", label = "Kinase 1", choices = meta$symbol_nice, selected = "ABL1"),
	selectInput("kinase_align2", label = "Kinase 2", choices = meta$symbol_nice, selected = "AKT1"),
	
	
	#textOutput("text1"),
	#dataTableOutput('tm_max_dt'),
	#dataTableOutput('similar_dt'),
	uiOutput("ui_text"),
	InteractiveComplexHeatmapOutput("heatmap"),
	#mod_heatmap_ui("heatmap1"),
	r3dmolOutput("align_3d")
)