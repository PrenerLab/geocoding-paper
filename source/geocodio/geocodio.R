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