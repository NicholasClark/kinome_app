### Module to prepare heatmap

mod_prep_heatmap_ui <- function(id) {
	ns <- NS(id)
	fluidPage(
		sliderInput(ns("heatmap_breaks"), label = h3("Heatmap color breaks"), min = 0, 
					max = 1, value = c(0.5, 0.75)),
		actionButton(ns("apply_breaks"), label = "Apply color breaks"),
		selectInput(ns("distance_metric"), label = "Distance metric", choices = list(`One minus TM-score` = "TM_score", `Pearson Correlation`= "pearson", `Spearman Correlation`= "spearman", `Euclidean distance` = "euclidean", `Cluster within groups` = "within_groups"),
					selected = "TM_score"),
		selectInput(ns("kinase_family"), label = "Kinase family",
		            choices = c("All families","AGC", "AKG", "CAMK", "CK1", "CMGC",
		                        "Other", "RGC", "STE", "TK", "TKL", "Unknown"),
		            selected = c("AGC")
					#selected = "All families"
		            ),
		selectInput(ns("matrix_names"), label = "Matrix row/column-names",
					choices = list(`Gene symbols` = "gene_symbol",
								   `Uniprot names` = "uniprot_name"),
					selected = "gene_symbol"
					),
		checkboxInput(ns("show_row_col_names"), label = "Show row/column names")
	)
}


heatmap_server = function(id, parent, rv) {
	#mod_prep_heatmap_server <- function(input, output, session) {
	moduleServer(id, function(input, output, session) {
		ns <- session$ns
		print("heatmap_server_called")
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
		
		make_heatmap = function() {
			print("make heatmap")
		  
		  
		  annot_df = meta %>%
		    select(Group, Fold_Annotation, is_curated, uniprot_name_nice, symbol_nice, domain_length) %>%
		    as.data.frame()
		  cm = "average"
		  size = unit(10, "inches")
		  #cd = "pearson"
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
	    # AGC       AKG      CAMK       CK1      CMGC     Other       RGC       STE 
	    # "#ee5680" "#d9906a" "#df7e39" "#d0bf3a" "#b2bd6c" "#7dca54" "#64cf9e" "#6ab3e1" 
	    # TK       TKL   Unknown 
	    # "#9d80e8" "#d980cd" "#dd82a2" 
	    col2 = c("#A3A4D1",
	             "#8DD3D3",
	             "#E5BAC7",
	             "#FECE88",
	             "#D0E288")
	    names(col2) = meta$Fold_Annotation %>% na.omit() %>% unique() %>% sort()
	    # Atypical    Eukaryotic Like Kinase (eLK) Eukaryotic Protein Kinase (ePK) 
	    # "#A3A4D1"                       "#8DD3D3"                       "#E5BAC7" 
	    # Unknown     Unrelated to Protein Kinase 
	    # "#FECE88"                       "#D0E288" 
	    #col2 = factor(col2, levels = col2[c(3,2,1,5,4)])
	    #col2 = col2[c(3,2,1,5,4)]
	    col3 = c("black","gray75")
	    names(col3) = c("TRUE", "FALSE")
	    col4 = c()
		if(input$kinase_family == "Unknown") {
			annot_df = annot_df %>% filter(is.na(Group) | Group == "Unknown")
			annot_df$Group[is.na(annot_df$Group)] = "NA"
			genes = annot_df$symbol_nice
			mat = mat[genes, genes]
			col1 = c("#dd82a2", "grey30"); names(col1) = c("Unknown", "NA")
		} else if(input$kinase_family != "All families") {
			annot_df = annot_df %>% filter(Group == input$kinase_family)
			genes = annot_df$symbol_nice
			mat = mat[genes, genes]
		}
	    
	    if(input$matrix_names == "uniprot_name") {
	    	uni_names = meta$uniprot_name_nice[match(rownames(mat), meta$symbol_nice)]
	    	rownames(mat) = uni_names
	    	colnames(mat) = uni_names
	    }
	    
	    #rv$kinase_family = input$kinase_family
	    print(head(annot_df))
		annot_df = annot_df %>%
			select(Group, Fold_Annotation, is_curated, domain_length) %>%
			as.data.frame()
	    print(head(annot_df))
		  ha_row = rowAnnotation(df = annot_df, col = list(Group = col1, Fold_Annotation = col2, is_curated = col3))
		  ha_col = columnAnnotation(df = annot_df, col = list(Group = col1, Fold_Annotation = col2, is_curated = col3), show_legend = F)
		  
			############ optimal leaf ordering ############
			
			#calculate distance matrix
			#rv$distance_metric = input$distance_metric
			if(input$distance_metric == "euclidean") {
				## distance = Euclidean distance between two vectors of TM-scores
				dist_mat <- dist(t(mat), method = "euclidean")
				#perform hierarchical clustering. The default is average linkage.
				col_hc <- hclust(dist_mat, method = "average")
			} else if(input$distance_metric == "TM_score") {
				## distance = 1 - TM_max(i,j) for domains i and j
				col_hc <- hclust(as.dist(1-mat), method = "average")
			} else if(input$distance_metric == "spearman") {
				## distance = Spearman correlation of two vectors of TM-scores
				dist_mat <- as.dist(1 - cor(t(mat), method = "spearman"))
				#perform hierarchical clustering. The default is average linkage.
				col_hc <- hclust(dist_mat, method = "average")
			} else {
				## distance = Pearson correlation of two vectors of TM-scores
				dist_mat <- as.dist(1 - cor(t(mat), method = "pearson"))
				#perform hierarchical clustering. The default is average linkage.
				col_hc <- hclust(dist_mat, method = "average")
			}
		  
			#row_hc <- hclust(t(dist_mat), method = "average")
			col_dend = dendsort(as.dendrogram(col_hc), type="average")
			
			#col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
			
			
			final_breaks = c(input$heatmap_breaks, 1)
			#col_fun = colorRamp2(c(0.5, 0.75, 1), c("blue", "white", "red"))
			col_fun = colorRamp2(final_breaks, c("blue", "white", "red"))
			colmap = ColorMapping(col_fun = col_fun)
			
			if(input$distance_metric == "within_groups") {
				if(input$kinase_family == "All families") {
					tmp_annot = annot_df$Group
					tmp_annot[is.na(tmp_annot)] = "NA"
					col_dend = cluster_within_group(mat, factor(tmp_annot))
				}
			}
			
			rv$hm = reactive({
			  make_heatmap_full = function() {
			    Heatmap(mat,
			            left_annotation = ha_row,
			            top_annotation = ha_col,
			            show_row_names = input$show_row_col_names,
			    		show_column_names = input$show_row_col_names,
			            #clustering_method_columns = cm, clustering_method_rows = cm,
			            #clustering_distance_columns = cd, clustering_distance_rows = cd,
			            cluster_rows = col_dend, cluster_columns = col_dend,
			            #heatmap_height = size, heatmap_width = size,
			            heatmap_legend_param = list(
			              title = "TM-score", at = seq(0, 1, 0.2),
			              col = col_fun
			            )
			    )
			  }
			  make_heatmap_test = function() {
			    ## heatmap for testing
			    Heatmap(mat[1:50,1:50],
    				 heatmap_legend_param = list(
    				 	title = "TM-score", at = seq(0, 1, 0.2),
    				 	col = col_fun)
    				 )
			  }
			  
				ht_int = make_heatmap_full()
				#ht_int = make_heatmap_test()
				
				ht_int@matrix_color_mapping = colmap
				ht_int
			})
			#rv$breaks = input$heatmap_breaks
			return(NULL)
		}
		
		observeEvent(c(input$apply_breaks, input$distance_metric, 
					   input$kinase_family, input$matrix_names,
					   input$show_row_col_names), {
			make_heatmap()
		}, ignoreInit = TRUE, ignoreNULL = TRUE)
		observeEvent(c(input$heatmap_breaks, input$distance_metric,
					   input$kinase_family, input$matrix_names,
					   input$show_row_col_names), {
			make_heatmap()
		}, once = TRUE)
		
	})
}
