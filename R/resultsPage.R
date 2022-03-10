# Module UI function
resultsOutput <- function(id, label = "results") {
  # `NS(id)` returns a namespace function, which was save as `ns` and will
  # invoke later.
  ns <- NS(id)
  
  tagList(
    h2("Visualise your EU-EpiCap profile"),
    fluidRow(
      box(width=12,
          p("This page visually summarises the interactively completed, or uploaded, EU-EpiCap profile.")
       )),
    fluidRow(
      box(width=12,
          title="EU-EpiCap Index and Dimensions",
          solidHeader=TRUE, status="success",
          collapsible=TRUE, collapsed=FALSE,
          p("EU-EpiCap and Dimension indices represent mean scores over all component questions, expressed as percentages."),
          textOutput(ns("restxt_overall")),
          fluidRow(column(4),
                   valueBoxOutput(ns("indexBox")),
                   column(4)),
          fluidRow(valueBoxOutput(ns("organizationBox")),
                   valueBoxOutput(ns("operationsBox")),
                   valueBoxOutput(ns("impactBox")))
          )),
    fluidRow(
      box(width=12,
          title="Targets",
          solidHeader=TRUE, status="info",
          collapsible=TRUE, collapsed=FALSE,
          p("Scores range 1-4, with higher values suggesting better adherence to the One Health principle (better integration of sectors), and lower values suggesting improvements may be required. Users are encouraged to hover over plotted data points to view breakdowns of scores."),
          textOutput(ns("restxt_targets")),
          fluidRow(column(6, girafeOutput(ns("lollipop_tar"))),
                   column(6, girafeOutput(ns("radar_all"))))
          )),
    fluidRow(
      box(width=12,
          title="Dimension 1: Organization",
          solidHeader=TRUE, status="warning",
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6, 
                   p("Scores range 1-4, with higher values suggesting better adherence to the One Health principle (better integration of sectors), and lower values suggesting improvements may be required. Greyed-out Indicators labels indicate a question was answered with NA. Users are encouraged to hover over plotted data points to view the wording of the chosen indicator level, and any comments that may have been added in connection with particular questions."),
                   textOutput(ns("restxt_dim1"))),
            column(6, girafeOutput(ns("radar_1"))))
          )),
    fluidRow(
      box(width=12,
          title="Dimension 2: Operations",
          solidHeader=TRUE, status="primary",
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6, 
                   p("Scores range 1-4, with higher values suggesting better adherence to the One Health principle (better integration of sectors), and lower values suggesting improvements may be required. Greyed-out Indicators labels indicate a question was answered with NA. Users are encouraged to hover over plotted data points to view the wording of the chosen indicator level, and any comments that may have been added in connection with particular questions."),
                   textOutput(ns("restxt_dim2"))),
            column(6, girafeOutput(ns("radar_2"))))
          )),
    fluidRow(
      box(width=12,
          title="Dimension 3: Impact",
          solidHeader=TRUE,
          collapsible=TRUE, collapsed=TRUE,
          fluidRow(
            column(6,
                   p("Scores range 1-4, with higher values suggesting better adherence to the One Health principle (better integration of sectors), and lower values suggesting improvements may be required. Greyed-out Indicators labels indicate a question was answered with NA. Users are encouraged to hover over plotted data points to view the wording of the chosen indicator level, and any comments that may have been added in connection with particular questions."),
                   textOutput(ns("restxt_dim3"))),
            column(6, girafeOutput(ns("radar_3"))))
          ))
  )
}

resultsServer <- function(id, scores_targets=scores_targets, scores_indicators=scores_indicators, scores_dimensions=scores_dimensions, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      #value boxes
      EUEpiCap_index<-reactive({(mean(scores_dimensions()$value, na.rm=TRUE)-1)*100/3})
      organization_index<-reactive({(scores_dimensions()$value[1]-1)*100/3})
      operations_index<-reactive({(scores_dimensions()$value[2]-1)*100/3})
      impact_index<-reactive({(scores_dimensions()$value[3]-1)*100/3})
      output$indexBox <- renderValueBox({valueBox(paste0(round(EUEpiCap_index(), 0),"%"), "EU-EpiCap Index", icon= icon("thumbs-up", lib = "glyphicon"), color = "green")})
      output$organizationBox <- renderValueBox({valueBox(paste0(round(organization_index(), 0),"%"), "Dimension 1: Organization", icon= icon("thumbs-up", lib = "glyphicon"), color = "orange")})
      output$operationsBox <- renderValueBox({valueBox(paste0(round(operations_index(), 0),"%"), "Dimension 2: Operations", icon= icon("thumbs-up", lib = "glyphicon"), color = "blue")})
      output$impactBox <- renderValueBox({valueBox(paste0(round(impact_index(), 0),"%"), "Dimension 3: Impact", icon= icon("thumbs-up", lib = "glyphicon"), color = "black")})
      #generate plots
      #output$lollipop_dim <- renderGirafe(makeLollipopPlot(scores_dimensions(),"Dimensions"))
      output$lollipop_tar <- renderGirafe(makeLollipopPlot(scores_targets(),"Targets"))
      #output$lollipop_1 <- renderGirafe(makeLollipopPlot(scores_indicators()[1:20,],"Indicators")) #Dimension-specific lollipop plots need labels based on target + short indicator name
      output$radar_all <- renderGirafe(makeRadarPlot_results(scores_targets(),3))
      output$radar_1 <- renderGirafe(makeRadarPlot_results(scores_indicators()[1:20,],4))
      output$radar_2 <- renderGirafe(makeRadarPlot_results(scores_indicators()[21:40,],4))
      output$radar_3 <- renderGirafe(makeRadarPlot_results(scores_indicators()[41:60,],4))
      #generate result texts
      output$restxt_overall <- renderText({"Sample text. Foo"})
      output$restxt_targets <- renderText({"Sample text. Best Dim score is"})
      output$restxt_dim1 <- renderText({"Sample text. Best Target score is "})
      output$restxt_dim2 <- renderText({"Sample text. Best Target score is "})
      output$restxt_dim3 <- renderText({"Sample text. Best Target score is "})
    }
  )    
}