# Load required libraries
library(ggplot2)
library(sf)
library(dplyr)
library(tibble)
library(tigris)
options(tigris_use_cache = TRUE)
library(nhdplusTools)


# site data
# manual input for better control than the .csv import
sites <- tribble(
  ~Site, ~Latitude, ~Longitude,
  "SwanCreek", 42.99951, -89.36139,
  "Dorn Creek", 43.14083, -89.43765,
  "Yahara River @ Windsor", 43.20902, -89.35286,
  "BadFish Creek", 42.83352, -89.19736,
  "Brewery Creek", 43.12231, -89.63712,
  "Mount Vernon Creek", 42.94052, -89.64745,
  "Black Earth Creek", 43.11494, -89.6642,
  "Garfoot Creek", 43.09388, -89.68271,
  "Token Creek", 43.18611, -89.32044,
  "Six Mile Creek", 43.19133, -89.448,
  "Yahara", 42.82543, -89.17285
)


# convert to spatial data (sf package)
sites_sf <- st_as_sf(sites, coords = c("Longitude", "Latitude"), crs = 4326)

# make bounding box, kind of arbitrarily containing all the sites here
bbox_coords <- matrix(c(
  -89.8, 42.8,  # lower left (xmin, ymin)
  -89.1, 43.25   # upper right (xmax, ymax)
), ncol = 2, byrow = TRUE)

bbox <- st_as_sfc(st_bbox(c(
  xmin = -89.8,
  xmax = -89.1,
  ymin = 42.8,
  ymax = 43.25
), crs = st_crs(4326)))





# tigris package to plot water 

# retrieve Wisconsin counties to use to specify later
counties <- counties(state = "WI", cb = TRUE)

# linear water (rivers/streams) for Dane, Rock, and Green counties
riversDane <- linear_water(state = "WI", county = "Dane") 
riversRock <- linear_water(state = "WI", county = "Rock")
riversGreen <- linear_water(state = "WI", county = "Green County")

# have to make sure the rivers are in the same coordinate reference system as bounding box
riversDane <- st_transform(riversDane, crs = st_crs(bbox))
riversRock <- st_transform(riversRock, crs = st_crs(bbox))
riversGreen <- st_transform(riversGreen, crs = st_crs(bbox))

# crop the rivers to fit within the bounding box -- there is probably a better way to do this
riversDane_cropped <- st_crop(riversDane, bbox)
riversRock_cropped <- st_crop(riversRock, bbox)
riversGreen_cropped <- st_crop(riversGreen, bbox)


# get lakes (places with area of water visible) in Dane county
lakes <- area_water(state = "WI", county = "Dane")

# crop lakes to designated box (otherwise some stick out the sides)
lakes <- st_transform(lakes, crs = st_crs(bbox))
lakes_cropped <- st_crop(lakes, bbox)



# plot it...
waterPlot <- ggplot() +
  geom_sf(data = bbox, fill = NA, color = "black") +  # Bounding box
  geom_sf(data = riversDane_cropped, color = "deepskyblue4", size = 0.3) +
  geom_sf(data = riversRock_cropped, color = "deepskyblue4", size = 0.3) +
  geom_sf(data = riversGreen_cropped, color = "deepskyblue4", size = 0.3) +
  geom_sf(data = sites_sf, aes(color = Site), size = 3) +
  geom_sf(data = lakes_cropped, color = "deepskyblue4", fill = "deepskyblue3") +
  theme_minimal() +
  coord_sf()

waterPlot



