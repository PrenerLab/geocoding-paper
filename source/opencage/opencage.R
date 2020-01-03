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