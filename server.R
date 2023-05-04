


server <- function(input, output, session) {
	
	rv = reactiveValues(hm = NULL, breaks = NULL, distance_metric = NULL)
	#### TM-max matrix/data table output
	output$tm_max_dt = renderDataTable(tm_max_data())

	### Module w/ code for 3d structure alignment/visualization and similar structure lookup
	callModule(mod_similar_structures_server, id = "similar1")
	
	### Heatmap output
	#callModule(mod_prep_heatmap_server, id = "heatmap")
	heatmap_server("heatmap", rv = rv)
	
	observe({
		makeInteractiveComplexHeatmap(input, output, session, rv$hm() %>% draw(), "heatmap_int")
	})
	
}
