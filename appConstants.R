# global constants available to the app
# last update:2016-01-17

# constants required for every app
appName <- 'collect'
appTitle <- 'Online Daten'
app_id <- 'eu.ownyourdata.collect'

# definition of data structure
currRepoSelect <- ''
appRepos <- list(Vorlage = 'eu.ownyourdata.collect',
                 Verlauf = 'eu.ownyourdata.collect.log')
appStruct <- list(
        Vorlage = list(
                fields      = c('text'),
                fieldKey    = 'text',
                fieldTypes  = c('string'),
                fieldInits  = c('empty'),
                fieldTitles = c('Text'),
                fieldWidths = c(600)),
        Verlauf = list(
                fields      = c('date', 'description'),
                fieldKey    = 'date',
                fieldTypes  = c('date', 'string'),
                fieldInits  = c('empty', 'empty'),
                fieldTitles = c('Datum', 'Text'),
                fieldWidths = c(150, 450)))

# Version information
currVersion <- "0.3.0"
verHistory <- data.frame(rbind(
        c(version = "0.3.0",
          text    = "erstes Release")
))

# app specific constants
collectorUiList <- vector()