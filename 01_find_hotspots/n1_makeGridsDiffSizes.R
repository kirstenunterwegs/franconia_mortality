

# Inspect the available data and create grid: hexagon
# modify the size to know how many fit in Bavaria by size

# --------------------------


rm(list = ls())

# Read my paths -----------------------------------------------------------
source('myPaths.R')

#myPath = "C:/Users/ge45lep/Documents/2021_Franconia_mortality"

#inFolder = "raw"
#outFolder = "outSpatial"

# Process:
# get bavaria data:
# Create hexagon
# count hexagons



# Read libs  --------------------------------------------------------------

library(sf)
library(dplyr)
require(data.table)
library(tidyr)
library(raster)
library(rgdal)
library(tidyverse)
library(lubridate)
library(sf)
library(patchwork)
library(fasterize)


# --------------------------
# Read input data: 
# --------------------------


# Get Germany data ----------------------
ger.shp <- st_read(paste(myPath, inFolder, "germany.shp", sep = "/")) # read watershed

plot(ger.shp["COUNTRY"])

# Get Europe data ----------------------

eu.shp <- st_read(paste(myPath, inFolder, "europe.shp", sep = "/")) # read watershed

plot(eu.shp)

# Simplify polygon, keep only geometry
ger.simple <- st_simplify(ger.shp, preserveTopology = FALSE, dTolerance = 1000)
eu.simple <- st_simplify(eu.shp, preserveTopology = FALSE, dTolerance = 1000)
#bav.shp.sp <-bav.shp$geom


# How many cells can I expect based on Europe size?? -------------------

#get area of Europe
area <- st_area(eu.simple)/1000000 # retrieve area in km2 for europe
#area <- st_area(ger.simple)/1000000 # retrieve area in km2 for germany

a= sqrt(area)  # 2398 *2398 km

# How many cells to expect??
# get cell size: 10, 25, 50 km
df = data.frame(size = c(5,10,15,20,25,50, 100))

df$area = df$size^2

# Get radius from this
df$r = sqrt(df$area/pi)

(df)


# Check projection
st_crs(ger.simple)$proj4string  # projection is in m, therefore the cell size need to be in meters as well
st_crs(eu.simple)$proj4string 

# Make a grid: hexagon and a square
# Make a grid 
g = st_make_grid(eu.simple, 
                 #n = c(10,10),
                 cellsize = 50000,  # 50 km
                 #cellsize = c(diff(st_bbox(df.geom)[c(1, 3)]), 
                 #           diff(st_bbox(df.geom)[c(2, 4)]))/n,
                 square = FALSE)  # make hexagon, not square

plot(g)
plot(eu.simple, add = T)


# # Export the new file
st_write(g, paste( myPath, outFolder, "hexa50_eu.gpkg", sep = "/"), append=FALSE)


# ------------------------------------
# Create hexagons for different sizes and export them
# -------------------------------------
#cell_size = df$size  # km to m

cell_size =  c(3, 5,10,12, 25, 50)

# Export all 

g_ls <- lapply(cell_size, function(x) {
  print(x)
  
  # get unique name
  outname = paste0("grid_", x)
  
  print(outname)
  g = st_make_grid(eu.simple, 
               cellsize = x*1000,  
               square = FALSE)  # make hexagon, not square
  # write hexagons
  st_write(g, paste( myPath, outFolder, paste0(outname, ".gpkg"), sep = "/"),
           append=FALSE)
  
})
  




