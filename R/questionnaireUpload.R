#This is script uploads .csv and .rds files (in order to restore the state of the questionnaire)

# Module UI function
questionnaireUploadUI <- function(id, label = "upload") {
  # `NS(id)` returns a namespace function, which was save as `ns` and will
  # invoke later.
  ns <- NS(id)
  
  tagList(
    box(width=12,
        title="Upload Your Questionnaire File",
        solidHeader=TRUE, status="primary",
        collapsible=FALSE, collapsed=FALSE,
        fileInput(ns("file"), label, accept=c("text/csv", "text/comma-separated-values", ".csv")),#, ".rds")), # I will harden .rds inputs later.
        htmlOutput(ns("msg"))
    )
  )
}

# Module server function
questionnaireUploadServer <- function(id, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      # The selected file, if any
      userFile <- reactive({
        extension <- tools::file_ext(input$file$datapath)
        # If no file is selected, don't do anything
        validate(need(input$file, message = "Please upload a questionnaire file."))
        # If not .rds or .csv, print error message (shown in the textoutput)
        #validate(need(extension %in% c("rds","csv"), message =  "Invalid file. Please upload a .csv or .rds file"))
        validate(need(extension %in% c("csv"), message =  "Invalid file. Please upload a .csv file."))
        
        # Check if the file has the correct format:
        df <- read.csv(input$file$datapath, header = TRUE, sep = ",", stringsAsFactors = stringsAsFactors, colClasses="character", na.strings = NULL, fileEncoding = "UTF-8", encoding = "UTF-8")
        validate(need(all(c(nrow(df[which(grepl("Q",df[,1])),]) == 48, ncol(df) == 2, all(df[which(grepl("Q",df[,1])), 2] %in% c("NULL", "NA", "1", "2", "3", "4")))),
                      message = paste0("Your file, ", input$file$name,", does not have the expected format. We expect there to be two columns; one for the question number, and one for the value. Each value should be one of 'NULL' (in the case for incomplete questionnaire files), 'NA', '1', '2', '3' or '4'.")))
        input$file
      })
      
      # Read and save list of inputs  
      state <- reactive({
        #if .rds file - NOTE: This conditional branch will never execute due to disabling .rds inputs above.
        if(tools::file_ext(userFile()$datapath) == "rds"){
          readRDS(userFile()$datapath)  
          #if .csv file
        } else if(tools::file_ext(userFile()$datapath) == "csv") {
          df <- read.csv(userFile()$datapath, 
                         header = TRUE,
                         sep = ",",
                         stringsAsFactors = stringsAsFactors,
                         colClasses="character",
                         na.strings = NULL,
                         fileEncoding = "UTF-8",
                         encoding = "UTF-8"
          )
          setNames(as.list(df$Value),df$Question)
        } 
      })
      
      # Some output is required to allow the display of the error msg in case of wrong file format
      # This can also display a message upon succesful upload (or could check data format and send people to next page)
      output$msg <- renderUI(
        HTML( # renderUI with HTML, to allow for correct display of text with new lines
            paste0("File ",userFile()$name, " was successfully uploaded. If the uploaded questionnaire is complete, please visit the Results page for visualisation. If the uploaded questionnaire is only partially completed, please visit the Dimension-specific pages to complete your submission."),
        )
      )
      
      # Return the reactive that yields the rds state / data frame
      return(state)
    }
  )    
}




