# Functions for Accessing Geocoding APIs

library(httr)

# Bing (Batch ?) SEE Schema: https://docs.microsoft.com/en-us/bingmaps/spatial-data-services/geocode-dataflow-api/geocode-dataflow-walkthrough
bing <- function(){
    url = 'http://spatial.virtualearth.net/REST/v1/Dataflows/Geocode'
}

# ESRI [ArcGIS] (Batch 2K) SEE Docs: https://developers.arcgis.com/rest/geocode/api-reference/geocoding-geocode-addresses.htm
esri <- function(){
    url = ''
}

# Geocodio (Batch 10K) SEE Docs: https://www.geocod.io/docs/#geocoding
geocodio <- function(){
    url = 'https://api.geocod.io/v1.4/geocode'
    POST()
}

# Google Maps SINGLE SEE Docs: https://developers.google.com/maps/documentation/geocoding/intro#GeocodingRequests
google <- function(){
    url = 'https://maps.googleapis.com/maps/api/geocode/json'
}

# HERE (Batch ?) SEE Docs: https://developer.here.com/documentation/batch-geocoder/dev_guide/topics/endpoints.html
here <- function(){
    url = 'https://geocoder.api.here.com/6.2/geocode.json'
    POST()
}

# OpenCage SINGLE (Free Rate Restricted..)
opencage <- function(){
    url = 'https://api.opencagedata.com/geocode/v1/json'
}

# TomTom (Batch 10K) SEE Docs: https://developer.tomtom.com/search-api-and-extended-search-api/search-api-and-extended-search-api-documentation-geocoding/geocode
# Invetigate Batch Search and Geocode vs Structured Geocode
tomtom <- function(){
    url =
}

# Censusxy
# See censusxy::cxy_geocode()

# Gateway
# See gateway::*