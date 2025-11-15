# questionnaireUpload.R
# This script uploads .csv files (restore questionnaire state)
# Uses readr for robust encoding & delimiter handling

# -------- UI --------
questionnaireUploadUI <- function(id, label = "upload") {
  ns <- NS(id)
  
  tagList(
    box(width = 12,
        title = "Upload Your Questionnaire File",
        solidHeader = TRUE, status = "primary",
        collapsible = FALSE, collapsed = FALSE,
        fluidRow(
          column(
            6,
            fileInput(
              ns("file"),
              label,
              accept = c("text/csv", "text/comma-separated-values", ".csv")
            )
          ),
          column(
            6,
            HTML("<b>Example Questionnaire Files</b>"),
            p(
              "To demo the Results page, please download one of the following questionnaire files and upload it into the app:",
              tags$a("Example Questionnaire 1", href = "reference_datasets/example_questionnaire_answers.csv"),
              "and",
              tags$a("Example Questionnaire 2.", href = "reference_datasets/example_questionnaire_answers_2.csv"),
              "You are also able to upload these questionnaire files into the Create Benchmark tab to demo the create benchmark functionality of this tool."
            )
          )
        ),
        htmlOutput(ns("msg"))
    )
  )
}

# ---- helper: robust CSV reader (UTF-8 first, fallback Latin-1; comma; semicolon; tab) ----
.read_questionnaire_best <- function(path) {
  encodings <- c("UTF-8", "Latin1")         # try UTF-8 first, then Latin-1
  delims    <- c(",", ";", "\t")            # common regional delimiters
  
  for (enc in encodings) {
    for (del in delims) {
      df_try <- try(
        readr::read_delim(
          file   = path,
          delim  = del,
          quote  = "\"",
          col_types = readr::cols(
            Question = readr::col_character(),
            Value    = readr::col_character()
          ),
          # Keep literal "NULL" (don't convert to NA)
          na      = character(),
          locale  = readr::locale(encoding = enc),
          trim_ws = TRUE
        ),
        silent = TRUE
      )
      if (!inherits(df_try, "try-error")) {
        # Clean possible BOM in the first header (readr usually handles it, but just in case)
        nm <- names(df_try)
        nm[1] <- sub("^\ufeff", "", nm[1])
        names(df_try) <- nm
        
        # Ensure we end up with exactly two columns named Question/Value
        if (ncol(df_try) >= 2 && all(c("Question", "Value") %in% names(df_try))) {
          df_try <- df_try[, c("Question", "Value")]
        } else if (ncol(df_try) == 2) {
          names(df_try) <- c("Question", "Value")
        } else {
          next
        }
        
        return(as.data.frame(df_try, stringsAsFactors = FALSE))
      }
    }
  }
  stop("Could not parse CSV as UTF-8/Latin-1 with ',', ';', or tab delimiter.")
}

# -------- Server --------
questionnaireUploadServer <- function(id, stringsAsFactors) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # Selected file
      userFile <- reactive({
        extension <- tools::file_ext(input$file$datapath)
        
        validate(need(input$file, message = "Please upload a questionnaire file."))
        validate(need(extension %in% c("csv"), message = "Invalid file. Please upload a .csv file."))
        
        # Try to read robustly (UTF-8 first, then Latin-1; comma/semicolon/tab)
        df <- .read_questionnaire_best(input$file$datapath)
        
        # Validate expected shape and allowed values (keep literal 'NULL')
        validate(need(
          all(c(
            nrow(df[which(grepl("Q", df[, 1])), ]) == 48,
            nrow(df[which(grepl("C", df[, 1])), ]) == 48,
            ncol(df) == 2,
            all(df[which(grepl("Q", df[, 1])), 2] %in% c("NULL", "NA", "1", "2", "3", "4"))
          )),
          message = paste0(
            "Your file, ", input$file$name,
            ", does not have the expected format. We expect there to be two columns; ",
            "one for the question number, and one for the value. Each value should be one of ",
            "'NULL' (in the case for incomplete questionnaire files), 'NA', '1', '2', '3' or '4'."
          )
        ))
        
        input$file
      })
      
      # Read and save list of inputs (return named list)
      state <- reactive({
        if (tools::file_ext(userFile()$datapath) == "csv") {
          df <- .read_questionnaire_best(userFile()$datapath)
          setNames(as.list(df$Value), df$Question)
        }
      })
      
      # Message area
      output$msg <- renderUI(
        HTML(
          paste0(
            "File ", userFile()$name,
            " was successfully uploaded. If the uploaded questionnaire is complete, ",
            "please visit the Results page for visualisation. If the uploaded questionnaire ",
            "is only partially completed, please visit the Dimension-specific pages to complete your submission."
          )
        )
      )
      
      # Return reactive state
      return(state)
    }
  )
}



