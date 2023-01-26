#library(tidyverse)
#library(arrow)


### load data used by multiple parts of app ---------------
meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

### load data used by heatmap -----------------
tm_max_df = read_parquet("data/TM_max_df.parquet")
tm_max_mat = tm_max_df %>% as.data.frame() %>% column_to_rownames("row_names") %>% as.matrix()
# convert row/colnames
rownames(tm_max_mat) = convert_uniprot_to_symbol_nice(rownames(tm_max_mat))
colnames(tm_max_mat) = convert_uniprot_to_symbol_nice(colnames(tm_max_mat))
tm_max_df = tm_max_mat %>% as.data.frame() %>% rownames_to_column("row_names")

tm_max_data = reactive(tm_max_df)


### Load data used by alignment -----------------
tm_df = read_parquet("data/TM_data_full.parquet")