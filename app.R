# Setup -------------------------------------------------------------------

library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(flexdashboard)
library(tidyverse)
library(readxl)
library(tidyxl)
library(unpivotr)
library(Rcpp)
library(ggiraph)
library(ggmulti)
library(bslib)
library(data.table)

# Change encoding to UTF-8
options(encoding="UTF-8") 
questionnaire_file <- "data/EU-EpiCap_Questionnaire_22_05_11.xlsx"
setupApp(questionnaire_file = questionnaire_file)

# User interface ----------------------------------------------------------

ui <- dashboardPage(
    dashboardHeader(title = "OH-EpiCap Tool"),

# UI - sidebar ------------------------------------------------------------
    
    dashboardSidebar(
        
        sidebarMenu(
            menuItem("About OH-EpiCap", tabName = "about", icon = icon("question-circle")), 
            #menuItem("Your Surveillance Network", tabName = "network", icon = icon("project-diagram")),
            menuItem("Instructions", tabName = "instructions", icon = icon("person-chalkboard")),
            menuItem("Questionnaire", tabName = "questionnaire", icon = icon("file-alt"),
                     convertMenuItem(menuItem("Organization", tabName = "organization",
                              menuSubItem("Formalisation", href="#T1.1",newtab=FALSE),
                              menuSubItem("Coverage", href="#T1.2",newtab=FALSE),
                              menuSubItem("Resources", href="#T1.3",newtab=FALSE),
                              menuSubItem("Evaluation and Resiliance", href="#T1.4",newtab=FALSE)),"organization"),
                     convertMenuItem(menuItem("Operations", tabName = "operations",
                              menuSubItem("Data Collection and Methods Sharing", href="#T2.1",newtab=FALSE),
                              menuSubItem("Data Sharing", href="#T2.2",newtab=FALSE),
                              menuSubItem("Data Analysis and Interpretation", href="#T2.3",newtab=FALSE),
                              menuSubItem("Communication", href="#T2.4",newtab=FALSE)),"operations"),
                     convertMenuItem(menuItem("Impact", tabName = "impact",
                              menuSubItem("Technical Outputs", href="#T3.1",newtab=FALSE),
                              menuSubItem("Collaborative Added Value", href="#T3.2",newtab=FALSE),
                              menuSubItem("Immediate and Intermediate Outcomes", href="#T3.3",newtab=FALSE),
                              menuSubItem("Ultimate Outcomes", href="#T3.4",newtab=FALSE)),"impact"),
                     menuItem("Upload answers from file", tabName = "upload"),
                     menuItem("Save answers to file", tabName = "download")
            ),
            menuItem("Results", tabName = "results", icon = icon("chart-pie")),
            menuItem("Create Benchmark File", tabName = "createBenchmark", icon = icon("tools")),
            menuItem("Benchmark", tabName = "benchmark", icon = icon("copy")),
            menuItem("Glossary", tabName = "glossary", icon = icon("book")),
            menuItem("Legal Information", tabName = "legal", icon=icon("gavel")),
            box(width = 12, solidHeader = TRUE, status = "danger", collapsible = FALSE, background = "red", height="auto",
                title = "Important Disclaimer:",
                p("Please see the Legal page for information relating to the management and processing of the data entered in this app.")
            )
        )
    ),

# UI - Header CSS ---------------------------------------------------------------

    dashboardBody(
        tags$style(type="text/css", "
            
            /* Use OHEJP font and justify the text */
            body{
                font-family: Open Sans, Sans-Serif;
                text-align: justify;
                font-size: 16px;
            }
            
            /* Change the headings to have OHEJP branding blue colors */
            h1, h2, h3, h4 {
                text-align: left;
                color: #13699f;
            }
            
            /* Ensures the colourful box() headings keep default font colours */
            h3.box-title{color: unset!important;}
            
            /* Orange Download Button */
            .btn-default {
                background-color: #EF7933;
                color: white;
            }
                   
            /* Primary title and subtitle style */
            .primary-title{
                margin-top:10px; 
                font-weight:bold;
            }
            .primary-subtitle{
                margin-top:10px;
                color: #EF7933; 
                font-weight:bold;
            }
            
            /* OHEJP blue border on hovered sidebar menu items */
            .skin-blue.sidebar-menu>li.active>a, .skin-blue.sidebar-menu>li:hover>a {
                color: #CECECD;
                background: #1e282c;
                border-left-color: #13699f !important;
            }
        
            /* Fixing the navbar and sidebar in place*/
            .sidebar {
                height: 100vh;
                overflow-x: hidden;
                position: fixed !important;
                top: 0 px;
                width: 230px;
            }
            .content {
                padding-top: 75px;
                width: 50%;
            }
            
            /* Wrapping long text in red disclaimer box */
            .sidebar-menu {
                white-space: normal!important;
                overflow: hidden;
                text-align: left;
            }
            
            /* Fixing sidebar logo area in place*/
            .skin-blue .main-header .logo{
                background-color: #13699f; /* To match with rest of navbar*/ 
                height: 52px; /* To match height with rest of navbar*/
                border-right-color: #1e282c!important;
                overflow-x: hidden;
                position: fixed !important;
                top: 0 px;
            }
            
            /* Fixing the rest of the top bar in place*/
            .skin-blue .main-header .navbar {
                background-color: #13699f!important;
                position: fixed !important;
                top: 0 px;
                width: 100%;
            }
            
            /* Narrow devices*/
            @media only screen and (max-width: 1920px){
            
                /* Fix the sidebar and top bar to the top on mobile devices */
                .left-side, .main-sidebar {
                    position: fixed;
                    top: 0;
                    left: 0;
                    padding-top: 52px;
                    width: 230px;
                }
                
                /* Make the content fill the screen */
                .content {width: 90% !important;}
            }
            
            /* Fix for when deployed to shinyapps.io, plot label font go to serif*/
            text{font-family: Open Sans, Sans-Serif;}
        "),
        
# UI - tabs ---------------------------------------------------------------
        
        tabItems(
            tabItem(tabName = "about",
                    HTML('<center><a href="https://onehealthejp.eu"><img src="OHEJP MATRIX.svg", style="width:250px;"></a></center>'),
                    tags$h1(class="primary-title", "OH-EpiCap Tool"),
                    tags$h3(class="primary-subtitle", "Evaluation tool for One Health epidemiological surveillance capacities and capabilities"),
                    br(),
                    h2("About the OH-EpiCap Tool"),
                    p("The purpose of the OH-EpiCap tool is to develop system-specific profiles of (potential) surveillance interoperability between sectors, highlighting both strength and gaps in surveillance capacity and capabilities. The OH-EpiCap tool will allow mapping, evaluation and improvement of ‘One Health-ness’ using a set of standardized indicators, to allow comparison across systems, countries and hazards of interest. Countries at similar levels of ‘OH-ness’, including similar capacities, limitations and resources, can together form an agreement to develop a common framework for One Health Surveillance (OHS) to address zoonotic threats across borders. This will improve national OH structures, including surveillance and data analysis, while also facilitating better integration of multinational collaboration. Countries at different levels of ‘OH-ness’ and surveillance capacity/resources can share experiences regarding surveillance practice against the same pathogen, transfer knowledge and share ideas to improve surveillance quality and efficacy across settings."),
                    p("Some of the features of the tool include:"),
                    tags$ul(
                        tags$li("Evaluation of 'OH-ness' across three dimensions"),
                        tags$li("Interactive visualisation of results"),
                        tags$li("Benchmarking tool to compare to other One Health Surveillance systems"),
                    ),
                    br(),
                    box(status="danger", width = 12, title = "Disclaimer:", solidHeader = TRUE, 
                      p("Here we present a functional 'beta' version of the tool, that is still under development. Therefore, expect placeholder text in some areas and a work-in-progress user interface.",
                      tags$b("Please note that this version of the OH-EpiCap tool times out after 60 min of inactivity."), "To avoid data loss, you must save your data regularly using the 'Save answers to file' option."),
                    ),
                    br(),
                    p("The OH-EpiCap tool has been developed by the MATRIX consortium, an integrative project funded by the One Health European Joint Programme. The MATRIX consortium aims to advance the implementation of OHS in practice by building onto existing resources, adding value to them and creating synergies among the sectors at the national level.  One activity has been the development of the generic benchmarking tool presented here, for characterizing, monitoring and evaluating epidemiological surveillance capacities and capabilities, which directly contribute to OHS. The tool aims to identify and describe the collaborations among actors involved in the surveillance of a hazard and to characterize the OH-ness of the surveillance system. The tool will support identification of areas that could lead to improvements in existing OH surveillance capacities. "),
                    br(),
                    p("The OH-EpiCap tool is split into three Dimensions:"),
                    tags$ul(
                        tags$li("Dimension 1: Organization"),
                        tags$li("Dimension 2: Operations"),
                        tags$li("Dimension 3: Impact"),
                    ),
                    p("The OH-EpiCap questionnaire can be completed by answering the questions on each of the individual Dimension pages (under the Questionnaire tab in the sidebar)."),
                    p("In each question, scores range 1-4, with higher values suggesting better adherence to the One Health principle (better integration of sectors), and lower values suggesting improvements may be beneficial. It is possible that the answers proposed for a question do not fit the OH surveillance system under evaluation; in this case, the panel of surveillance representatives should define what would be the ideal situation regarding this question for the OH surveillance system under evaluation and score the question accordingly by comparing the current situation to the ideal one. We recommend the panel to indicate in the comment space under the question which alternative answer(s) they considered."),
                    p("The value 'Not Applicable (NA)' can be used if the indicator is not relevant to the OH surveillance system under evaluation."),
                    box(
                      width = 12, status = "primary", collapsible = FALSE, solidHeader = TRUE,
                      title = "Authorship Statement",
                      p("This tool has been developed by the University of Surrey in collaboration with the French Agency for Food, Environmental and Occupational Health & Safety (ANSES). The interface has been developed by Dr Carlijn Bogaardt and Mr Frederick T. A. Freeth, supervised by Dr Joaquin M Prada. Content has been edited by Ms Emma Taylor, based on the tool created by Drs Henok Tegegne and Viviane Henaux. We are grateful to MATRIX WP4 colleagues and the broad consortium for feedback and suggestions. The source code for this tool can be found in two linked repositories:", tags$a("Frederick T. A. Freeth's OH-EpiCap Tool GitHub Repository", href="https://github.com/FreddieTAFreeth/OH-EpiCap"), "and", tags$a("Carlijn Bogaardt's OH-EpiCap Tool GitHub Repository.", href="https://github.com/CarlijnB/OH-EpiCap"), "Feedback on the tool is welcome, you can e-mail this to Dr. Joaquin Prada (j.prada@surrey.ac.uk).")
                    ),
                    p("Please see the Legal page for the terms and conditions for the use of this tool.")
            ),
            #tabItem(tabName = "network",
            #        h2("Explore your Surveillance Network")
            #),
            tabItem(tabName = "instructions",
                    h2("How to Complete the OH-EpiCap Tool"),
                    p("The OH-EpiCap tool can be completed in two ways:"),
                    tags$ul(
                      tags$li("Manual completion of the questionnaire,"),
                      tags$li("Uploading pre-saved answers from a .csv file.")
                    ),
                    p("Note: to see the results and analysis of your surveillance capacity and capabilities, you must complete all questions of the questionnaire. Furthermore, for an in-depth tutorial, download the full OH-EpiCap tool guide here:", tags$a("The OH-EpiCap Tool Guide", href="OH-EpiCap_User guide_2022_06-03.pdf"),". Furthermore, the tool does not save your work automatically. Therefore, please ensure that your work is saved locally before closing the window."), 
                    box(
                      width = 12, status = "primary", collapsible = FALSE, solidHeader = TRUE,
                      title = "Manual Completion of the Questionnaire",
                      p("To start filling out the questionnaire, go to the sidebar on the left and click 'Questionnaire'. You will be required to answer the questions for each of the three dimensions, and you will be able to save your answers as a .csv file. You will then be able to view the analysis."),
                      p("The questionnaire should be completed by a panel of representatives from the different sectors across the entire surveillance chain, during a workshop. To facilitate the discussion, we recommend a panel with 8-10 participants from different disciplines and surveillance programs. A 4-hour time slot is recommended for the workshop."),
                      p("To start filling out the questionnaire, use the sidebar to navigate to the 'Questionnaire' tab and start completing each Target in each of the Dimensions. After completing all of the dimensions, you can save your answers as a downloadable file. To do this, navigate to the 'Save answers to file' tab and you can choose to save your answers as either a .csv file. Note that the tool does not save your work automatically, so please ensure you save your work before closing the window."),
                      p("Once the questionnaire has been completed, you may proceed to the 'Results' tab to view the analysis of your results. On the 'Benchmark' page, you can compare your results with a reference dataset."),
                      
                    ),
                    box(
                      width = 12, status = "primary", collapsible = FALSE, solidHeader = TRUE,
                      title = "Uploading a File",
                      p("If you have already completed the questionnaire, you may upload the .csv file you saved to view your results. To do this, navigate to the 'Upload Answers From File' tab, click the 'Browse' button and upload your saved file. Your answers will then be used in the analysis as if you completed the questionnaire manually.")
                    ),
                    box(width=12, solidHeader=TRUE, status="danger", collapsible=FALSE, title = "Disclaimer",
                        p("Please note that answers you submit to the questionnaire are not stored in a central database, and only used in generating a report.")
                    ),
                    p("Please continue to the questionnaire."),
            ),
            tabItem(tabName = "questionnaire",
                    h2("Complete The OH-EpiCap Questionnaire Here"),
            ),
            tabItem(tabName = "organization",
                    h2("Dimension 1: Organization"),
                    box(width=12,
                        p(tags$b("Dimension 1"), "deals with different aspects related to the ", tags$b("organization of the OH surveillance system.")),
                        p("It comprises four Target areas:"),
                        tags$ul(
                          tags$li(tags$b("Target 1.1 Formalization"),"includes questions about the objectives, supporting documentation, coordination roles, and leadership in the OH surveillance system."),
                          tags$li(tags$b("Target 1.2 Coverage"), "addresses whether the surveillance covers all relevant actors, disciplines, sectors, geography, populations, and hazards."),
                          tags$li(tags$b("Target 1.3 Resources"), "addresses questions linked to the availability of financial and human resources, training, and sharing of the available operational resources."),
                          tags$li(tags$b("Target 1.4 Evaluation and Resilience"), "focuses on internal and external evaluation, implementation of corrective measures, and the capacity of the OH surveillance system to adapt to changes.")
                        ),
                    ),
                    buildQuestionnaireUI(commands[commands$Dimension=='Dimension 1: Organization',])
            ),
            tabItem(tabName = "operations",
                    h2("Dimension 2: Operations"),
                    box(width=12,
                        p(tags$b("Dimension 2"), "deals with different aspects related to OH-ness in ", tags$b("operational activities of the OH surveillance system.")),
                        p("It comprises four Target areas:"),
                        tags$ul(
                        tags$li(tags$b("Target 2.1 Data collection and methods sharing"),"concerns the level of multisectoral collaboration in the design of surveillance protocols, data collection, harmonization of laboratory techniques and data warehousing."),
                        tags$li(tags$b("Target 2.2 Data sharing"), "addresses data sharing agreements, evaluation of data quality, use of shared data, and the compliance of data with the FAIR principle."),
                        tags$li(tags$b("Target 2.3 Data analysis and interpretation"), "addresses multisectoral integration for data analysis, sharing of statistical analysis techniques, sharing of scientific expertise, and harmonization of indicators."),
                        tags$li(tags$b("Target 2.4 Communication"), "focuses on both internal and external communication processes, dissemination to decision-makers, and information sharing in case of suspicion.")
                        ),
                    ),
                    buildQuestionnaireUI(commands[commands$Dimension=='Dimension 2: Operations',])
            ),
            tabItem(tabName = "impact",
                    h2("Dimension 3: Impact"),
                    box(width = 12,
                        p(tags$b("Dimension 3"), "deals with the", tags$b("impact of the OH surveillance system.")),
                        p("It comprises four Target areas:"),
                        tags$ul(
                          tags$li(tags$b("Target 3.1 Technical outputs"),"concerns the timely detection of emergence, knowledge improvement on hazard epidemiological situations, increased effectiveness of surveillance, and reduction of operational costs."),
                          tags$li(tags$b("Target 3.2 Collaborative added value"), "addresses strengthening of the OH team and network, international collaboration and common strategy (road map) design."),
                          tags$li(tags$b("Target 3.3 Immediate and intermediate outcomes"), "addresses advocacy, awareness, preparedness and interventions based on the information generated by the OH surveillance system."),
                          tags$li(tags$b("Target 3.4 Ultimate outcomes"), "focuses on research opportunities, policy changes, behavioral changes and better health outcomes that are attributed to the OH surveillance system.")
                        ),
                    ),
                    buildQuestionnaireUI(commands[commands$Dimension=='Dimension 3: Impact',])
            ),
            tabItem(tabName = "upload",
                    h2("Upload Questionnaire Answers From A File"),
                    p("Previously saved questionnaire answers, such as from a partially completed questionnaire, can be uploaded from file here. This allows the user to revisit or complete their answers, via the relevant Dimension pages. If the uploaded questionnaire is complete, results can also be visualised on the 'Results' page. Note that files not encoded in UTF-8, i.e. containing special characters, may cause unexpected behaviour."),
                    #questionnaireUploadUI("datafile", "Upload saved OH-EpiCap answers (.csv or .rds format)"),
                    questionnaireUploadUI("datafile", "Upload saved OH-EpiCap answers (.csv format)"),
            ),
            tabItem(tabName = "download",
                    h2("Save Questionnaire Answers to File"),
                    p("(Partially) completed questionnaires can be saved to a file, allowing the user to revisit or complete their answers at a later time. Files can be saved in .csv (human-readable) format."),
                    br(),
                    p("To upload a saved file and revisit the questionnaire answers, navigate to the 'Upload answers from file' page."),
                    questionnaireDownloadUI("downloadedAnswers", "Download OH-EpiCap questionnaire answers (.csv format)")
            ),
            tabItem(tabName = "results", resultsOutput("resultsPage")),
            tabItem(tabName = "createBenchmark",
                    h2("Create a Benchmark File"),
                    p("To compare your surveillance capacity and capabilities with respect to other surveillance programmes, you will need to create a benchmark file. Please select your completed questionnaire files from the drop down options. Continue to “Benchmark” tab for visualisation of results."),
                    box(width = 12, status = "primary", collapsible = FALSE, solidHeader = TRUE,
                        title = "Upload Your Questionnaire Files",
                        fileInput(input = "questionnaireFiles",
                                  label = "Select completed questionnaire files",
                                  multiple = TRUE,
                                  accept = c('text/csv', '.csv', 'text/comma-separated-values,text/plain')
                        )
                    ),
                    uiOutput("questionnaireFileViewer"),
                    conditionalPanel(condition="output.questionnaireFileViewer",
                                     downloadButton(outputId = 'createdBenchmark', 'Download your benchmark file'),
                    )
            ),
            tabItem(tabName = "benchmark", benchmarkUI("benchmarkPage", ref_datasets = ref_datasets)),
            tabItem(tabName = "glossary", glossaryOutput()),
            tabItem(tabName = "legal",
                    h2("Legal and Funding Information"),
                    p("We, the University of Surrey, permit You to use the tool accessed through this site and associated content and documentation, together the “Tool”, for free on the following basis. You may not, without prior written consent from us: use or communicate the Tool for commercial purposes, nor transfer, share or licence the Tool to any third party for commercial purposes; and/or use the Tool to create any software that is substantially similar in its expression to the Tool."),
                    p("The Tool is provided for general information only and all data inputs are only saved locally on Your machine. Outputs of the Tool are based on Your responses and should not be considered as advice on which You should rely. We make no representations, warranties or guarantees, whether express or implied, that use of the Tool will be uninterrupted or error-free, nor that the Tool will be free from vulnerabilities or viruses. The University of Surrey is not responsible or liable for the deletion of or failure to store any of Your information and other communications transmitted through Your use of the Tool. You are responsible and liable for complying with all applicable technology control or export laws and regulations that apply to Your use of the Tool."),
                    box(
                      width = 12, status = "primary", collapsible = FALSE, solidHeader = TRUE,
                      title = "Funding Statement",
                      p("The OH-EpiCap tool has received funding, through the One Health EJP, from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 773830.")
                    ),
                    h2("Data Management and Privacy"),
                    p("To comply with the European General Data Protection Regulation (GDPR), the OH-EpiCap team does not collect any data through the application, and the application does not ask any personal or identifying information regarding users or the surveillance system under evaluation. The application is hosted in the cloud with",tags$a("shinyapps.io",href="https://www.shinyapps.io"),"and questionnaire and benchmark data(files) are processed and temporarily stored on an external server for the duration of the user's session only. All data remain inaccessible to other users of the app. In cases where evaluating surveilliance systems using the online version of the tool is not appropriate, users are able to locally run the project either by downloading and running the files in", tags$a("Frederick T. A. Freeth's OH-EpiCap Tool GitHub Repository", href="https://github.com/FreddieTAFreeth/OH-EpiCap"), "in RStudio, or to run the standalone downloadable app availiable in the repository.")
            )
        )
    )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
    # Server logic for Create Benchmark begins here.
    # Multiple file input. Read in the question numbers from the first file and
    # create a new dataframe newBenchmark. We sort the question numbers for extra
    # safety in case files get their rows mixed up.
    benchmarkFile <- reactive({
        inFiles <- lapply(input$questionnaireFiles$datapath, fread)
        
        # Setup data structures.
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
        
        newBenchmark <- as.data.frame(matrix(0, nrow = length(questionNums), ncol = 4))
        colnames(newBenchmark) <- c("Question", "Value", "Low", "High")
        newBenchmark[,1] <- questionNums
        
        # Loop through each question in the benchmark file, find where that is
        # located in the uploaded file (in case questions are somehow reordered)
        # and then calculate the quartiles of each question across file and then
        # add this to the newBenchmark file.
        for(i in 1:nrow(newBenchmark)){
            Values <- rep(0, times = length(inFiles))
            for(j in 1:length(inFiles)){
                questionNumInFile = which(questionNums[i] == inFiles[[j]][[1]])
                Values[j] = inFiles[[j]][[2]][questionNumInFile]
            }
            # Add the mean, min and high quantile values to new benchmark file.
            newBenchmark[i,2] = quantile(as.numeric(Values), na.rm=T)[3] # 50% Median -> "Value"
            newBenchmark[i,3] = quantile(as.numeric(Values), na.rm=T)[2] # 25% Low -> "Low"
            newBenchmark[i,4] = quantile(as.numeric(Values), na.rm=T)[4] # 75% High -> "High"
        }
        return(newBenchmark)
    })
    
    # Server logic the table of uploaded files
    output$fileDirectory <- renderTable(
      {
        if(is.null(benchmarkFile())){return()}
        input$questionnaireFiles[[1]] # Just want the names of uploaded files.
      },
      rownames = TRUE,
      colnames = FALSE,
      striped = TRUE,
      hover = TRUE,
      bordered = TRUE,
      align = 'r', # Right align so the extensions are easier to see.
    )
    
    output$displayFile <- renderTable(
      {
        if(is.null(benchmarkFile)){return()}
        benchmarkFile()
      },
      striped = TRUE,
      hover = TRUE,
      bordered = TRUE,
      align = 'c',
    )
    
    # UI for the table of uploaded files
    output$questionnaireFileViewer <- renderUI({
      inFiles <- lapply(input$questionnaireFiles$datapath, fread)
      validate(need(!is.null(input$questionnaireFiles), message="Please upload your questionnaire file(s). You will see your uploaded files here."))
      
      # Check if all files are completed and if they have the right dimension:
      unsuitableFileNums <- rep(0, length(inFiles)) # Assume all files are suitable
      incompleteFileNums <- rep(0, length(inFiles)) # Assume all files are complete
      for(i in 1:length(inFiles)){
        
        # Locate which files have incorrect dimension and entries. We expect these files to contain
        # two columns, one with 'Question' and another with 'Value' with each value being one of 
        # a string of NULL, NA, 1, 2, 3, or 4.
        if(FALSE %in% c(nrow(inFiles[[i]]) == 96, ncol(inFiles[[i]]) == 2,
           all(inFiles[[i]][which(grepl("Q", inFiles[[i]][[1]]))][[2]] %in% c("NULL", NA, "1", "2", "3", "4")))){
          unsuitableFileNums[i] = 1
          # Locate which files have incomplete questions. NULL is saved as "NULL" in Questionnaire.
        } else if("NULL" %in% inFiles[[i]][which(grepl("Q", inFiles[[i]][[1]]))][[2]]){
          incompleteFileNums[i] = 1
        }
      }
      
      # Show user which questionnaire files have not been completed or are of the wrong format.
      if(sum(unsuitableFileNums) != 0){
        validate(
          paste("The following questionnaire file(s) do not have the expected format: \n",
                paste(input$questionnaireFiles[[1]][which(unsuitableFileNums != 0)], collapse="\n"),
                "\nWe expect there to be two columns; one for the question number, and one for the value. Each value should be one of 'NA', '1', '2', '3' or '4'",
                "\n", sep = ""
          )
        )
      } else if(sum(incompleteFileNums) != 0){
        validate(
          paste("The following questionnaire file(s) have the correct format but are incomplete: \n",
                paste(input$questionnaireFiles[[1]][which(incompleteFileNums != 0)], collapse="\n"),
                "\nPlease upload them under the Questionnaire tab to complete them and try again.",
                "\n", sep = ""
          )
        )
      }
      # Display the successfully uploaded files in a table,
      box(width = 12, solidHeader = TRUE, status = "primary", collapsible = FALSE,
          title = "Uploaded Files",
          tableOutput("fileDirectory")
      )
    })
    
    outputOptions(output, "questionnaireFileViewer", suspendWhenHidden = FALSE)
    
    # Download the new benchmark file
    output$createdBenchmark <- downloadHandler(
        filename = function(){paste("Benchmark_File_", Sys.Date(), ".csv", sep="")},
        content = function(file){
          write.csv(benchmarkFile(), file, row.names=FALSE, fileEncoding = "UTF-8") # Forces UTF-8 encoding.
        }
    )
    # Server logic for Create Benchmark ends here.
    
    
    
    #lists of input names associated with questions and comments
    question_inputs <- reactive(grep(pattern="Q[[:digit:]]", x=names(input), value=TRUE))
    comment_inputs <- reactive(grep(pattern="C[[:digit:]]", x=names(input), value=TRUE))
    
    ### tabName "download" --- download completed questionnaire as rds or csv file
    inputlist <- reactive({
        sapply(c(question_inputs(),comment_inputs()), function(x) input[[x]], USE.NAMES = TRUE)
    })
    downloadedAnswers <- questionnaireDownloadServer("downloadedAnswers", stringsAsFactors = FALSE,inputlist=inputlist)
    
    ### restoring questionnaire state
    state<-questionnaireUploadServer("datafile", stringsAsFactors = FALSE)
    observeEvent(state(),{
        sapply(question_inputs(), function(x){updateRadioButtons(session,inputId=x,selected=state()[[x]])})
        sapply(comment_inputs(), function(x){updateTextInput(session,inputId=x,value=state()[[x]])})
    })

    ### scoring the questionnaire 
    # extracting questionnaire choices, and adding them to the questionnaire dataframe
    questionnaire_w_values <- addScores2Questionnaire(input,questionnaire) #by sticking everything into one df, all wrangling + plotting code has to be rerun as soon as I change 1 value 
    # summarising scores by target for all dimensions, and by indicator for each dimension separately
    scores_dimensions<-reactive(scoringTable(questionnaire_w_values(), "dimensions"))
    scores_targets<-reactive(scoringTable(questionnaire_w_values(), "targets"))
    scores_indicators<-reactive(scoringTable(questionnaire_w_values(), "indicators"))
    
    ### creating the Results page (with gauges, plots, and associated texts)
    resultsServer("resultsPage", scores_targets=scores_targets, scores_indicators=scores_indicators, scores_dimensions=scores_dimensions,stringsAsFactors = FALSE)
    
    ### creating the Benchmarking page (with plots and associated texts)
    benchmarkServer("benchmarkPage", scores_targets=scores_targets, scores_indicators=scores_indicators, stringsAsFactors = FALSE)
    }

shinyApp(ui, server)
