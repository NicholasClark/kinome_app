


server <- function(input, output, session) {
	
	#### TM-max matrix/data table output
	output$tm_max_dt = renderDataTable(tm_max_data())
	
	### Module w/ code for 3d structure alignment/visualization and similar structure lookup
	callModule(mod_similar_structures_server, id = "similar1")
	
	### Heatmap output
	makeInteractiveComplexHeatmap(input, output, session, Heatmap(tm_max_mat) %>% draw(), "heatmap")
	
}
