library(tidyverse)
library(readr)
library(tibble)
library(arrow)
library(r3dmol)
library(here)
library(Rpdb)
library(bio3d)
library(magrittr)

### define helper functions
source("helper_funs.R")

server <- function(input, output, session) {
	### read in data
	meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	tm_df = read_parquet("data/TM_data_full.parquet")
	tm_max_df = read_parquet("data/TM_max_df.parquet")
	tm_max_mat = tm_max_df %>% as.data.frame() %>% column_to_rownames("row_names") %>% as.matrix()
	### convert row/colnames
	rownames(tm_max_mat) = convert_uniprot_to_symbol_nice(rownames(tm_max_mat))
	colnames(tm_max_mat) = convert_uniprot_to_symbol_nice(colnames(tm_max_mat))
	
	tm_max_df = tm_max_mat %>% as.data.frame() %>% rownames_to_column("row_names")
	tm_max_data = reactive(tm_max_df)
	
	#### TM-max matrix/data table output
	output$tm_max_dt = renderDataTable(tm_max_data())
	
	
	#### get similar kinases -----------------------
	most_similar_full = reactive({
		tmp = quo(input$kinase_align1)
		tm_max_data() %>% dplyr::select(row_names, !!tmp) %>% dplyr::rename(TM_max = eval(tmp), symbol = row_names) %>% dplyr::filter(symbol != eval(tmp)) %>% dplyr::arrange(desc(TM_max))
	})
	
	#### Text outputs for most similar kinases
	output$text1 = renderText({paste("You have selected", input$kinase_align1)})
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
	output$similar_dt = renderDataTable(most_similar_full() %>% head())
	output$ui_text = renderUI({
		HTML(paste(similar_text1(), similar_text2(), sep = '<br/>'))
	})
	###################
	
	output$align_3d = renderR3dmol(align_kinases(input$kinase_align1, input$kinase_align2))
	

}
