#library(tidyverse)
#library(arrow)


### load data used by multiple parts of app ---------------
#meta = read_parquet("data/kinase_meta_updated_2023_update.parquet")
meta = load_metadata()

### load data used by heatmap -----------------
tm_max_df = read_parquet("data/TM_max_df.parquet")

tm_max_df = tm_max_df[-which(tm_max_df$row_names == "KS6C1_HUMAN_344_445"),]
tm_max_df[["KS6C1_HUMAN_344_445"]] = NULL

tm_max_mat = tm_max_df %>% as.data.frame() %>% remove_rownames() %>% column_to_rownames("row_names") %>% as.matrix()
# convert row/colnames
rownames(tm_max_mat) = convert_uniprot_to_symbol_nice(rownames(tm_max_mat))
colnames(tm_max_mat) = convert_uniprot_to_symbol_nice(colnames(tm_max_mat))
tm_max_df = tm_max_mat %>% as.data.frame() %>% rownames_to_column("row_names")

tm_max_data = reactive(tm_max_df)


### Load data used by alignment -----------------
tm_df = read_parquet("data/TM_data_full.parquet")
tm_df = tm_df %>% filter(kinase1 != "RPS6KC1_344_445" & kinase2 != "RPS6KC1_344_445")
