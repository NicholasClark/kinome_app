library(shiny)
library(readr)

meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

ui <- fluidPage(
	"Hello, world!",
	br(),
	##### select inputs for alignment
	selectInput("kinase_align1", label = "Kinase 1", choices = meta$uniprot_name_nice),
	selectInput("kinase_align2", label = "Kinase 2", choices = meta$uniprot_name_nice),
	
	
	textOutput("text1"),
	#textOutput("text2"),
	dataTableOutput('test1'),
	dataTableOutput('test2'),
	#textOutput("similar_text")
	uiOutput("ui_text")
)