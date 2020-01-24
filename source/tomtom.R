# TomTom 
library(httr);library(magrittr);library(dplyr)

# Batch 10,000 (Async) 100 (Synchronous)
# Docs: https://developer.tomtom.com/search-api-and-extended-search-api/search-api-and-extended-search-api-documentation-geocoding/geocode

# Asynchrnous Unstructured Implementation
tomtom <- function(addresses, key){
  # TomTom's Async Implementation is Bad, so iterate batches of 100
  # * It's bad because it uses long polling that times out in 120 seconds regardless
  jobs <- split(addresses, (seq(length(addresses))-1) %/% 100)
  returns <- vector('list', length(jobs))
  
  for (i in seq_along(jobs)){
    # Standardize Data (Build own json object)
    schema <- '{"batchItems":['
    for (j in seq_along(jobs[[i]])){
      schema <- paste0(
        schema, '{"query":"/geocode/', jobs[[i]][j], '.json"},'
      )
    }
      
      # Remove last comma with closing brackets
    schema <- gsub(',$', ']}', schema)
    
    # Submit Job
    url = 'https://api.tomtom.com/search/2/batch.json'
    
    POST(url,
         query = list(
           key = key,
           redirectMode = 'auto' # 303, Long Poll 120 Seconds
         ),
         body = schema,
         content_type_json()
    ) %>%
    content() -> P
    
    # Pre-Parse
    returns[[i]] <- lapply(P$batchItems, function(x){
      data.frame(stringsAsFactors = FALSE,
                 lower = x$response$summary$query, # Replaced with original capitalization in parsing
                 lat = x$response$results[[1]]$position$lat,
                 lon = x$response$results[[1]]$position$lon)
    })
    
    returns[[i]] <- dplyr::bind_rows(returns[[i]])
  }
  
  # Parse
  parsed <- dplyr::bind_rows(returns)
  parsed <- dplyr::mutate(parsed, row = row_number())
  
    # Match lower case query to original capitalization
  lower_key <- data.frame(stringsAsFactors = FALSE,
                      lower = tolower(addresses) %>% gsub('\\,|\\.','', .),
                      address = addresses,
                      row = seq_along(addresses))
  
  parsed <- dplyr::left_join(parsed, lower_key, by = c('lower', 'row'))
  
  # Remove Lower Columns
  parsed <- parsed[,c('address', 'lat', 'lon')]
  
  return(parsed)
}
