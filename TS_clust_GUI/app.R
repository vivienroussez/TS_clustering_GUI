#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(dplyr)
library(tidyr)
library(shiny)
library(ggplot2)
library(plotly)
library(lubridate)

ex_long <- expand.grid(time=1:5,ID=paste0("ID",1:4)) %>% 
  mutate(KPI1=rnorm(20),KPI2=rnorm(20,10,20),KPI3=rnorm(20,100,200))


ui <- navbarPage("Time series clustering - GUI",
                 tabPanel("Introduction",
                          fluidPage(
                            h3("Presentation"),
                            textOutput("presentation"),
                            h3("Instructions - expected data format"),
                            textOutput("instructions"),
                            tableOutput("example")
                          )),
                 tabPanel("Clustering tool",
                          fluidRow(
                            column(4,
                                   wellPanel(
                                     fileInput("file1", "Choose CSV File",
                                               accept = c(
                                                 "text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")
                                     ),
                                     radioButtons("separator","Separator",c("Comma"=",","Semicolon"=";"),inline = T),
                                     radioButtons("decimal","Decimal separator",c("Dot"=".","Comma"=","),inline = T),
                                     uiOutput("ind_var"),
                                     uiOutput("time_var"),
                                     uiOutput("kpi_var"),
                                     radioButtons("date_form","Time variable format is",list(Date="T",Numerical=F),inline = T),
                                     uiOutput("n_series"),
                                     radioButtons("norm","Normalize data",list(Yes=T,No=F),inline = T),
                                     numericInput("n_clust","Number of clusters",5),
                                     actionButton("compute","Cluster now !"),
                                     downloadButton("downloadData", "Download results")
                                     
                                   )
                            ),
                            column(8,
                                   h3("Original series"),
                                   plotOutput("original"),
                                   h3("Clusters centers"),
                                   plotlyOutput("plot_centers")
                            )
                            
                          )
                 )
)


server <- function(input, output) {
  
  output$presentation <- renderText({"
    This tool is a graphical interface allowing to cluster time series. 
    If you observe individuals' behavior (customers, network cells, devices...) over time, 
    clustering them with respect to this time dimension allows you to find common patterns among them."})
  
  output$instructions <- renderText({"
    Please provide the input data according to the following schema : one column identifying the 
    individuals you want to cluster, one for the time feature, 
    and one or more KPIs you want to cluster individual with respect to. The variable identifying time 
    can be provided in date format (that can be parsed by lubridate::as_date) or a generic numerical variable "})
  output$example <- renderTable(ex_long)
  
  dat <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header = TRUE)
    return(data)
  })
  
  output$time_var <- renderUI({
    selectizeInput("time_var","Time variable",names(dat()))
  })
  output$ind_var <- renderUI({
    selectizeInput("ind_var","Individual identificator",names(dat()))
  })
  output$kpi_var <- renderUI({
    selectizeInput("kpi_var","KPI to use",names(dat()))
  })
  
  output$n_series <- renderUI({
    numericInput("n_series","Number of series to plot",length(unique(dat()[,input$ind_var])))
  })
  
  prepare_dat <- eventReactive(input$compute,{
    # rename inputs for easier use
    dd <- dat() %>% 
      rename_at(c(input$ind_var,input$time_var,input$kpi_var),function(xx) c("ID","TIME","KPI"))
    if (input$norm) {
      dd <- group_by(dd,ID) %>% 
        mutate(KPI = (KPI-mean(KPI,na.rm = T))/sd(KPI,na.rm = T)) %>% 
        ungroup()
    }
    if (input$date_form) {
      dd <- mutate(dd,TIME=as_date(TIME))
    }
    dd <- select(dd,ID,TIME,KPI) %>% 
      arrange(ID,TIME) %>% 
      spread(key = TIME,value = KPI)
    return(dd)
  })
  
  clust <- reactive({
    cc <- prepare_dat() %>% 
      select(-ID) %>% 
      kmeans(input$n_clust)
    return(cc)
  })
  
  output$original <- renderPlot({
    if (input$date_form) {ff <- as_date} else {ff <- as.numeric}
    sel <- sample(unique(dat()[,input$ind_var]),size = input$n_series,replace = F)
    prepare_dat() %>% 
      filter(ID %in% sel) %>% 
      gather(key=TIME,value=KPI,-ID) %>% 
      mutate(TIME=ff(TIME)) %>% 
      ggplot(aes(TIME,KPI,group=ID)) + geom_line(col="blue") + theme_light()
  })
  
  output$plot_centers <- renderPlotly({
    cc <- clust()
    if (input$date_form) {ff <- as_date} else {ff <- as.numeric}
    cc$centers %>% as.data.frame() %>% 
      mutate(cl = row_number()) %>% 
      gather(key = "Time",value = "KPI",-cl) %>% 
      mutate(cluster = paste0("Cluster ",cl),Time=ff(Time)) %>% 
      ggplot(aes(Time,KPI,color=cluster)) + geom_line() + theme_light()
  })
  
  output$test <- renderDataTable({
    final_dat() 
  })
  
  final_dat <- reactive({
    cc <- clust()
    dd <- prepare_dat() %>% 
      mutate(cluster=cc[["cluster"]]) %>% 
      gather(key="TIME",value = "KPI",-ID,-cluster)
    return(dd)
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("Clustered", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(final_dat(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)