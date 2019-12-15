# Functions for Accessing Geocoding APIs

library(httr);library(magrittr)

# [ ] Bing (Batch 50 Free, 200K Enterprise) SEE Schema: https://docs.microsoft.com/en-us/bingmaps/spatial-data-services/geocode-dataflow-api/geocode-dataflow-walkthrough
bing <- function(csv, key){
    url = 'http://spatial.virtualearth.net/REST/v1/Dataflows/Geocode'
    # Need to Implement Iterator if using Free Tier
    POST(url,
         query = list(
             input = 'csv',
             key = key,
             output = 'json'
         ),
         body = upload_file(csv)
    ) %>%
    content()
    
    #TODO Return only Lat Lon in List
}

# [ ] ESRI [ArcGIS] (Batch 2K?) SEE Docs: https://developers.arcgis.com/rest/geocode/api-reference/geocoding-geocode-addresses.htm
esri <- function(json, token){
    url = 'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/geocodeAddresses'
    #TODO Write standardizatinon function for ESRIs super strict schema
    # Use of Parameters to limit extent/accuracy?
    POST(url,
         query = list(
             token = token,
             f = 'json'
         ),
         body = json,
         # need to be url encoded json 
         # &addresses={"records": [
         # {"attributes": {"OBJECTID": 1, "SingleLine":"<Address>"}},
         # {"attributes": {"OBJECTID": 2, "SingleLine":"<Address>"}}
         # ]}
         # could technically be sent in URL (query) instead.
         # ESRI: Bad Implementation, Worse Documentation
         encode = 'form' # mime: application/x-www-form-urlencoded
    ) %>%
    content()
}

# [ ] Geocodio (Batch 10K) SEE Docs: https://www.geocod.io/docs/#geocoding
geocodio <- function(json, key){
    url = 'https://api.geocod.io/v1.4/geocode'
    POST(url,
         query = list(
             api_key = key
         ),
         body = json # if valid json, else use list and encode = 'json'
    ) %>%
    content()
    # Allows for Address Components
    
    # Arrary
    # [
    #   "<Address>"
    #   "<Address>"
    # ]
     
    # Or object
    # {
    #   "1" : <Address>"
    #   "2" : <Address>"
    # }
}

# [\] Google Maps SINGLE SEE Docs: https://developers.google.com/maps/documentation/geocoding/intro#GeocodingRequests
google <- function(address, key){
    url = 'https://maps.googleapis.com/maps/api/geocode/json'
    #TODO Implement Iterator
    GET(url,
        query = list(
            address = address,
            key = key
        )
    ) %>%
    content()
    
    #TODO Return only Lat Lon in List
}

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

# [\] OpenCage SINGLE (Free Rate Restricted..)
opencage <- function(address, key){
    url = 'https://api.opencagedata.com/geocode/v1/json'
    #TODO Implement Iterator
    GET(url,
        query = list(
            q = address,
            key = key,
            pretty = 1
        )
    ) %>%
    content()
    
    #TODO Return only Lat Lon in List
}

# [ ] TomTom (Batch 10K) SEE Docs: https://developer.tomtom.com/search-api-and-extended-search-api/search-api-and-extended-search-api-documentation-geocoding/geocode
# Invetigate Batch Search and Geocode vs Structured Geocode
# Sructured or Unstructured??
# Synchronous or Asynchronus
tomtom <- function(){
    url = 'https://api.tomtom.com/search'
}

# Censusxy
# See censusxy::cxy_geocode()

# Gateway
# See gateway::*