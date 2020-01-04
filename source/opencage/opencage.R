# OpenCage 
library(httr);library(magrittr);library(dplyr)

# Docs: https://opencagedata.com/api
# SingleLine Only
# Free Rate is Restricted
opencage <- function(addresses, key){
  url = 'https://api.opencagedata.com/geocode/v1/json'
  
  responses <- vector('list', length(addresses))
    
  for (i in seq_along(addresses)){
    GET(url,
        query = list(
          q = addresses[i],
          key = key,
          pretty = 1
        )
    ) %>%
    content() -> G
    
    responses[[i]] <- 
      data.frame(stringsAsFactors = FALSE,
                 address = addresses[i],
                 lat = G[["results"]][[1]][["geometry"]]$lat,
                 lng = G[["results"]][[1]][["geometry"]]$lng)
  }
  
  parsed <- dplyr::bind_rows(responses)
  
  return(parsed)
}

# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
okey <- yaml::read_yaml('creds.yml')$opencage

# Full Test Run
otime <- system.time({
  ofull <- opencage(addresses, okey) 
})

save(otime, ofull, file = 'results/opencage.rda')
