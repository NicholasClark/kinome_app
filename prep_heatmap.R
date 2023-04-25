#library(readr)
#library(dplyr)
#library(ComplexHeatmap)
#library(InteractiveComplexHeatmap)
#library(magrittr)
library(colorRamp2)
#library(arrow)
library(dendsort)
#library(seriation)

mat = tm_max_mat
annot_df = meta %>%
	select(Group, Fold_Annotation, is_curated) %>%
	as.data.frame()
cm = "average"
size = unit(10, "inches")
cd = "pearson"
#cd = "euclidean"
col1 = c("#ee5680",
		 "#d9906a",
		 "#df7e39",
		 "#d0bf3a",
		 "#b2bd6c",
		 "#7dca54",
		 "#64cf9e",
		 "#6ab3e1",
		 "#9d80e8",
		 "#d980cd",
		 "#dd82a2")
names(col1) = meta$Group %>% unique() %>% sort()
col2 = c("#A3A4D1",
		 "#8DD3D3",
		 "#E5BAC7",
		 "#FECE88",
		 "#D0E288")
names(col2) = meta$Fold_Annotation %>% na.omit() %>% unique() %>% sort()
#col2 = factor(col2, levels = col2[c(3,2,1,5,4)])
#col2 = col2[c(3,2,1,5,4)]

col3 = c("black","gray75")
names(col3) = c("TRUE", "FALSE")

ha_row = rowAnnotation(df = annot_df, col = list(Group = col1, Fold_Annotation = col2, is_curated = col3))
ha_col = columnAnnotation(df = annot_df, col = list(Group = col1, Fold_Annotation = col2, is_curated = col3), show_legend = F) 

#col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
col_fun = colorRamp2(c(0.5, 0.75, 1), c("blue", "white", "red"))

colmap = ColorMapping(col_fun = col_fun)
#col_fun(seq(0, 1, length = 20))

############ optimal leaf ordering ############

#calculate distance matrix. default is Euclidean distance
dist_mat <- as.dist(1 - cor(t(mat), method = "pearson"))
#perform hierarchical clustering. The default is complete linkage.
col_hc <- hclust(dist_mat, method = "average")
#row_hc <- hclust(t(dist_mat), method = "average")
col_dend = dendsort(as.dendrogram(col_hc), type="average")

ht_int = Heatmap(mat,
				 left_annotation = ha_row,
				 top_annotation = ha_col,
				 show_row_names = F, show_column_names = F,
				 #clustering_method_columns = cm, clustering_method_rows = cm,
				 #clustering_distance_columns = cd, clustering_distance_rows = cd,
				 cluster_rows = col_dend, cluster_columns = col_dend,
				 #heatmap_height = size, heatmap_width = size,
				 heatmap_legend_param = list(
				 	title = "TM-score", at = seq(0, 1, 0.2),
				 	col = col_fun
				 )
)
