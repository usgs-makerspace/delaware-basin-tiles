#TODO: check contents of geojson
library(geojsonio)
library(sf)
gj <- st_read('delaware_PRMS_streams.geojson') %>% 
  st_transform(crs = 4326)
plot(gj)
st_crs(gj)
sites <- st_read('delaware_sites_summary.geojson')
points_matrix <- matrix(c(sites$longitude, sites$latitude), ncol = 2)
points_geom <- st_sfc(st_multipoint(x = points_matrix, dim = "XY"))
#st_geometry(sites) 
sites_new <- sites
sites_new$geometry <- points_geom
st_crs(sites_new) <- 4326
geojson_write(sites_new, file = "sites.geojson", 
              convert_wgs84 = TRUE)

##NHD HR subsetting
library(geojsonio)
library(sf)
drb_extent <- st_read('DRB_Extent.shp') %>% st_transform(4269)
pa_gdb_layers <- st_layers('~/Downloads/NHD_H_Pennsylvania_State_GDB/NHD_H_Pennsylvania_State_GDB.gdb/')

de_gdb_bodies <- st_read('~/Downloads/NHD_H_Delaware_State_GDB/NHD_H_Delaware_State_GDB.gdb/',
                         layer = "NHDWaterbody")
pa_gdb_flowlines <- st_read('~/Downloads/NHD_H_Pennsylvania_State_GDB/NHD_H_Pennsylvania_State_GDB.gdb/',
                            layer = "NHDFlowline") %>% 
  st_zm(drop = TRUE)
plot(pa_gdb_bodies)
flowlines_int <- st_intersection(pa_gdb_flowlines, drb_extent) 
flowlines_int_wgs84 <- st_transform(flowlines_int, 4326) %>% 
  dplyr::select(Permanent_Identifier, FType, GNIS_Name, GNIS_ID, FCode,
         OBJECTID, Shape)
geojson_write(flowlines_int_wgs84, file = "nhd_hires_flowlines.geojson",
              precision = 4)

de_bodies_int <- st_intersection(de_gdb_bodies, drb_extent)
de_bodies_int_wgs84 <- st_transform(de_bodies_int, 4326) %>% 
  dplyr::select(Permanent_Identifier, FType, GNIS_Name, GNIS_ID, FCode,
                OBJECTID, Shape)
geojson_write(de_bodies_int_wgs84, file = "nhd_hires_waterbodies.geojson",
              precision = 4)

#converting Jake's files to GeoJSON
flowlines <- readRDS('~/Downloads/nhd_flowline_subset.rds')
flowlines_write <- flowlines %>% st_transform(crs = 4326) %>% 
  dplyr::select(Permanent_Identifier, FDate, GNIS_ID, GNIS_Name, ReachCode,
         FlowDir, FType, FCode, NHDPlusID, StreamOrde, geom)
geojson_write(flowlines_write, file = "nhd_hires_flowlines.geojson",
              precision = 4)

bodies <- readRDS('~/Downloads/nhd_waterbody_subset.rds')
bodies_write <- bodies %>% st_transform(crs = 4326) %>% 
  dplyr::select(Permanent_Identifier, FType, GNIS_Name, GNIS_ID, FCode,
                Elevation, ReachCode, geom, NHDPlusID) 
geojson_write(flowlines_write, file = "nhd_hires_waterbodies.geojson",
              precision = 4, geometry = "polygon")
