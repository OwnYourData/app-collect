# create tag cloud for given repo
# last update: 2017-02-14

getTermMatrix <- function() {
        data <- currDataSelection()
        if(nrow(data) > 0){
                data$dat <- as.Date(as.POSIXct(as.integer(data$timestamp), 
                                               origin='1970-01-01')) 
                dataMin <- min(data$dat, na.rm=TRUE)
                dataMax <- max(data$dat, na.rm=TRUE)
                curMin <- as.Date(input$dateRange[1], '%d.%m.%Y')
                curMax <- as.Date(input$dateRange[2], '%d.%m.%Y')
                daterange <- seq(curMin, curMax, 'days')
                data <- data[as.Date(data$dat) %in% daterange, ]
                
                text <- paste(data$value, collapse = ' ')
                myCorpus = Corpus(VectorSource(text))
                myCorpus = tm_map(myCorpus, content_transformer(tolower))
                myCorpus = tm_map(myCorpus, removePunctuation)
                myCorpus = tm_map(myCorpus, removeNumbers)
                myCorpus = tm_map(myCorpus, removeWords,
                                  c(stopwords('SMART'), 
                                    stopwords('en'), 
                                    stopwords('german'), 
                                    'thy', 'thou', 'thee', 'the', 'and', 'but'))
                myDTM = TermDocumentMatrix(myCorpus,
                                           control = list(minWordLength = 1))
                m = as.matrix(myDTM)
                sort(rowSums(m), decreasing = TRUE)
        } else {
                matrix()
        }
}

        