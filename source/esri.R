# Ersi [ArcGIS] Geocoder
library(httr);library(magrittr);library(dplyr)

# ESRI [ArcGIS] (Batch 2K?) 
# Docs: https://developers.arcgis.com/rest/geocode/api-reference/geocoding-geocode-addresses.htm

esri <- function(addresses, key){
  # API Fails when Sending Large Quantites of Addresses
  # So I implement batches of 50
  
    # Add Id as Name to Vector 
  names(addresses) <- seq_along(addresses)
    # Split into Batches
  jobs <- split(addresses, (seq(length(addresses))-1) %/% 50)
  returns <- vector('list', length(jobs))
  
  url = 'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/geocodeAddresses'
  for (i in seq_along(jobs)){
    # Standardize to Schema (Building JSON to avoid R object ambiguity)
    schema <- '{"records":['
    for (j in seq_along(jobs[[i]])){
      schema <-
        paste0(schema,
               '{"attributes":{"OBJECTID":', names(jobs[[i]][j]),',"SingleLine":"',jobs[[i]][j],'"}},'
        )
    }
      # Remove last comma with closing brackets
    schema <- gsub(',$', ']}', schema)
    # Send Request
    returns[[i]] <- 
    POST(url,
         query = list(
           addresses = schema,
           f = 'json',
           token = key
         )
    ) %>%
    content()
  }
  # Parse the Results
  parsed <- vector('list', length(returns))

  for (i in seq_along(returns)){
    address = vector('character', length(returns[[i]][['locations']]))
    id = vector('integer', length(returns[[i]][['locations']]))
    x = vector('integer', length(returns[[i]][['locations']]))
    y = vector('integer', length(returns[[i]][['locations']]))
    
    for (j in seq_along(returns[[i]][['locations']])){
      address[j] <- returns[[i]][['locations']][[j]][["address"]]
      id[j] <- returns[[i]][['locations']][[j]][["attributes"]][["ResultID"]]
      x[j] <- returns[[i]][['locations']][[j]][["location"]][["x"]]
      y[j] <- returns[[i]][['locations']][[j]][["location"]][["y"]]
    }
    
    parsed[[i]] <- 
      data.frame(stringsAsFactors = FALSE,
                 ResultID = id,
                 address = address,
                 x = x,
                 y = y 
      )
  } 
  
  parsed <- dplyr::bind_rows(parsed)
  
  # Order the data
  parsed <- parsed[order(parsed$ResultID),]
  
  return(parsed)
}

# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
ekey <- yaml::read_yaml('creds.yml')$esri

# Full Test Run
etime <- system.time({
  efull <- esri(addresses, ekey)
})

save(etime, efull, file = 'results/esri.rda')

