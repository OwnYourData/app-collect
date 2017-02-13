# UI for configuring collectors
# last update: 2017-02-13

appSourceCollectors <- function(){
        tabPanel('Online Datenquellen',
                 br(),
                 helpText('Konfiguriere hier die vorhandenen Datenquellen.', style='display:inline'), 
                 br(), br(),
                 fluidRow(
                         column(4,
                                selectInput('collectorList',
                                            'Quellen:',
                                            collectorUiList,
                                            multiple=TRUE, 
                                            selectize=FALSE,
                                            size=12),
                                actionButton('delCollectorList', 'Entfernen', 
                                             icon('trash')),
                                actionButton('importCollectorList', 'Jetzt Sammeln',
                                             icon('download'))),
                         column(8,
                                textInput('collectorItemName',
                                          'Name:',
                                          value = ''),
                                tags$label('R-Script:'),
                                br(),
                                tags$textarea(id='collectorItemRscript',
                                              rows=3, cols=80,
                                              ''),
                                br(),br(),
                                textInput('collectorItemFrequency',
                                          'Import-Frequenz: (in Crontab-Notation)',
                                          value = ''),
                                textInput('collectorItemRepo',
                                          'Repo:',
                                          value = ''),
                                checkboxInput('collectorItemActive',
                                              'aktiv'),
                                br(),
                                actionButton('addCollectorItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateCollectorItem', 
                                             'Aktualisieren', icon('edit'))
                         )
                 )
        )
}