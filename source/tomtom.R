# TomTom 
library(httr);library(magrittr);library(dplyr)

# Batch 10,000 (Async) 100 (Synchronous)
# Docs: https://developer.tomtom.com/search-api-and-extended-search-api/search-api-and-extended-search-api-documentation-geocoding/geocode

# Asynchrnous Unstructured Implementation
tomtom <- function(addresses, key){
  # Standardize Data (Build own json object)
  schema <- '{"batchItems":['
  for (i in seq_along(addresses)){
    schema <- paste0(
      schema, '{"query":"/geocode/', addresses[i], '.json"},'
    )
  }
    
    # Remove last comma with closing brackets
  schema <- gsub(',$', ']}', schema)
  
  # Submit Job
  url = 'https://api.tomtom.com/search/2/batch.json'
  
  POST(url,
       query = list(
         key = key,
         redirectMode = 'manual'
       ),
       body = schema,
       content_type_json()
  ) %>%
  headers() -> P
    
  dl_url <- paste0('https://api.tomtom.com', P$location)
  
  # Download (May need to increase timeout)
  GET(dl_url) %>%
  content() -> response
  
  # Parse
  parsed <- lapply(response$batchItems, function(x){
    data.frame(stringsAsFactors = FALSE,
               lower = x$response$summary$query, # Replaced with original capitalization in parsing
               lat = x$response$results[[1]]$position$lat,
               lon = x$response$results[[1]]$position$lon)
  })
  
  parsed <- dplyr::bind_rows(parsed)
  parsed <- dplyr::mutate(parsed, row = row_number())
  
    # Match lower case query to original capitalization
  lower_key <- data.frame(stringsAsFactors = FALSE,
                      lower = tolower(addresses) %>% gsub('\\,|\\.','', .),
                      address = addresses,
                      row = seq_along(addresses))
  
  parsed <- dplyr::left_join(parsed, lower_key, by = c('lower', 'row'))
  
  # Remove Lower Column
  parsed <- parsed[,c('address', 'lat', 'lon')]
  
  return(parsed)
}


# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
tkey <- yaml::read_yaml('creds.yml')$tomtom

# Full Test Run
ttime <- system.time({
  tfull <- tomtom(addresses, tkey) 
})

save(ttime, tfull, file = 'results/tomtom.rda')
