#Helper function: create reference data file from multiple OH-Epicap profiles
#createRefDataset <- function(files, outputname){
#  
#  #if .rds file
#  if(tools::file_ext(userFile()$datapath)=="rds"){
#    readRDS(userFile()$datapath)  
#    #if .csv file
#  } else {
#    df <- read.csv(userFile()$datapath, header = TRUE, sep = ",", stringsAsFactors = stringsAsFactors, colClasses="character", na.strings = NULL)
#    setNames(as.list(df$Value),df$Question)
#  } 
#}

#Helper function: formats a reference data file into scoring table format
formatRefDataset <- function(refdatafile, questionnaire_file = questionnaire_file){
  
  source("R/scoringHelpers.R")
  
  #Check if questionnaire exists (in the global env), and if not read in questionnaire (within function)
  if(!exists("questionnaire")){
    source("R/questionnaireHelpers.R")
    questionnaire <- readQuestionnaire(questionnaire_file)
  }
  #Read in ref data (read.csv)
  #refdatafile<-"Data/reference_datasets/example_benchmark_data.csv"
  refdata <- read.csv(refdatafile)
  
  #Attach ref data values to questionnaire
  qwv<- cbind(
    questionnaire,
    Chosen_value = refdata$Value, #needs refdata to be read (i.e. read.csv or readRDS somewhere)
    low = refdata$Low,
    high = refdata$High
  )
  
  #Create scoring tables as variables
  ref_targets <- scoringTable(qwv,"targets",reference=TRUE)
  ref_indicators <- scoringTable(qwv,"indicators",reference=TRUE)
  
  #pass scoring tables on to parent environment
  return(list(ref_targets = ref_targets, ref_indicators = ref_indicators))
}

# Module UI function
benchmarkUI <- function(id, label = "benchmark", ref_datasets) {
  # `NS(id)` returns a namespace function, which was save as `ns` and will
  # invoke later.
  ns <- NS(id)
  
  tagList(
    h2("Compare Your OH-EpiCap Profile with a Reference Dataset"),
    p("This page allows the user to visually compare the completed or uploaded OH-EpiCap profile to a selected reference dataset."),
    fluidRow(
      box(width=12,
          title="Reference Dataset",
          solidHeader=TRUE, status="danger",
          collapsible=FALSE, collapsed=FALSE,
          fluidRow(column(6,fileInput(inputId = ns("selected_ref"), label = "Please select a benchmark file", multiple = FALSE, accept = c('text/csv', '.csv', 'text/comma-separated-values,text/plain'))),
                   column(6,
                          HTML("<b>Example Benchmark File</b>"),
                          p("To demo the Benchmarking page, please download the following benchmark file and upload it into the app:", tags$a("Example Benchmark File", href="reference_datasets/example_benchmark_data.csv"))
                    )
          )
      )
    ),
    fluidRow(
      box(width=12,
          title="Targets",
          solidHeader=TRUE, status="info",
          collapsible=TRUE, collapsed=FALSE,
          fluidRow(
            column(6,
                   p("This section shows the comparison between the completed/uploaded OH-EpiCap profile and the selected reference dataset, across the twelve targets."),
                   p("The lightly coloured area depicts the interquartile range (IQR) of the relevant target score in the reference dataset, with the + symbol indicating the median."),
                   p("If a data point (filled circle) falls within the coloured area, the target score from the OH-EpiCap profile is within the range of the benchmark target."),
                   uiOutput(ns("bmtxt_targets"))),
                   column(6, girafeOutput(ns("benchmark_all")),  downloadButton(ns('save_benchmark_all'), 'Download Plot (SVG)', style="float:right")))
          
      )
    ),
    fluidRow(
      box(width=12,
          title="Dimension 1: Organization",
          solidHeader=TRUE, status="warning",
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6, 
                   p("This section shows the comparison between the completed/uploaded OH-EpiCap profile and the selected reference dataset, across the indicators of Dimension 1 (Organization)."),
                   p("The lightly coloured area depicts the interquartile range (IQR) of the relevant indicator score in the reference dataset, with the + symbol indicating the median."),
                   p("If a data point (filled circle) falls within the coloured area, the indicator score from the OH-EpiCap profile is within the range of the benchmark target."),
                   uiOutput(ns("bmtxt_dim1"))),
            column(6, girafeOutput(ns("benchmark_1")), downloadButton(ns('save_benchmark_1'), 'Download Plot (SVG)', style="float:right")))
      )
    ),
    fluidRow(
      box(width=12,
          title="Dimension 2: Operations",
          solidHeader=TRUE, status="primary",
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6, 
                   p("This section shows the comparison between the completed/uploaded OH-EpiCap profile and the selected reference dataset, across the indicators of Dimension 2 (Operations)."),
                   p("The lightly coloured area depicts the interquartile range (IQR) of the relevant indicator score in the reference dataset, with the + symbol indicating the median."),
                   p("If a data point (filled circle) falls within the coloured area, the indicator score from the OH-EpiCap profile is within the range of the benchmark target."),                   
                   uiOutput(ns("bmtxt_dim2"))),
            column(6, girafeOutput(ns("benchmark_2")), downloadButton(ns('save_benchmark_2'), 'Download Plot (SVG)', style="float:right")))
      )
    ),
    fluidRow(
      box(width=12,
          title="Dimension 3: Impact",
          solidHeader=TRUE,
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6,
                   p("This section shows the comparison between the completed/uploaded OH-EpiCap profile and the selected reference dataset, across the indicators of Dimension 3 (Impact)."),
                   p("The lightly coloured area depicts the interquartile range (IQR) of the relevant indicator score in the reference dataset, with the + symbol indicating the median."),
                   p("If a data point (filled circle) falls within the coloured area, the indicator score from the OH-EpiCap profile is within the range of the benchmark target."),                   
                   uiOutput(ns("bmtxt_dim3"))),
            column(6, girafeOutput(ns("benchmark_3")), downloadButton(ns('save_benchmark_3'), 'Download Plot (SVG)', style="float:right")))
      )
    ),
  )
}

# Module server function
benchmarkServer <- function(id, scores_targets=scores_targets, scores_indicators=scores_indicators, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      
      #creates scoring tables from selected reference datafile, stores these as variables
      ref_ST <- reactive({
        inFile <- lapply(input$selected_ref$datapath, fread)

        # Error message if no file is uploaded
        validate(need(!is.null(input$selected_ref$datapath), message="Please select a benchmark file."))
        
        # Error message if the file contains wrong format/data:
        questionNums <- c("Q1.1.1", "Q1.1.2", "Q1.1.3", "Q1.1.4",
                          "Q1.2.1", "Q1.2.2", "Q1.2.3", "Q1.2.4",
                          "Q1.3.1", "Q1.3.2", "Q1.3.3", "Q1.3.4",
                          "Q1.4.1", "Q1.4.2", "Q1.4.3", "Q1.4.4",
                          
                          "Q2.1.1", "Q2.1.2", "Q2.1.3", "Q2.1.4",
                          "Q2.2.1", "Q2.2.2", "Q2.2.3", "Q2.2.4",
                          "Q2.3.1", "Q2.3.2", "Q2.3.3", "Q2.3.4",
                          "Q2.4.1", "Q2.4.2", "Q2.4.3", "Q2.4.4",
                          
                          "Q3.1.1", "Q3.1.2", "Q3.1.3", "Q3.1.4",
                          "Q3.2.1", "Q3.2.2", "Q3.2.3", "Q3.2.4",
                          "Q3.3.1", "Q3.3.2", "Q3.3.3", "Q3.3.4",
                          "Q3.4.1", "Q3.4.2", "Q3.4.3", "Q3.4.4")

        validate(need(all(nrow(inFile[[1]])==length(questionNums), ncol(inFile[[1]])==4, inFile[[1]][,1] == questionNums, is.numeric(unlist(inFile[[1]][,2:4])) == TRUE), 
                 message = "The benchmark file does not have the expected format. We expect four columns with the first containing the question numbers (i.e., Q1.1.1 to Q3.4.4), and numeric data for the value, low and high scores generated by the Create Benchmark tool.")
        )
        
        formatRefDataset(input$selected_ref$datapath)
      })
      ref_targets <- reactive({ref_ST()$ref_targets})
      ref_indic <- reactive({ref_ST()$ref_indicators})

      #generate radarcharts, using scoring tables from the active profile and the reference dataset
      output$benchmark_all <- renderGirafe(makeRadarPlot_benchmark(scores_targets(),3,ref_targets()))
      output$benchmark_1 <- renderGirafe(makeRadarPlot_benchmark(scores_indicators()[1:20,],4,ref_indic()[1:16,]))
      output$benchmark_2 <- renderGirafe(makeRadarPlot_benchmark(scores_indicators()[21:40,],4,ref_indic()[17:32,]))
      output$benchmark_3 <- renderGirafe(makeRadarPlot_benchmark(scores_indicators()[41:60,],4,ref_indic()[33:48,]))
      
      #lists of targets/indicators with low scores
      source("R/scoringHelpers.R")
      targets_low <- id_low_scores(scores_targets(),ref_targets()$low)
      targets_high <- id_high_scores(scores_targets(),ref_targets()$high)
      dim1_low <- id_low_scores(scores_indicators()[1:20,],ref_indic()[1:16,]$low)
      dim1_high <- id_high_scores(scores_indicators()[1:20,],ref_indic()[1:16,]$high)
      dim2_low <- id_low_scores(scores_indicators()[21:40,],ref_indic()[17:32,]$low)
      dim2_high <- id_high_scores(scores_indicators()[21:40,],ref_indic()[17:32,]$high)
      dim3_low <- id_low_scores(scores_indicators()[41:60,],ref_indic()[33:48,]$low)
      dim3_high <- id_high_scores(scores_indicators()[41:60,],ref_indic()[33:48,]$high)
      
      #generate benchmark texts
      output$bmtxt_refdata <- renderText({"Sample text describing the reference dataset"})
      output$bmtxt_targets <- renderUI({HTML(paste0("Targets exceeding the benchmark range, are: <b>",targets_high(),"</b>.<br><br>Targets falling below the benchmark range, are: <b>",targets_low(),"</b>."))})
      output$bmtxt_dim1 <- renderUI({HTML(paste0("Indicators exceeding the benchmark range, are: <b>",dim1_high(),"</b>.<br><br>Indicators falling below the benchmark range, are: <b>",dim1_low(),"</b>."))})
      output$bmtxt_dim2 <- renderUI({HTML(paste0("Indicators exceeding the benchmark range, are: <b>",dim2_high(),"</b>.<br><br>Indicators falling below the benchmark range, are: <b>",dim2_low(),"</b>."))})
      output$bmtxt_dim3 <- renderUI({HTML(paste0("Indicators exceeding the benchmark range, are: <b>",dim3_high(),"</b>.<br><br>Indicators falling below the benchmark range, are: <b>",dim3_low(),"</b>."))})
      
      
      # Save benchmark figures as SVGs
      output$save_benchmark_all <- downloadHandler(filename = "Benchmark_Plot_All.svg", 
                                                  content = function(file){
                                                    writeLines(reactive({makeRadarPlot_benchmark(scores_targets(),3,ref_targets())})()$x$html, con = file)})
      output$save_benchmark_1 <- downloadHandler(filename = "Benchmark_Plot_1.svg", 
                                                   content = function(file){
                                                     writeLines(reactive({makeRadarPlot_benchmark(scores_indicators()[1:20,],4,ref_indic()[1:16,])})()$x$html, con = file)})
      output$save_benchmark_2 <- downloadHandler(filename = "Benchmark_Plot_2.svg", 
                                                   content = function(file){
                                                     writeLines(reactive({makeRadarPlot_benchmark(scores_indicators()[21:40,],4,ref_indic()[17:32,])})()$x$html, con = file)})
      output$save_benchmark_3 <- downloadHandler(filename = "Benchmark_Plot_3.svg", 
                                                   content = function(file){
                                                     writeLines(reactive({makeRadarPlot_benchmark(scores_indicators()[41:60,],4,ref_indic()[33:48,])})()$x$html, con = file)})
    }
  )    
}