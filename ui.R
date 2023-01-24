library(shiny)
library(readr)

meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

ui <- fluidPage(
	"Hello, world!",
	br(),
	##### select inputs for alignment
	selectInput("kinase_align1", label = "Kinase 1", choices = meta$symbol_nice),
	selectInput("kinase_align2", label = "Kinase 2", choices = meta$symbol_nice),
	
	
	textOutput("text1"),
	#dataTableOutput('tm_max_dt'),
	#dataTableOutput('similar_dt'),
	uiOutput("ui_text"),
	r3dmolOutput("align_3d")
)