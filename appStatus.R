# layout for section "Status"
# last update: 2016-10-10

source('appStatusSelect.R')
source('appStatusTagCloud.R')
source('appStatusLineGraph.R')

appStatus <- function(){
        fluidRow(
                column(12, 
                       # uiOutput('desktopUiStatusItemsRender')
                       appStatusSelect(),
                       bsAlert('dataStatus'),
                       tabsetPanel(type='tabs',
                                   appStatusTagCloud(),
                                   appStatusLineGraph()
                       )
                )
        )
}

# constants for configurable Tabs
# defaultStatTabsName <- c('Plot')
# 
# defaultStatTabsUI <- c(
#         "
#         tabPanel('Plot',
#                  plotOutput(outputId = ns('bank2Plot'), height = '300px')
#         )
#         "
# )
# 
# defaultStatTabsLogic <- c(
#         "
#         output$bank2Plot <- renderPlot({
#                 data <- currData()
#                 plot(x=data$date, y=data$value, type='l', 
#                         xlab='Datum', ylab='Euro')
#         
#         })
#         "
# )
