import pandas as pd 
import geopandas as gpd 

def inmap_data(input_data, output_data_path):

    """
    Processes emissions data and saves it as a shapefile.

    Args:
        input_data (str) : Path to input csv file containing the emissions data. The csv should 
        include columns such as 'LAT', 'LON', 'co2_lbs_wattime', 'so2_lbs_wattime', 
        'nox_lbs_wattime', and 'pm25_lbs_wattime'.

        output_data_path (str) : Path where the output shapfile files will be saved. The shapefile 
        will contain geometries (points) and converted lbs to kg attributes ('PM2_5','NOx','SOx').

    """

    #load the data 
    df = pd.read_csv(input_data)

    #aggregate the data on LAT and LON 

    df_aggregated = df.groupby(['LAT', 'LON']).sum().reset_index()[['LAT', 'LON', 
                                                                    'co2_lbs_wattime', 
                                                                    'so2_lbs_wattime', 
                                                                    'nox_lbs_wattime', 
                                                                    'pm25_lbs_wattime']]
    
    #create geodataframe and convert crs 
    gdf = gpd.GeoDataFrame(
        df_aggregated, 
        geometry = gpd.points_from_xy(df_aggregated.LON, df_aggregated.LAT),
        crs = 'WGS84'
    ).to_crs('ESRI:102003')

    #convert pollutant values from lbs to kg and rename columns 
    gdf['PM2_5'] = gdf['pm25_lbs_wattime'] * 0.453592
    gdf['NOx'] = gdf['nox_lbs_wattime'] * 0.453592
    gdf['SOx'] = gdf['so2_lbs_wattime'] * 0.453592

    #display the final GeoDataFrame before saving 
    print(gdf[['geometry', 'PM2_5','NOx','SOx']])

    #select and save the dataset 
    gdf[['geometry', 'PM2_5','NOx','SOx']].to_file(output_data_path)

