# Geocodio 
library(httr);library(magrittr);library(dplyr);library(jsonlite)

# Batch 10,000
# Docs: https://www.geocod.io/docs/#geocoding

geocodio <- function(addresses, key){
  url = 'https://api.geocod.io/v1.4/geocode'
  POST(url,
       query = list(
         api_key = key
       ),
       body = jsonlite::toJSON(addresses),
       content_type_json()
  ) %>%
  content() -> P
  
  # parse the response
  parsed <- lapply(P$results, function(x){
    data.frame(stringsAsFactors = FALSE,
               address = x[["query"]],
               lat = x[["response"]][["results"]][[1]][["location"]]$lat,
               lng = x[["response"]][["results"]][[1]][["location"]]$lng)
  })
  
  parsed <- dplyr::bind_rows(parsed)
  
  return(parsed)
  
}
