library(rJava)
library(r5r)
library(KernSmooth)
library(tidyverse)



# initial set up and graph building
options(java.parameters = "-Xmx4G")
r5r_core <- setup_r5(data_path = ".", verbose = FALSE)


# load in origin locations - hexagon centroid
points_o <- read.csv("hex200.csv", colClasses = "character")
points_o$lon <- as.numeric(points_o$X)
points_o$lat <- as.numeric(points_o$Y)
points_o$id <- points_o$id
points_o <- points_o[,c("id","lon","lat")]

# subsetting for testing
points_o_sub <- head(points_o,10)

# load in destination locations - foodbank locations
points_d <- read.csv("foodbanks_xy.csv", colClasses = "character")
points_d$lon <- as.numeric(points_d$X)
points_d$lat <- as.numeric(points_d$Y)
points_d$id <- points_d$ID
points_d <- subset(points_d, points_d$Accessible == 1)

# subset if only looking at older locations
points_d <- subset(points_d, points_d$New != 1)

# subsetting for testing
points_d_sub <- head(points_d,10)


# routing paramaters
mode <- c("WALK", "TRANSIT")
max_walk_dist <- 50000   # meters
max_trip_duration <- 60 # minutes
departure_datetime <- as.POSIXct("21-04-2021 15:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")
departure_datetime <- as.POSIXct("19-02-2020 15:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

# estimating the travel time
ttm2 <- travel_time_matrix(r5r_core,
                          origins = points_o,
                          destinations = points_d,
                          mode = mode,
                          departure_datetime = departure_datetime,
                          max_walk_dist = max_walk_dist,
                          max_trip_duration = max_trip_duration)

# computing travel time to the nearest
dfm <- ttm2 %>% group_by(fromId) %>% summarise(
  min_travel_time = min(travel_time, na.rm = T) + 1
)

# save
write.csv(dfm, "outputs/min_travel_time_hex_una_febl2020.csv")











