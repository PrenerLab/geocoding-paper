# Bing Geocoder
library(httr);library(magrittr)

# Bing (Batch 50 Free, 200K Enterprise)
# Docs: https://docs.microsoft.com/en-us/bingmaps/spatial-data-services/geocode-dataflow-api/geocode-dataflow-walkthrough
# This API is Asynchronous
# 2 Simultaneous Jobs, 50 Jobs Max per 24 Hours
# 50 Entities Per Batch

# Wonky Iteration Psuedo Code (This is a bad implementation)
#
# Coerce Vector of Singleline Addresses into schema (Version 2.0)
# Count Total Numer of Jobs 1822/50 = 37 jobs
# Create 37 Files and Allocations within Memory
# Send One Job, get 201 and URL
# Send Job 2, get 201 and URL
# While latest job < 37 and not all jobs done
# ~Wait a few seconds
# ~Check Job 1 status
# ~If complete, store job 1 results at index one, and start next available job
# ~Wait a few seconds
# ~Check Job 2 status
# ~If complete, store job 2 results at index 2 and start next available job
# Exit Condition only reached when all indicies have returned results
# Combine the Results
# Parse for latitude longitude

# Error handling is going to be a big deal. We only get one shot per 24hrs to get this whole thing right



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

key <- yaml::read_yaml('source/bing/key.yml')$Key

bing('source/bing/test.csv', key)
