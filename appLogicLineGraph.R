# show line chart
# last update:2017-02-17

linePlotly <- function(data){
        pdf(NULL)
        outputPlot <- plotly_empty()
        data$val <- as.numeric(data$value)
        if(nrow(data) > 0){
                outputPlot <- plot_ly() %>%
                        add_lines(x = as.POSIXct(as.numeric(data$timestamp), 
                                                 origin='1970-01-01'),
                                  y = data$val,
                                  line=list(
                                          width = 3,
                                          shape = 'spline'),
                                  name='') %>%
                        add_markers(x = as.POSIXct(as.numeric(data$timestamp), 
                                                   origin='1970-01-01'),
                                  y = data$val,
                                  marker=list(color='blue'),
                                  name='') %>%
                        layout( title = '',
                                showlegend = FALSE,
                                margin = list(l = 80, r = 80)
                        )
        } else {
                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                            style = 'warning', append = FALSE,
                            title = 'Keine Daten für Sensoren im gewählten Zeitfenster',
                            content = 'Für die ausgewählten Sensoren sind im angegebenen Zeitfenster keine Daten vorhanden.')
        }
        dev.off()
        outputPlot
}