library(tidyverse)
library(readr)
library(tibble)
library(arrow)

server <- function(input, output, session) {
	meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	
	tm_df = read_parquet("data/TM_data_full.parquet")
	tm_max_df = read_parquet("data/TM_max_df.parquet") #%>% as.data.frame() %>% column_to_rownames("row_names")
	
	tm_max_data = reactive(tm_max_df)
	
	most_similar = reactive({
		tm_max_data() %>% dplyr::select(row_names, input$kinase_align1) %>% dplyr::filter(row_names != as.character(input$kinase_align1)) %>% dplyr::arrange_at(.vars = input$kinase_align1, desc) %>% head(5)
	})
	
	output$test1 = renderDataTable(tm_max_data())
	output$test2 = renderDataTable(most_similar())
	
	#output$text2 = renderText({paste("Most similar kinases:", most_similar() )})
	
	# observeEvent(input$kinase_align1, {
	# 	tmp = tm_max_df %>% arrange(desc(input$kinase_align1))
	# 	output$text2 = renderText({paste("Most similar kinases:", tmp)})
	# })
	
	
	
	output$text1 = renderText({paste("You have selected", input$kinase_align1)})
	

}
