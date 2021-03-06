# data import for Collectors
# last update: 2017-02-13

# get stored Collectors
readCollectorItems <- function(){
        app <- currApp()
        collectorItems <- data.frame()
        if(length(app) > 0){
                retVal <- readSchedulerItemsFunction()
                if(nrow(retVal) > 0){
                        paramDF <- do.call(bind_rows, 
                                           lapply(retVal$parameters, 
                                                  function(x) data.frame(t(sapply(x,c)), stringsAsFactors = FALSE)))
                        respStructDF <- do.call(bind_rows,
                                                lapply(paramDF$response_structure,
                                                       function(x) data.frame(t(sapply(x,c)), stringsAsFactors = FALSE)))
                        collectorItems <- cbind(retVal, paramDF, respStructDF)
                        rownames(collectorItems) <- collectorItems$repoName
                        collectorItems$rScript <- lapply(collectorItems$Rscript_base64, 
                                                         function(x) if(nchar(as.character(x)) < 2){
                                                                 ''
                                                         } else {
                                                                 base64Decode(x)
                                                         })
                        collectorItems <- collectorItems[, c('rScript',
                                                             'time',
                                                             'repo',
                                                             'active',
                                                             'id')]
                        colnames(collectorItems) <- c('rScript',
                                                      'frequency',
                                                      'repo',
                                                      'active',
                                                      'id')
                }
        }
        collectorItems
}

collectorList <- function(){
        allItems <- readCollectorItems()
        colRepos <- vector()
        if(nrow(allItems) > 0){
                colRepos <- rownames(allItems)
        } else {
                colRepos <- c('keine Datenquellen vorhanden')
        }
        updateSelectInput(
                session,
                'statusRepoSelect',
                choices = colRepos,
                selected = colRepos[1])
        appRepos <<- append(appReposDefault,
                            setNames(as.character(allItems$repo),
                                     as.list(rownames(allItems))))
        updateSelectInput(
                session,
                'repoSelect',
                choices = names(appRepos),
                selected = 'Verlauf')
}

# show attributes on selecting an item in the Collector list
observeEvent(input$collectorList, {
        selItem <- input$collectorList
        if(length(selItem)>1){
                selItem <- selItem[1]
                updateSelectInput(session, 'collectorList', selected = selItem)
        }
        allItems <- readCollectorItems()
        selItemName <- selItem
        selItemRscript <- allItems[rownames(allItems) == selItem, 'rScript']
        selItemFreq <- allItems[rownames(allItems) == selItem, 'frequency']
        selItemRepo <- allItems[rownames(allItems) == selItem, 'repo']
        selItemActive <- allItems[rownames(allItems) == selItem, 'active']
        updateTextInput(session, 'collectorItemName',
                        value = selItemName)
        updateTextInput(session, 'collectorItemRscript',
                        value = trim(as.character(selItemRscript)))
        updateTextInput(session, 'collectorItemFrequency',
                        value = trim(as.character(selItemFreq)))
        updateTextInput(session, 'collectorItemRepo',
                        value = trim(as.character(selItemRepo)))
        updateCheckboxInput(session, 'collectorItemActive',
                            value = selItemActive)
})

observeEvent(input$addCollectorItem, {
        errMsg <- ''
        itemName    <- input$collectorItemName
        itemRscript <- input$collectorItemRscript
        itemFreq    <- input$collectorItemFrequency
        itemRepo    <- input$collectorItemRepo
        itemActive  <- input$collectorItemActive
        
        allItems <- readCollectorItems()
        if(itemName %in% rownames(allItems)){
                errMsg <- 'Name bereits vergeben'
        }
        if(errMsg == ''){
                app <- currApp()
                writeSchedulerRscript(app,
                                      itemName,
                                      itemRscript,
                                      itemFreq,
                                      itemRepo,
                                      itemActive)
                initNames <- rownames(allItems)
                updateSelectInput(session, 'collectorList',
                                  choices = c(initNames, itemName),
                                  selected = NA)
                updateTextInput(session, 'collectorItemName',
                                value = '')
                updateTextInput(session, 'collectorItemRscript',
                                value = '')
                updateTextInput(session, 'collectorItemFrequency',
                                value = '')
                updateTextInput(session, 'collectorItemRepo',
                                value = '')
                updateCheckboxInput(session, 'collectorItemActive',
                                    value = FALSE)
        }
        closeAlert(session, 'myCollectorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myCollectorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        collectorList()
})

observeEvent(input$updateCollectorItem, {
        errMsg  <- ''
        selItem <- input$collectorList
        itemName    <- input$collectorItemName
        itemRscript <- input$collectorItemRscript
        itemFreq    <- input$collectorItemFrequency
        itemRepo    <- input$collectorItemRepo
        itemActive  <- input$collectorItemActive
        if(is.null(selItem)){
                errMsg <- 'Keine Quelle ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readCollectorItems()
                app <- currApp()
                id <- allItems[rownames(allItems) == selItem, 'id']
                writeSchedulerRscript(app,
                                      itemName,
                                      itemRscript,
                                      itemFreq,
                                      itemRepo,
                                      itemActive,
                                      id)
                newRowNames <- rownames(allItems)
                newRowNames[newRowNames == selItem] <- itemName
                updateSelectInput(session, 'collectorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'collectorItemName',
                                value = '')
                updateTextInput(session, 'collectorItemRscript',
                                value = '')
                updateTextInput(session, 'collectorItemFrequency',
                                value = '')
                updateTextInput(session, 'collectorItemRepo',
                                value = '')
                updateCheckboxInput(session, 'collectorItemActive',
                                    value = FALSE)
        }
        closeAlert(session, 'myCollectorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myCollectorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        collectorList()
})

observeEvent(input$delCollectorList, {
        errMsg  <- ''
        selItem <- input$collectorList
        if(is.null(selItem)){
                errMsg <- 'Keine Quelle ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readCollectorItems()
                newRowNames <- rownames(allItems)
                app <- currApp()
                url <- itemsUrl(app[['url']],
                                schedulerKey)
                id <- allItems[rownames(allItems) == selItem, 'id']
                deleteItem(app, url, id)
                newRowNames <- newRowNames[newRowNames != selItem]
                allItems <- allItems[rownames(allItems) != selItem, ]
                updateSelectInput(session, 'collectorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'collectorItemName',
                                value = '')
                updateTextInput(session, 'collectorItemRscript',
                                value = '')
                updateTextInput(session, 'collectorItemFrequency',
                                value = '')
                updateTextInput(session, 'collectorItemRepo',
                                value = '')
                updateCheckboxInput(session, 'collectorItemActive',
                                    value = FALSE)
        }
        closeAlert(session, 'myCollectorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myCollectorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        collectorList()
})

observeEvent(input$importCollectorList, {
        errMsg  <- ''
        succMsg  <- ''
        selItem <- input$collectorList
        if(is.null(selItem)){
                errMsg <- 'Keine Quelle ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readCollectorItems()
                selItemName <- selItem
                selItemRscript <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'rScript']))
                selItemRepo <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'repo']))
                rScript <- gsub('\\R', '\n', selItemRscript, perl=TRUE)
                eval(parse(text = rScript))
                if(length(result) > 1){
                        app <- currApp()
                        url <- itemsUrl(app[['url']], selItemRepo)
                        data <- list(
                                timestamp = as.integer(Sys.time()),
                                value = intToUtf8(result),
                                '_oydRepoName' = selItemName
                        )
                        writeItem(app, url, data)
                        succMsg <- 'Daten wurden erfolgreich gespeichert.'
                } else {
                        if(length(result) == 1){
                                app <- currApp()
                                url <- itemsUrl(app[['url']], selItemRepo)
                                data <- list(
                                        timestamp = as.integer(Sys.time()),
                                        value = as.integer(result),
                                        '_oydRepoName' = selItemName
                                )
                                writeItem(app, url, data)
                                succMsg <- 'Daten wurden erfolgreich gespeichert.'
                        } else {
                                errMsg <- 'Das R-Skript lieferte keinen Rückgabewert und es wurden keine Daten gespeichert.'
                        }
                }
        }
        closeAlert(session, 'myCollectorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myCollectorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        if(succMsg != ''){
                writeLog(paste0('Import für Datenquelle ',
                                selItem,
                                ' durchgeführt.'))
                createAlert(session, 'taskInfo', 
                            'mySensorItemStatus',
                            title = 'Aktion erfolgreich',
                            content = succMsg,
                            style = 'info',
                            append = 'false')
        }
})
        