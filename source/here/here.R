# HERE 
library(httr);library(magrittr)

# Batch 1M or 2GB uncompressed
# Docs: https://developer.here.com/documentation/batch-geocoder/dev_guide/topics/endpoints.html
# File needs to comply with: https://developer.here.com/documentation/batch-geocoder/dev_guide/topics/data-input.html
here <- function(addresses, key){
  # Standardize the Data to the Schema
  schema <- data.frame(stringsAsFactors = FALSE,
                       searchText = addresses,
                       country = 'USA')
  
    # Write to a temp file
  tmp <- tempfile()
  write.table(schema, file = tmp, sep = '|',
              row.names = FALSE, quote = FALSE)
  
  url = 'https://batch.geocoder.ls.hereapi.com/6.2/jobs'
  
  # Submit Job and Start
  POST(url,
       query = list(
         indelim = '|',
         outdelim = ',',
         outcols = 'displayLatitude,displayLongitude,locationLabel',
         apikey = key,
         action = 'run',
         outputcombined = 'true'
       ),
       body = upload_file(tmp)
  ) %>%
  content() -> P
  
  # get the request id for the job from the POST
  reqid <- P$Response$MetaInfo$RequestId
  req_url <- paste0(url, '/', reqid)
  
  # Wait 15 seconds
  Sys.sleep(15)
  
  # Check if Complete
  status = 'running'
  while(status == 'running'){
    Sys.sleep(5) # wait 5 seconds
    GET(req_url,
        query = list(
          action = 'status',
          apikey = key
        )    
    ) %>%
    content() -> G
    
    status = G$Response$Status
  }
  
  # Once Completed, Download and Parse Result File
  GET(paste0(req_url, '/', 'result'),
      query = list(
        outputcompressed = 'false',
        apikey = key
      )
  ) %>%
  content() -> response
  
  # Parse and Return the Content
  parsed <- read.csv(text = response, stringsAsFactors = FALSE)
  
  # Accept the First Match
  parsed <- parsed[which(parsed$SeqNumber == 1),]
    
  # Add Original Address
  parsed$address <- addresses
  
  # Select Columns for Output
  parsed <- parsed[,c('recId', 'address','displayLatitude','displayLongitude')]
  
  return(parsed)
}

# Load Vector of Addresses
data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO') # Add St. Louis Key (Some Blanks though...)
addresses <- data

# Load Key
hkey <- yaml::read_yaml('creds.yml')$here

# Full Test Run
htime <- system.time({
  hfull <- here(addresses, hkey) 
})

save(htime, hfull, file = 'results/here.rda')
