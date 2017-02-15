# Tag Cloud
# last update: 2017-02-14

appStatusTagCloud <- function(){
        tabPanel('Wort Wolke', br(),
                 fluidRow(
                         column(1),
                         column(4,
                                sliderInput("freq",
                                            "min. Wortfrequenz:", ticks=FALSE,
                                            min = 1,  max = 50, value = 15)),
                         column(4,
                                sliderInput("max",
                                            "max. Wortzahl:", ticks=FALSE,
                                            min = 1,  max = 300,  value = 100))),
                 br(),
                 plotOutput('tagCloud')
        )
}
