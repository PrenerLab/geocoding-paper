# Bing Geocoder
library(httr);library(magrittr);library(dplyr)

# Bing (Batch 50 Free, 200K Enterprise)
# Docs: https://docs.microsoft.com/en-us/bingmaps/spatial-data-services/geocode-dataflow-api/geocode-dataflow-walkthrough
# This API is Asynchronous
# 2 Simultaneous Jobs, 50 Jobs Max per 24 Hours (Current implementation is linear)
# 50 Entities Per Batch

# Error handling is going to be a big deal. We only get one shot per 24hrs to get this whole thing right

bing <- function(addresses, key){
  # Transform vector to schema
  schema <- data.frame(stringsAsFactors = FALSE,
                       Id = NA,
                       `GeocodeRequest/Culture` = 'en-US',
                       `GeocodeRequest/Address/AddressLine` = addresses,
                       `GeocodeResponse/Point/Latitude` = NA,
                       `GeocodeResponse/Point/Longitude` = NA)
  schema %<>%
    mutate(Id = row_number())
  
  # Seperate Jobs into List of Files
  tmp <- tempdir()
  jobs <- split(schema, (seq(nrow(schema))-1) %/% 50)
  
    # Write Files to Temp
  for (i in seq_along(jobs)){
    write('Bing Spatial Data Services, 2.0', file.path(tmp, paste0('job', i, '.csv')))
    suppressWarnings({
      write.table(jobs[[i]], file.path(tmp, paste0('job', i, '.csv')),
                row.names = FALSE, quote = FALSE, append = TRUE, sep = ',', na = '',
                col.names = list('Id', 'GeocodeRequest/Culture',
                                 'GeocodeRequest/Address/AddressLine',
                                 'GeocodeResponse/Point/Latitude',
                                 'GeocodeResponse/Point/Longitude')
      )
    }) # Anticipate Warning Because Appending Col Names to Existing File
  }
  
  # Iterate Sending Jobs, Waiting
  returns <- vector('list', length(jobs))
  
    # Linear Implementation Currently (As Opposed to Async)
  for (i in seq_along(jobs)){
    url = 'http://spatial.virtualearth.net/REST/v1/Dataflows/Geocode'
    # Submit Job and Get ID
    POST(url,
         query = list(
           input = 'csv',
           key = key,
           output = 'json'
         ),
         body = upload_file(file.path(tmp, paste0('job', i, '.csv')))
    ) %>%
    content() -> P
    id = P$resourceSets[[1]]$resources[[1]]$id
    status = P$resourceSets[[1]]$resources[[1]]$status
    
    # Wait 10 Seconds
    Sys.sleep(10)
    
    # Check on Status
    while(status == 'Pending'){
      # Check Status
      GET(paste0(url, '/', id),
          query = list(
            key = key
          )
      ) %>%
      content() -> G
      
      status = G$resourceSets[[1]]$resources[[1]]$status
      link = try(G$resourceSets[[1]]$resources[[1]]$links[[2]]$url)
    }
    
    # Download Response
    GET(link,
        query = list(
          key = key
        )
    ) %>%
    content(encoding = 'UTF-8') -> returns[[i]]
    returns[[i]] <- sub('Bing Spatial Data Services, 2.0\r\n', '', returns[[i]])
  }
  
  # Parse
  parsed <- lapply(returns, function(x){
    read.csv(text = x, stringsAsFactors = FALSE)
  })
  
  parsed <- dplyr::bind_rows(parsed)
  # Return
  return(parsed)
  
}

# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
bkey <- yaml::read_yaml('creds.yml')$bing

# Full Test Run
btime <- system.time({
  bfull <- bing(addresses, bkey) 
})

save(btime, bfull, file = 'results/bing.rda')
