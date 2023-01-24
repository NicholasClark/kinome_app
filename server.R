library(tidyverse)
library(readr)
library(tibble)
library(arrow)

server <- function(input, output, session) {
	meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	
	tm_df = read_parquet("data/TM_data_full.parquet")
	tm_max_df = read_parquet("data/TM_max_df.parquet") #%>% as.data.frame() %>% column_to_rownames("row_names")
	
	
	
	#### get similar kinases 
	tm_max_data = reactive(tm_max_df)
	
	most_similar_full = reactive({
		tmp = quo(input$kinase_align1)
		tm_max_data() %>% dplyr::select(row_names, !!tmp) %>% dplyr::rename(TM_max = eval(tmp), uniprot_name = row_names) %>% dplyr::filter(uniprot_name != eval(tmp)) %>% dplyr::arrange(desc(TM_max))
	})
	
	similar_text1 = reactive(paste("Most similar kinases to ", input$kinase_align1))
	similar_text2 = reactive({
		tmp_text = ""
		num_top = 3
		tmp = most_similar_full() %>% head(num_top)
		kinases = tmp[,1]
		tm_scores = tmp[,2] %>% signif(3)
		#paste(kinases, tm_scores, sep = " ")
		nums = paste(1:num_top, ".", sep = "")
		tmp_text = paste(nums, kinases, paste("(", tm_scores ,")", sep = ""), sep = " ")
		tmp_text = paste(tmp_text, collapse = " ")
		#print(tmp_text)
		#paste0("Most similar kinases to ", input$kinase_align1, ": ", tmp_text, collapse = "")
	})
	output$test2 = renderDataTable(most_similar_full() %>% head())
	output$ui_text = renderUI({
		HTML(paste(similar_text1(), similar_text2(), sep = '<br/>'))
	})
	
	
	output$test1 = renderDataTable(tm_max_data())
	
	output$text1 = renderText({paste("You have selected", input$kinase_align1)})
	

}
