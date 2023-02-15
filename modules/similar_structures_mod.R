mod_similar_structures_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    ### Dropdown boxes for alignment
    selectInput(ns("kinase_align1"), label = "Kinase 1", choices = meta$symbol_nice, selected = "ABL1"),
    selectInput(ns("kinase_align2"), label = "Kinase 2", choices = meta$symbol_nice, selected = "AKT1"),
    checkboxInput(ns("kinase_domain_only"), label = "Show kinase domain only", value = TRUE),
    ### 3d alignment visualization
    r3dmolOutput(ns("align_3d")),
    ### Most structurally similar kinases output
    # data table output -- most similar
    dataTableOutput(ns('similar_dt')),
    # text output -- most similar
    uiOutput(ns("ui_text")),
  )
}

mod_similar_structures_server <- function(input, output, session) {
  ns <- session$ns
  #### get similar kinases -----------------------
  most_similar_full = reactive({
    tmp = quo(input$kinase_align1)
    tm_max_data() %>% dplyr::select(row_names, !!tmp) %>% dplyr::rename(TM_max = eval(tmp), symbol = row_names) %>% dplyr::filter(symbol != eval(tmp)) %>% dplyr::arrange(desc(TM_max))
  })
  
  #### Text outputs for most similar kinases ------------
  #output$text1 = renderText({paste("You have selected", input$kinase_align1)})
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
  
  ####### 3d alignment visualization output --------------
  output$align_3d = renderR3dmol(align_kinases(input$kinase_align1, input$kinase_align2, domain_only = input$kinase_domain_only))
  
}