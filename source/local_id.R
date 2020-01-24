# "Ground truth" values for homicides

# dependecies
library(dplyr)
library(gateway)
library(readr)
library(here)

# load data
homicides <- read_csv(here("data", "STL_CRIME_Homicides.csv"))

# create geocoders
geocoder <- gw_build_geocoder(style = "full", return = "coords")
geocoder_s <- gw_build_geocoder(style = "short", return = "coords")
geocoder_p <- gw_build_geocoder(style = "placename", return = "coords")

# geocode
homicides <- gw_geocode(homicides, type = "composite, local", var = address_norm, class = "tibble",
                        local = geocoder, local_short = geocoder_s, local_place = geocoder_p)

# limit columns
homicides <- select(homicides, cs_year, date_occur, address_norm, gw_addrrecnum, gw_x, gw_y, gw_source)

# write
write_csv(homicides, here("data", "STL_CRIME_Homicides_local_id.csv"))
