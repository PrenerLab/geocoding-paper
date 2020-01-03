# Google Maps
library(httr);library(magrittr);library(dplyr)

# Singleline Only
# Docs: https://developers.google.com/maps/documentation/geocoding/intro#GeocodingRequests
# Not Intended for Storage/Use of Data by terms of Service

google <- function(addresses, key){
  url = 'https://maps.googleapis.com/maps/api/geocode/json'
  
  responses <- vector('list', length(addresses))
  
  for (i in seq_along(responses)){
    GET(url,
        query = list(
          address = addresses[i],
          key = key
        )
    ) %>%
    content() -> G
    
    responses[[i]] <-
      data.frame(stringsAsFactors = FALSE,
                 address = addresses[i],
                 lat = G[["results"]][[1]][["geometry"]][["location"]]$lat,
                 lng = G[["results"]][[1]][["geometry"]][["location"]]$lng
      )
  }
  
  responses <- dplyr::bind_rows(responses)
  
  return(responses)
}


# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
ggkey = yaml::read_yaml('creds.yml')$google

# Full Test Run
ggtime <- system.time({
  ggfull <- google(addresses, ggkey) 
})

save(ggtime, ggfull, file = 'results/google.rda')
