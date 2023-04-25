library(shiny)
library(r3dmol)
library(InteractiveComplexHeatmap)

ui <- fluidPage(
	
	InteractiveComplexHeatmapOutput("heatmap"),
	mod_similar_structures_ui("similar1")#,
	#dataTableOutput('tm_max_dt')
	
)