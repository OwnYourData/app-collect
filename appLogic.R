# application specific logic
# last update: 2016-10-07

source('srvDateselect.R', local=TRUE)
source('srvEmail.R', local=TRUE)
source('srvScheduler.R', local=TRUE)

source('appLogicCollectors.R', local=TRUE)
source('appLogicTagCloud.R', local=TRUE)
source('appLogicLineGraph.R', local=TRUE)

# any record manipulations before storing a record
appData <- function(record){
        record
}

getRepoStruct <- function(repo){
        if(repo == 'Verlauf') {
                appStruct[[repo]]
        } else {
                list(
                        fields = c('timestamp', 'value'),
                        fieldKey = 'timestamp',
                        fieldTypes = c('timestamp', 'number'),
                        fieldInits = c('empty', 'empty'),
                        fieldTitles = c('Zeit', 'Wert'),
                        fieldWidths = c(150, 450))
        }
}

repoData <- function(repo){
        data <- data.frame()
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']],
                                repo)
                data <- readItems(app, url)
        }
        data
}

appStart <- function(){
        allItems <- readCollectorItems()
        updateSelectInput(session, 'collectorList',
                          choices = rownames(allItems))
        collectorList()
}

currDataSelection <- reactive({
        closeAlert(session, 'myDataStatus')
        allItems <- readCollectorItems()
        repo <- allItems[rownames(allItems) == input$statusRepoSelect, 'repo']
        data <- repoData(repo)
        if(nrow(data) == 0) {
                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                            style = 'warning', append = FALSE,
                            title = 'Keine Daten im gewählten Zeitfenster',
                            content = 'Für das ausgewählte Zeitfenster sind keine Daten vorhanden.')
                data <- data.frame()
        } else {
                data$dat <- as.Date(as.POSIXct(as.integer(data$timestamp), 
                                               origin='1970-01-01')) 
                dataMin <- min(data$dat, na.rm=TRUE)
                dataMax <- max(data$dat, na.rm=TRUE)
                curMin <- as.Date(input$dateRange[1], '%d.%m.%Y')
                curMax <- as.Date(input$dateRange[2], '%d.%m.%Y')
                daterange <- seq(curMin, curMax, 'days')
                data <- data[as.Date(data$dat) %in% daterange, ]
                if(nrow(data) == 0){
                        createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                                    style = 'warning', append = FALSE,
                                    title = 'Keine Daten im gewählten Zeitfenster',
                                    content = 'Für das ausgewählte Zeitfenster sind keine Daten vorhanden.')
                }
        }
        data
})

wordcloud_rep <- repeatable(wordcloud)

output$tagCloud <- renderPlot({
        v <- getTermMatrix()
        if(length(v) > 1){
                wordcloud_rep(names(v), v,
                              scale=c(4,0.5),
                              min.freq = input$freq, 
                              max.words= input$max,
                              colors=brewer.pal(8, "Dark2"))
        }
})

output$lineChart <- renderPlotly({
        data <- currDataSelection()
        linePlotly(data)
})
