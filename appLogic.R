# application specific logic
# last update: 2016-10-07

source('srvDateselect.R', local=TRUE)
source('srvEmail.R', local=TRUE)
source('srvScheduler.R', local=TRUE)

source('appLogicCollectors.R', local=TRUE)

# any record manipulations before storing a record
appData <- function(record){
        record
}

getRepoStruct <- function(repo){
        appStruct[[repo]]
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
}