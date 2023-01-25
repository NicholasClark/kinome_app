### Heatmap module

mod_heatmap_ui <- function(id) {
	ns <- NS(id)
	InteractiveComplexHeatmapOutput(ns("heatmap"))
	### example ui code
	# tagList(sidebarLayout(
	# 	# Sidebar with a slider input
	# 	sidebarPanel(
	# 		width = 3,
	# 		h2("Row filters"),
	# 		mod_filters_ui("filters_ui_1", open = TRUE)
	# 	),
	# 	mainPanel(
	# 		width = 9,
	# 		div(id = ns("n_columns_text")),
	# 		DT::DTOutput(ns("kinometable"), width = "90%"),
	# 		mod_ui_download_button(ns("output_table_csv_dl"), "Download CSV"),
	# 		mod_ui_download_button(ns("output_table_xlsx_dl"), "Download Excel"),
	# 		mod_ui_modal_column(ns("pdb_structures"))
	# 	)
	# ))
}



mod_heatmap_server <- function(input, output, session, data) {
	ns <- session$ns
	print(data[1:3,1:3])
	makeInteractiveComplexHeatmap(input, output, session, Heatmap(data) %>% draw(), ns("heatmap"))
}