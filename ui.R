library(shiny)
library(r3dmol)
library(InteractiveComplexHeatmap)

ui <- fluidPage(

	mod_similar_structures_ui("similar1"),
	InteractiveComplexHeatmapOutput("heatmap"),
	dataTableOutput('tm_max_dt')
	
)