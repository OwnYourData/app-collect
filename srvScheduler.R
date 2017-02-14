# functions for setting up recurring tasks
# last update:2016-10-13

readSchedulerItems <- reactive({
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], schedulerKey)
                allItems <- readItems(app, url)
                if(nrow(allItems) == 0){
                        data.frame()
                } else {
                        allItems[allItems$app == app[['app_key']] & 
                                 !is.na(allItems$app), ]
                }
        } else {
                data.frame()
        }
})

readSchedulerItemsFunction <- function(){
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], schedulerKey)
                allItems <- readItems(app, url)
                if(nrow(allItems) == 0){
                        data.frame()
                } else {
                        allItems[allItems$app == app[['app_key']] & 
                                         !is.na(allItems$app), ]
                }
        } else {
                data.frame()
        }
}

writeSchedulerRscript <- function(app, app_name, rScript, time, repo, active, id){
        rScript_fields <- list(
                date='Date.now',
                value='Rscript.result'
        )
        rScript_structure <- list(
                repo=repo,
                repoName=app_name,
                fields=rScript_fields
        )
        response_structure <- list(
                rScript_structure
        )
        save(app, app_name, rScript, time, repo, active, rScript_fields, rScript_structure, response_structure, file='tmpWrite.RData')
        parameters <- list(Rscript_base64     = base64Encode(rScript),
                           response_structure = response_structure,
                           pia_url            = app[['url']],
                           app_key            = app[['app_key']],
                           app_secret         = app[['app_secret']])
        config <- list(app            = app[['app_key']],
                       time           = time,
                       task           = 'Rscript',
                       active         = active,
                       parameters     = parameters,
                       '_oydRepoName' = 'Scheduler')
        if(missing(id)) {
                writeItem(app,
                          itemsUrl(app[['url']], schedulerKey),
                          config)
        } else {
                updateItem(app, 
                           itemsUrl(app[['url']], schedulerKey), 
                           config,
                           id)
        }
}
