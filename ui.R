library(shiny)
library(r3dmol)
library(InteractiveComplexHeatmap)

ui <- fluidPage(
	mod_prep_heatmap_ui("heatmap"),
	InteractiveComplexHeatmapOutput("heatmap_int"),
	mod_similar_structures_ui("similar1")#,
	#dataTableOutput('tm_max_dt')
	
)