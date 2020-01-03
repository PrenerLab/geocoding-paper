# [ ] HERE (Batch 1M or 2GB) SEE Docs: https://developer.here.com/documentation/batch-geocoder/dev_guide/topics/endpoints.html
# NEED TO OBTAIN KEY TO REPLACE CODE/ID in Credentials
# File needs to comply with: https://developer.here.com/documentation/batch-geocoder/dev_guide/topics/data-input.html
here <- function(file, key){
  url = 'https://batch.geocoder.ls.hereapi.com/6.2/jobs'
  # Mandatory Asynchronous Process
  # Submit Job
  POST(url,
       query = list(
         indelim = ',', # If submitting comma delimited file
         outdelim = ',',
         outcols = 'displayLatitude,displayLongitude,locationLabel',
         apikey = key
       ),
       body = upload_file(file)
  ) %>%
    content()
  # get the request id for the job from the POST
  reqid <- #
    req_url <- paste0(url, '/', reqid)
  
  # Check if Complete
  complete = FALSE
  while(complete == FALSE){
    Sys.sleep(5) # wait 5 seconds
    GET(req_url,
        query = list(
          action = 'status',
          apikey = key
        )    
    ) %>%
      content()
    # Change Complete to Status (Error or TRUE)
    # Stop if Error
    # Exit While if TRUE
  }
  
  # Once Completed, Download and Parse Result File
  GET(paste0(req_url, '/', 'result'),
      query = list(
        OutputCombined = 'true',
        apikey = key
      )
  ) %>%
    content()
  
  # Parse and Return the Content
}