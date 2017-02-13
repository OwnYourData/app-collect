# data import for Collectors
# last update: 2017-02-13

# get stored Collectors
readCollectorItems <- function(){
        app <- currApp()
        collectorItems <- data.frame()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.collectors'))
                collectorItems <- readItems(app, url)
                if(nrow(collectorItems) > 0){
                        rownames(collectorItems) <- collectorItems$name
                        collectorItems <- collectorItems[, c('rScript',
                                                             'frequency',
                                                             'repo',
                                                             'active')]
                }
        }
        collectorItems
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
        save(selItem, allItems, selItemRepo, file='tmpIntermediate.RData')
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
        errMsg   <- ''
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
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']],
                                       '.collectors'))
                data <- list(name      = itemName,
                             rScript   = itemRscript,
                             frequency = itemFreq,
                             repo      = itemRepo,
                             active    = itemActive)
                data$`_oydRepoName` <- 'Datenquellen'
                writeItem(app, url, data)
                initNames <- rownames(allItems)
                allItems$rScript <- as.character(allItems$rScript )
                allItems$frequency <- as.character(allItems$frequency)
                allItems$repo <- as.character(allItems$repo)
                allItems$active <- as.logical(allItems$active)
                allItems <- rbind(allItems, c(itemRscript, 
                                              itemRepo))
                
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
                url <- itemsUrl(app[['url']],
                                paste0(app[['app_key']],
                                       '.collectors'))
                data <- list(name      = itemName,
                             rScript   = itemRscript,
                             frequency = itemFreq,
                             repo      = itemRepo,
                             active    = itemActive)
                collectorItems <- readItems(app, url)
                id <- collectorItems[collectorItems$name == selItem, 'id']
                updateItem(app, url, data, id)
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
                                paste0(app[['app_key']],
                                       '.collectors'))
                collectorItems <- readItems(app, url)
                id <- collectorItems[collectorItems$name == selItem, 'id']
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
})

observeEvent(input$importCollectorList, {
        errMsg  <- ''
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
                result <- eval(parse(text = rScript))
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
                        errMsg <- 'Das R-Skript lieferte keinen Rückgabewert und es wurden keine Daten gespeichert.'
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
                createAlert(session, 'taskInfo', 
                            'mySensorItemStatus',
                            title = 'Aktion erfolgreich',
                            content = succMsg,
                            style = 'info',
                            append = 'false')
        }
})
        