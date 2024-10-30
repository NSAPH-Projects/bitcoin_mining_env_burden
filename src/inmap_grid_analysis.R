install.packages('tigris')
options(tigris_use_cache = TRUE)
library(tigris)
library(ggplot2)
library(sf)
library(raster)
library(tictoc)
library(dplyr)
library(ggrepel)
library(sf)

inmap_results_finest_res_corrected <-st_read(
  "/Users/gianlucaguidi/inmap/cmd/inmap/evaldata_v1.6.1/inmap_emissions_2022_2023_finest_res.shp")
st_crs(inmap_results_finest_res_corrected)


tracts_sf <- tracts( cb=TRUE, state=NULL)
tracts_sf <- tracts_sf[!(tracts_sf$STATEFP %in% c("02", "15", "66", "72", "60", "69", "78")), ]


tracts_sf <- st_transform(tracts_sf, crs = st_crs(inmap_results_finest_res_corrected))

st_crs(inmap_results_finest_res_corrected)
st_crs(tracts_sf)

max(inmap_results_finest_res_corrected$TotalPM25)

nrow(inmap_results_finest_res_corrected)
colSums(is.na(inmap_results_finest_res_corrected))

ggplot( (inmap_results_finest_res_corrected)
        ,
        aes( fill =  TotalPM25)) +
  geom_sf( size = 0, alpha = .9, color = NA) +
  geom_sf( data = us.sf, fill = NA, size = .9, color = 'lightgrey') +
  #scale_fill_gradient( high = 'red', low = 'green',
  #                    limits = c(0,0.05), 
  #                   oob = scales::squish) +
  scale_fill_viridis_c(option='magma',
                       limits = c(0,.5),
                       oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 1) +
  theme_minimal() +
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('Power Plants Total PM25 Emissions - InMAP grid (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5)) 


#### convert inmap cells into tracts 
tracts_sf
inmap_results_finest_res_corrected
#Function 

#' `sf` polygon to `sf` polygon variable aggregation
#' 
#' @param x_poly_sf object of `sf`class, with corresponding geometry class `sfc_POLYGON`, `sfc_MULTIPOLYGON`, `sfc_GEOMETRY`. The corresponding `tibble` should contain a variable that will be aggregated.
#' @param y_poly_sf object of `sf`class, with corresponding geometry class `sfc_POLYGON`, `sfc_MULTIPOLYGON`, `sfc_GEOMETRY`.
#' @param y_id name of variable in `y_poly_sf` that contains the polygon IDs.
#' @param x_var name of the variable in `x_poly_sf` that will be "aggregated".
#' @param fn "aggregation function" function 
#'
#' @return A `tibble` containing a polygon ID in `y_poly_sf` and an associated variable which is obtained by applying an aggregation function over values in `x_poly_sf`.
var_poly_to_poly <- function(
    x_poly_sf, 
    y_poly_sf, 
    y_id, 
    x_var, 
    fn = mean()
) {
  
  y_poly_sf[[x_var]] = 0
  
  for (i in 1:nrow(y_poly_sf)) {
    y_i_sf <- dplyr::select(y_poly_sf[i, ], c("geometry"))
    
    # st_crop prints warnings and messages
    suppressWarnings({
      suppressMessages(
        x_i_sf <- try(
          dplyr::select(st_crop(x_poly_sf, raster::extent(y_i_sf)), c(x_var, "geometry"))
          ,silent = T) %>% st_drop_geometry()
      )
    })
    
    if(class(x_i_sf)[1] != "try-error"){
      y_poly_sf[[x_var]][i] <- mean(as.numeric(unlist(x_i_sf[x_var])))
    } else y_poly_sf[[x_var]][i] <- as.numeric(NA)
    
  }
  
  return(
    y_poly_sf %>% 
      st_drop_geometry() %>% 
      dplyr::select(y_id, x_var)
  )
}


#### the line below takes 7 hours to be run ###

tracts_exp_totPM25_finest_res_corrected_FINAL<- var_poly_to_poly(inmap_results_finest_res_corrected, tracts_sf, 
                                                                 'GEOID', 'TotalPM25')

# save results
write.csv(tracts_exp_totPM25_finest_res_corrected_FINAL, "/Users/gianlucaguidi/inmap/cmd/inmap/evaldata_v1.6.1/tracts_exp_totPM25_finest_res_corrected_FINAL.csv", row.names=FALSE)

# load results
tracts_exp_totPM25_finest_res_corrected_FINAL = read.csv("/Users/gianlucaguidi/inmap/cmd/inmap/evaldata_v1.6.1/tracts_exp_totPM25_finest_res_corrected_FINAL.csv")

## assign GEID to polygons
tracts_sf$GEOID = as.numeric(tracts_sf$GEOID)
tracts_exp_totPM25_finest_res_corrected_FINAL$GEOID = as.numeric(tracts_exp_totPM25_finest_res_corrected_FINAL$GEOID)

tracts_exp_sf_totPM25_finest_res_corrected_FINAL <- tracts_sf %>% 
  left_join(tracts_exp_totPM25_finest_res_corrected_FINAL)


nrow(tracts_exp_sf_totPM25_finest_res_corrected_FINAL)
colSums(is.na(tracts_exp_totPM25_finest_res_corrected_FINAL))
tracts_exp_sf_totPM25_finest_res_corrected_FINAL

max(tracts_exp_sf_totPM25_finest_res_corrected_FINAL$TotalPM25)
# all exposure by tract


#####plot totPM25 ######
ggplot( tracts_exp_sf_totPM25_finest_res_corrected_FINAL,
        aes( fill =  TotalPM25)) +
  geom_sf( size = 0, alpha = .9, color = NA) +
  geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',limits = c(0,.5),oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 0) +
  theme_minimal() +
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('Power Plants Total PM2.5 Emissions - Census Tract Level - InMAP (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

#####plot totPM25 ONLY ABOVE threshold ######
tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero = tracts_exp_sf_totPM25_finest_res_corrected_FINAL[(tracts_exp_sf_totPM25_finest_res_corrected_FINAL$TotalPM25>0.01),]

ggplot( tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero,
        aes( fill =  TotalPM25)) +
  geom_sf( size = 0, alpha = 1, linewidth=.05, color=NA) +
  geom_sf( data = us.sf, fill = 'NA', size = .5, linewidth=.05, color='black') +
  #scale_fill_gradient( high = 'black', low = 'lightyellow',
  #limits = c(0,1), 
  #                  oob = scales::squish) +
  scale_fill_viridis_c(option='magma',limits = c(0,.5),oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 0) +
  theme_minimal() +
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('') +
  theme(plot.title = element_text(hjust = 0.5))


quantile(tracts_exp_sf_totPM25_finest_res_corrected_FINAL$TotalPM25)
hist(tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero$TotalPM25 )
tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero[order(-tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero$TotalPM25),]


#####plot for paper - final

ggplot( tracts_exp_sf_totPM25_finest_res_corrected_FINAL_above_zero,
        aes( fill =  TotalPM25)) +
  geom_sf( size = 0, alpha = .9, color = 'NA') +
  geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.05, color='black') +
  #scale_fill_gradient( high = '#2a1c0e', low = 'moccasin',
  #                     limits = c(0,1), 
  #                  oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction = 1,limits = c(0,.5),oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 0) +
  #theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('Power Plants Total PM2.5 Emissions - Census Tract Level - InMAP (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))



## demographics

####### Demographics at tract level ######
library(data.table)
install.packages('R.utils')
library(R.utils)
library(dplyr)

demogrphics_tracts_all = fread("/Users/gianlucaguidi/Downloads/2022_tract_acs5.csv.gz")

demogrphics_tracts = dplyr::select(demogrphics_tracts_all, GEOID, population, pct_white, pct_black, pct_asian, pct_hispanic, pct_native, ethnic_fractionalization, med_household_income,med_family_income,pct_poverty,med_property_value)
demogrphics_tracts

demogrphics_tracts = demogrphics_tracts_all %>%
  dplyr::select(GEOID, population, pct_white, pct_black, pct_asian, pct_hispanic, pct_native, ethnic_fractionalization, med_household_income,med_family_income,pct_poverty,med_property_value)

demogrphics_tracts$GEOID = as.numeric(demogrphics_tracts$GEOID)
tracts_exp_sf_totPM25_finest_res_corrected$GEOID = as.numeric(tracts_exp_sf_totPM25_finest_res_corrected$GEOID)

demogrphics_tracts$pop_white = demogrphics_tracts$population*demogrphics_tracts$pct_white
demogrphics_tracts$pop_black = demogrphics_tracts$population*demogrphics_tracts$pct_black
demogrphics_tracts$pop_hispanic = demogrphics_tracts$population*demogrphics_tracts$pct_hispanic
demogrphics_tracts

tracts_exp_sf_totPM25_finest_res_corrected_FINAL

exposure_all_black_white_hispanic_corrected_FINAL <- tracts_exp_sf_totPM25_finest_res_corrected_FINAL %>% 
  left_join(demogrphics_tracts, by='GEOID')

exposure_all_black_white_hispanic_corrected_FINAL

colSums(is.na(exposure_all_black_white_hispanic_corrected_FINAL))



#save files with all tracts and all demographics in shp and csv
st_write(exposure_all_black_white_hispanic_corrected_FINAL, 
         dsn='/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/exposure_all_black_white_hispanic_corrected_FINAL',
         driver = "ESRI Shapefile",append=FALSE)

# 

st_write(exposure_all_black_white_hispanic_corrected_FINAL_above_zero, 
         dsn='/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/exposure_all_black_white_hispanic_corrected_FINAL_above_zero',
         driver = "ESRI Shapefile",append=FALSE)

#
exposure_all_black_white_hispanic_corrected_FINAL_no_geometry = st_drop_geometry(exposure_all_black_white_hispanic_corrected_FINAL)
write.csv(exposure_all_black_white_hispanic_corrected_FINAL_no_geometry, "exposure_all_black_white_hispanic_corrected_FINAL_CSV_NOSHP.csv", row.names = FALSE)



##### read file with exposures and demographics ##### 

exposure_all_black_white_hispanic_corrected_FINAL = st_read(
  '/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/exposure_all_black_white_hispanic_corrected_FINAL')


exposure_all_black_white_hispanic_corrected_FINAL



#### LOAD TOTAL PM2.5 at tract level to find Bitcoin contribution ####
library(arrow)
library(dplyr)
colnames(bitcoin_pm25_tracts)

# Check column names in pm25_tracts
colnames(exposure_all_black_white_hispanic_corrected_FINAL)


pm25_tracts = read.csv(
  '/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/satellite_pm25_census_tract_2022.csv')
pm25_tracts$census_tract =  as.numeric(pm25_tracts$census_tract)
pm25_tracts$GEOID =  as.numeric(pm25_tracts$census_tract)
pm25_tracts

bitcoin_pm25_tracts = select(exposure_all_black_white_hispanic_corrected_FINAL,NAMELSADC,STATE_N, GEOID, TtlPM25, geometry)
bitcoin_pm25_tracts

exposure_all_black_white_hispanic_corrected_FINAL

bitcoin_pm25_tracts_and_tractsPM25 <- exposure_all_black_white_hispanic_corrected_FINAL %>%
  left_join(pm25_tracts, by = "GEOID")


bitcoin_pm25_tracts_and_tractsPM25$bitcoin_contribution = bitcoin_pm25_tracts_and_tractsPM25$TtlPM25/bitcoin_pm25_tracts_and_tractsPM25$pm25

hist(bitcoin_pm25_tracts_and_tractsPM25$bitcoin_contribution)
sapply(bitcoin_pm25_tracts_and_tractsPM25, summary)


bitcoin_pm25_tracts_and_tractsPM25_above_zero <- bitcoin_pm25_tracts_and_tractsPM25[bitcoin_pm25_tracts_and_tractsPM25$bitcoin_contribution>=0.01,]

bitcoin_pm25_tracts_and_tractsPM25_above_zero

hist(na.omit(bitcoin_pm25_tracts_and_tractsPM25_above_zero$bitcoin_contribution))

bitcoin_pm25_tracts_and_tractsPM25_above_zero[order(-bitcoin_pm25_tracts_and_tractsPM25_above_zero$bitcoin_contribution),]


ggplot( bitcoin_pm25_tracts_and_tractsPM25_above_zero,
        aes( fill =  bitcoin_contribution)) +
  geom_sf( size = 0, alpha = .9, color = 'NA') +
  geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.05, color='black') +
  #scale_fill_gradient( high = '#2a1c0e', low = 'moccasin',
  #limits = c(0,1), 
  #oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction = 1,limits = c(0,0.1),oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 0) +
  #theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('Bitcoin %Contribution') +
  theme(plot.title = element_text(hjust = 0.5))

nrow(bitcoin_pm25_tracts_and_tractsPM25_above_zero)
bitcoin_pm25_tracts_and_tractsPM25_above_zero


bitcoin_pm25_tracts_and_tractsPM25_above_zero_CSV <- st_drop_geometry(bitcoin_pm25_tracts_and_tractsPM25)
bitcoin_pm25_tracts_and_tractsPM25_above_zero_CSV
# Save the data as a CSV file
write.csv(bitcoin_pm25_tracts_and_tractsPM25_above_zero_CSV,
          "/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/bitcoin_pm25_tracts_and_tractsPM25_above_zero_CSV.csv")




### ZOOMING INTO HOTSPOTS 

exposure_all_black_white_hispanic_corrected_FINAL
#population exposed to at least 0.01ug
sum(exposure_all_black_white_hispanic_corrected_FINAL_above_zero$popultn)

#raise threshold to 0.1ug
exposure_all_black_white_hispanic_corrected_FINAL_above_zero <- exposure_all_black_white_hispanic_corrected_FINAL[exposure_all_black_white_hispanic_corrected_FINAL$TtlPM25>=0.1,]
nrow(exposure_all_black_white_hispanic_corrected_FINAL_above_zero)
#population exposed to at least 0.1ug
sum(na.omit(exposure_all_black_white_hispanic_corrected_FINAL_above_zero$popultn))


#plot only values above 0.1ug
ggplot( exposure_all_black_white_hispanic_corrected_FINAL_above_zero,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 0, alpha = .9, color = 'NA') +
  geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.05, color='black') +
  #scale_fill_gradient( high = '#2a1c0e', low = 'moccasin',
  #limits = c(0,1), 
  #oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction = 1,limits = c(0,.5),oob = scales::squish, alpha =0.9)+
  
  expand_limits( fill = 0) +
  #theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  ggtitle('Total PM2.5 > 0.1 Only - Census Tract Level - InMAP (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


# plot only tracts with exposure >0.1ug

ggplot( exposure_all_black_white_hispanic_corrected_FINAL_above_zero,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,1),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('Above 0.1 Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


#divide them by state

### NYC NJ HOTSPOT 

NY_NJ_tracts = exposure_all_black_white_hispanic_corrected_FINAL_above_zero[(exposure_all_black_white_hispanic_corrected_FINAL_above_zero$STUSPS %in% c('NY','NJ')),]

NY_NJ_tracts


counties_NY_NJ_hotspot = unique(NY_NJ_tracts$NAMELSADC)
counties_NY_NJ_hotspot = c("Queens County", "Kings County", "New York County" , 
                           "Bronx County","Richmond County", 'Hudson County')


NY_NJ_hotspot_all = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% counties_NY_NJ_hotspot) & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('NY','NJ')),]
NY_NJ_hotspot_all

median(na.omit(NY_NJ_hotspot_all$pct_blc))


exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% 'New York County') & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('NY','NJ')),]

#load NY shapefile with higher definitions
NY_SHAPEFILE = st_read(
  "/Users/gianlucaguidi/Downloads/nyct2020_24b/nyct2020.shp")
st_crs(NY_SHAPEFILE)
NY_SHAPEFILE <- st_transform(NY_SHAPEFILE, crs = st_crs(exposure_all_black_white_hispanic_corrected_FINAL))
NY_SHAPEFILE

NJ_SHAPEFILE = st_read(
  "/Users/gianlucaguidi/Downloads/tl_2019_34017_faces/tl_2019_34017_faces.shp")
st_crs(NY_SHAPEFILE)
NJ_SHAPEFILE <- st_transform(NJ_SHAPEFILE, crs = st_crs(exposure_all_black_white_hispanic_corrected_FINAL))


merged_NYC <- NY_SHAPEFILE %>% 
  st_join(NY_NJ_hotspot_all, by = "GEOID")

names(merged_NYC)
names(merged_NJ)
columns_to_keep = c("TtlPM25" ,"popultn", "pct_wht"   ,"pct_blc"  ,  "pct_asn"  ,  "pct_hsp"  ,  "pct_ntv" ,   "ethnc_f"  ,  "md_hsh_"   
                    ,"md_fml_", "pct_pvr" ,"md_prp_"  ,  "pop_wht", "pp_blck", "pp_hspn","geometry")

merged_NJ <-NJ_SHAPEFILE %>% 
  st_join(NY_NJ_hotspot_all, by = "GEOID")

NY_NJ_hotspot_all

merged_NJ = merged_NJ %>% select(all_of(columns_to_keep))
merged_NYC = merged_NYC %>% select(all_of(columns_to_keep))

merged_NJ
merged_NYC_NJ = rbind(merged_NYC, merged_NJ)

ggplot( merged_NYC_NJ,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('NYC - NJ Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

NY_NJ_hotspot_all[order(-NY_NJ_hotspot_all$TtlPM25),]

NY_NJ_hotspot_all$STUPS %in%c('NY')

NY_NJ_hotspot_all[(NY_NJ_hotspot_all$STUSPS %in% c('NJ')),][order(-NY_NJ_hotspot_all[(NY_NJ_hotspot_all$STUSPS %in% c('NJ')),]$TtlPM25),]

### TEXAS HOTSPOT 

TX_tracts = exposure_all_black_white_hispanic_corrected_FINAL_above_zero[(exposure_all_black_white_hispanic_corrected_FINAL_above_zero$STUSPS %in% c('TX','LA')),]

TX_tracts

counties_TX_hotspot = unique(TX_tracts$NAMELSADC)
counties_TX_hotspot

counties_TX_hotspot_1 = c('Titus County','Cass County','Smith County','Morris County', 'Marion County','Camp County', 'Bowie County','Wood County',
                          'Upshur County','Gregg County','Panola County','Rusk County', 'Harrison County', 'Caddo Parish County')

counties_TX_hotspot_2 = c('Harris County','Fort Bend County','Wharton County', "Travis County","Fayette County",
                          "Brazoria County","Matagorda County","Bastrop County","Colorado County","Austin County",
                          'Waller County')


TX_hotspot_all = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% counties_TX_hotspot) & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('TX','LA')),]
TX_hotspot_1 = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% counties_TX_hotspot_1) & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('TX')),]
TX_hotspot_2 = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% counties_TX_hotspot_2) & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('TX')),]



IL_KY_hotspot_all[order(-IL_KY_hotspot_all$TtlPM25),]



ggplot( TX_hotspot_all,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.5) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  geom_sf_text(aes(label = NAMELSADC) ,check_overlap = TRUE, data = )+
  scale_fill_viridis_c(option='magma',direction=-1,limits = c(0,.5),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('TX Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


ggplot( TX_hotspot_all,
        aes( fill =  TtlPM25
        )) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  geom_sf_text(aes(label = NAMELSADC) ,check_overlap = TRUE, data = )+
  scale_fill_viridis_c(option='magma',direction=-1,limits = c(0,1),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('TX Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


ggplot( TX_hotspot_1,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  #geom_sf_text(aes(label = NAMELSADCO) ,check_overlap = TRUE, data = )+
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('TX_1 Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

TX_hotspot_1[order(-TX_hotspot_1$TtlPM25),]



ggplot( TX_hotspot_2,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  #geom_sf_text(aes(label = NAMELSADCO) ,check_overlap = TRUE, data = )+
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  
  ggtitle('TX_2 Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


TX_hotspot_2[order(-TX_hotspot_2$TtlPM25),]


### IL KY hotspot
exposure_all_black_white_hispanic_corrected_FINAL_above_zero

IL_KY_tracts = exposure_all_black_white_hispanic_corrected_FINAL_above_zero[(exposure_all_black_white_hispanic_corrected_FINAL_above_zero$STUSPS %in% c('IL','KY')),]

IL_KY_tracts 
counties_IL_KY_hotspot = unique(IL_KY_tracts$NAMELSADC)

counties_IL_KY_hotspot = c("McCracken County","Massac County", "Pope County", "Ballard County" )
IL_KY_hotspot_all = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$NAMELSADC %in% counties_IL_KY_hotspot) & (exposure_all_black_white_hispanic_corrected_FINAL$STUSPS %in% c('IL','KY','MO')),]


IL_KY_hotspot_all

ggplot( IL_KY_hotspot_all,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = TRUE) +
  geom_sf_text(aes(label = NAMELSADC) ,check_overlap = TRUE, data = )+
  
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1)+
  
  #expand_limits( fill = 0) +
  theme_minimal() +
  theme( legend.position = 'bottom',
         legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),)+
  ggtitle('IL - KY Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

IL_KY_hotspot_all[order(-IL_KY_hotspot_all$TtlPM25),]


sum(NY_NJ_hotspot_all[NY_NJ_hotspot_all$TtlPM25>=0.1,]$popultn)
sum(TX_hotspot_1[TX_hotspot_1$TtlPM25>=0.1,]$popultn)
sum(TX_hotspot_2[TX_hotspot_2$TtlPM25>=0.1,]$popultn)
sum(IL_KY_hotspot_all[IL_KY_hotspot_all$TtlPM25>=0.1,]$popultn)


# check hotsposts values

NY_NJ_hotspot_all$hotspot = 'NY'
TX_hotspot_1$hotspot = 'TX_1'
TX_hotspot_2$hotspot = 'TX_2'
IL_KY_hotspot_all$hotspot = 'IL_KY'


concatenated_hotspots <- rbind(NY_NJ_hotspot_all, TX_hotspot_1,TX_hotspot_2,IL_KY_hotspot_all)
concatenated_hotspots_csv = st_drop_geometry(concatenated_hotspots)

concatenated_hotspots_csv

write.csv(concatenated_hotspots_csv, "hotsposts_exposures_demographic.csv", row.names = FALSE)


#PM
tracts_exp_sf_totPM25_finest_res_103k

counties_to_zoom_in = c('New York County','Hudson County','Richmond County', 'Queens County', 'Bronx County', 'Kings County')

tracts_exp_sf_totPM25_finest_res_103k_NY = tracts_exp_sf_totPM25_finest_res_103k[(tracts_exp_sf_totPM25_finest_res_103k$NAMELSADCO %in% counties_to_zoom_in) & (tracts_exp_sf_totPM25_finest_res_103k$STUSPS %in% c('NY','NJ')),]
tracts_exp_sf_totPM25_finest_res_103k_NY

pm25 <- ggplot( NY_NJ_hotspot_all,
                aes( fill =  TotalPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = FALSE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1, na.value='white')+
  
  #expand_limits( fill = 0) +
  #theme_minimal() +
  #theme( legend.position = 'bottom',
  #      legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),)+
  ggtitle('Bitcoin PM 2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))



### plotting the map FINAL MAP OFFICIAL for PAPER
#plot only values above 0.1
exposure_all_black_white_hispanic_corrected_FINAL_above_zero = exposure_all_black_white_hispanic_corrected_FINAL[(exposure_all_black_white_hispanic_corrected_FINAL$TtlPM25>0.01),]

ggplot(exposure_all_black_white_hispanic_corrected_FINAL_above_zero, aes(fill = TtlPM25)) +
  geom_sf(data = us.sf, fill = 'lightyellow', size = .5, linewidth = .09, color = 'black') +
  geom_sf(size = 0, alpha = 1, color = 'NA') +
  scale_fill_viridis_c(option = 'magma', direction = 1, limits = c(0, .5), oob = scales::squish, alpha = 1) +
  expand_limits(fill = 0) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank(),
        legend.position = 'bottom',
        legend.title = element_text(color = "black", size = 9),
        legend.text = element_text(angle = 30),
        plot.title = element_text(hjust = 0.5)) +
  labs(fill = "Additional PM2.5 attributable to Mines\n(annual average concentration, µg/m³)")

################################################################################################################################################
### plotting the 4 hotspots FINAL OFFICIAL for PAPER ###################################################################################################
#############################################################################################################################################
install.packages("ggspatial")
library(ggspatial)

ggplot( merged_NYC_NJ,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = FALSE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1, na.value='white')+
  annotation_scale(
    location = "br",  # Change location: 'tl' = top left, 'tr' = top right, 'bl' = bottom left, 'br' = bottom right
    width_hint = 0.25, 
    unit_category = "imperial",  # Change to "metric" for kilometers/meters
    height = unit(0.2, "cm"),
    #text_col = "blue",  # Change text color of the scale bar
    bar_cols = c("grey", "white"),  # Change colors of the scale bar
  ) +
  #expand_limits( fill = 0) +
  #theme_minimal() +
  #theme( legend.position = 'bottom',
  #      legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  ggtitle('NYC PM2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))



ggplot( TX_hotspot_1,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = FALSE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1, na.value='white')+
  annotation_scale(
    location = "br",  # Change location: 'tl' = top left, 'tr' = top right, 'bl' = bottom left, 'br' = bottom right
    width_hint = 0.25, 
    unit_category = "imperial",  # Change to "metric" for kilometers/meters
    height = unit(0.2, "cm"),
    #text_col = "blue",  # Change text color of the scale bar
    bar_cols = c("grey", "white"),  # Change colors of the scale bar
  ) +
  #expand_limits( fill = 0) +
  #theme_minimal() +
  #theme( legend.position = 'bottom',
  #      legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  ggtitle('TX_1 PM2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

ggplot( TX_hotspot_2,
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = FALSE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1, na.value='white')+
  annotation_scale(
    location = "br",  # Change location: 'tl' = top left, 'tr' = top right, 'bl' = bottom left, 'br' = bottom right
    width_hint = 0.25, 
    unit_category = "imperial",  # Change to "metric" for kilometers/meters
    height = unit(0.2, "cm"),
    #text_col = "blue",  # Change text color of the scale bar
    bar_cols = c("grey", "white"),  # Change colors of the scale bar
  ) +
  #expand_limits( fill = 0) +
  #theme_minimal() +
  #theme( legend.position = 'bottom',
  #      legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  ggtitle('TX_2 PM2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))

ggplot( IL_KY_hotspot_all, 
        aes( fill =  TtlPM25)) +
  geom_sf( size = 2, alpha = 1., color = 'darkgrey',show.legend = FALSE) +
  #geom_sf( data = us.sf, fill = NA, size = .5, linewidth=.005) +
  #scale_fill_gradient( high = 'red', low = 'white',
  #limits = c(1,2), 
  #                    oob = scales::squish) +
  scale_fill_viridis_c(option='magma',direction=1,limits = c(0,.5),oob = scales::squish, alpha =1, na.value='white')+
  annotation_scale(
    location = "br",  # Change location: 'tl' = top left, 'tr' = top right, 'bl' = bottom left, 'br' = bottom right
    width_hint = 0.25, 
    unit_category = "imperial",  # Change to "metric" for kilometers/meters
    height = unit(0.2, "cm"),
    #text_col = "blue",  # Change text color of the scale bar
    bar_cols = c("grey", "white"),  # Change colors of the scale bar
  ) +
  #expand_limits( fill = 0) +
  #theme_minimal() +
  #theme( legend.position = 'bottom',
  #      legend.text = element_text( angle = 30))  +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  ggtitle('KY/IL PM2.5 (µg/m3)') +
  theme(plot.title = element_text(hjust = 0.5))


####################################################################################



###### plot with arrows and lines
library(readr)


df_miners_load_on_plants <-read_csv(
  "/Users/gianlucaguidi/Library/CloudStorage/GoogleDrive-g.guidi15@studenti.unipi.it/My Drive/BostonProject/df_miners_to_plants_ALL_final_light.csv")
unique(df_miners_load_on_plants$id)
df_miners_load_on_plants


df_miners_load_on_plants = df_miners_load_on_plants[-(which(df_miners_load_on_plants$fuel == "HYDRO")),]
df_miners_load_on_plants = df_miners_load_on_plants[-(which(df_miners_load_on_plants$fuel == "SOLAR")),]
df_miners_load_on_plants = df_miners_load_on_plants[-(which(df_miners_load_on_plants$fuel == "OIL")),]



df_miners_load_on_plants_sf_PLANTS <-
  st_as_sf( df_miners_load_on_plants,
            coords = c( 'plant_LON', 'plant_LAT'),
            crs ='WGS84' )

df_miners_load_on_plants_sf_PLANTS

df_miners_load_on_plants_sf_PLANTS_tot_miner_marginalMW = df_miners_load_on_plants_sf_PLANTS %>%
  group_by(plant, fuel) %>%
  summarise(miners_tot_marginal_MW = sum(marginalMW_wattime)) 
df_miners_load_on_plants_sf_PLANTS_tot_miner_marginalMW

df_miners_load_on_plants_sf_MINERS <-
  st_as_sf( df_miners_load_on_plants,
            coords = c( 'miner_LON', 'miner_LAT'),
            crs ='WGS84' )

df_miners_load_on_plants_sf_MINERS

df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW = df_miners_load_on_plants_sf_MINERS %>%
  group_by(id, company) %>%
  summarise(miners_tot_marginal_MW = sum(marginalMW_wattime)) 
df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW



us.sf <- st_transform(us.sf, crs = 'WGS84')


df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW


df_miners_load_on_plants_above_percentile = df_miners_load_on_plants[
  (df_miners_load_on_plants$pm25_lbs_wattime>quantile(df_miners_load_on_plants$pm25_lbs_wattime, probs = .98)),]

df_miners_load_on_plants

unique(df_miners_load_on_plants$fuel)
df_miners_load_on_plants

library(ggrepel)
df_miners_load_on_plants_sf_PLANTS_tot_miner_marginalMW
#plot all
options(scipen=10000)

ggplot( ) +
  geom_sf( data = us.sf, fill = 'white', size = 2, colour='grey28')  +
  #scale_size_continuous(name = "Bitcoin Miner Capacity Size (MW)") +
  #plot edges 
  
  geom_curve(data = df_miners_load_on_plants, aes(x = miner_LON, y = miner_LAT,
                                                  xend = plant_LON, yend = plant_LAT, #linewidth = log(pm25_lbs_wattime)
  ),
  linewidth=0.3,
  color = "darkgrey", alpha=0.08,
  curvature = 0.3,
  angle = 90,
  show.legend = TRUE) +  
  
  #plot plants
  geom_sf( data = df_miners_load_on_plants_sf_PLANTS_tot_miner_marginalMW,
           aes(color=fuel, size =miners_tot_marginal_MW/1e6 )) +
  scale_color_manual(values = c("red", "skyblue3", "tomato4"),name = "Plant Primary Fuel")+
  
  #geom_text_repel(data = df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW,
  #                x = st_coordinates(df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW$geometry)[, "X"],
  #                y = st_coordinates(df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW$geometry)[, "Y"],
  #                aes(label=company), size=2)+
  
  
  #plot miners
  geom_sf( data = df_miners_load_on_plants_sf_MINERS_tot_miner_marginalMW,
           color='grey20',alpha=0.8, aes(size = miners_tot_marginal_MW/1e6) ,shape = 17) +
  
  #scale_color_discrete() +
  theme(
    legend.position = "right",  # Position the legend on the right side
    legend.direction = "vertical"  # Make the legend vertical
  )+
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        rect = element_blank())+
  #ggtitle('Bitcoin Miners and Power Plants') +
  theme(plot.title = element_text(hjust = 0.5))+
  labs(size = "Bitcoin mine electricity use (TWh)")



