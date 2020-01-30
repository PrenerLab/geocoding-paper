# Generate Intesection Dataframe
library(tigris)
library(sf)
library(dplyr)
options(tigris_use_cache = FALSE)

# Get Roads for St. Louis
stl_roads <- roads(29, 510, class = 'sf')
stl_interstate <- filter(stl_roads, RTTYP == 'I')
stl_roads <- filter(stl_roads, RTTYP != 'I')

# Find Intersections for Interstates
intersections <- st_intersection(stl_interstate, stl_roads)
intersections <- 
  transmute(intersections,
    name = paste0(FULLNAME, ' @ ', FULLNAME.1)
  )

# Remove Non-Point Geometries (Lines Overlapping)
points <- sapply(intersections[['geometry']], function(x){
  if ("POINT" %in% class(x)){
    return(TRUE)
  }else{
    return(FALSE)
  }
})

intersections <- filter(intersections, points)

# If Mulitple Intersections, Return Center Point
intersections %>% 
  group_by(name) %>%
  summarise() -> groups

coords <- sapply(groups[['geometry']], function(x){
    if ("MULTIPOINT" %in% class(x)){
      coords <- st_coordinates(x)
      center <- c(lon = mean(coords[,1]),
                  lat = mean(coords[,2]))
      return(center)
    }else{
      return(st_coordinates(x))
    }
})
coords <- t(coords)

# Join the Data and Project to SF
join <- cbind(groups, coords)

final <- st_drop_geometry(join) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# To Test View
#library(mapview)
#mapview(final, legend = FALSE)
