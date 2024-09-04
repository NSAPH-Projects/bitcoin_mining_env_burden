import pandas as pd 
import numpy as np 
from .data_loader import load_miners_data, load_unit_rates, load_moers_data, aggregate_moers_data
from .calculations import calculate_mw_demand, calculate_emissions
from .config import DAYS_PER_YEAR, MONTHS_PER_YEAR


def find_miner_emissions(miner, period=['daily', 'monthly'], wattime_data=[True, False]):
    df_miners = load_miners_data()
    df_unit_rates = load_unit_rates()
    condition = df_miners['id'] == miner
    area = df_miners.loc[condition]['Grid Region'].item()
    df_moers = load_moers_data(area=area)
    date_range = pd.date_range(start='2018-01', end='2023-08', freq='M').strftime('%Y-%m').tolist()

    
    df_daily, df_monthly , n_plants = aggregate_moers_data(df_moers, period)
    start_date = df_miners.loc[condition]['start_date'].dt.to_period('M').item()
    uptime = df_miners[condition]['uptime'].item()

    daily_mw_demanded, monthly_mw_demanded = calculate_mw_demand(df_miners, condition)
    df_moers_num = df_moers.select_dtypes(include = [np.number])

     # DAILY

    if period == 'daily':
        
        #WITHOUT WATTIME DATA
        df_daily1 = df_moers_num.groupby(df_moers['Date'].dt.date).mean() #average per day to get the daily values
        # build a MOER table without considering WATTIMe data (all power plants contribute equally)
        df_daily1[:] = np.where(df_daily[:] > -1 , 1/n_plants, df_daily[:])
        
        df_daily_times_miner1 = df_daily1.multiply(daily_mw_demanded, axis=1) #portion for the current miner supplied by each power plant
        
        df_daily_times_miner1['date'] = pd.to_datetime(df_daily_times_miner1.index)
        df_daily_times_miner1['month'] = pd.DatetimeIndex(df_daily_times_miner1['date']).month
        df_daily_times_miner1['year'] = pd.DatetimeIndex(df_daily_times_miner1['date']).year
        df_daily_times_miner1['day'] = pd.DatetimeIndex(df_daily_times_miner1['date']).day
        df_daily_times_miner1.set_index(['year','month','day'],inplace = True)
        df_daily_times_miner1.pop('date')
        
        transposed_df1 = df_daily_times_miner1.stack().reset_index()
        transposed_df1.rename(columns={"level_3": "plant_unit", 0:'marginalMW'}, inplace = True)
        df_merged1 = pd.merge(transposed_df1, df_unit_rates, right_on = ['plant_unit','month'], left_on = ['plant_unit','month'])
        df_merged1.drop_duplicates(inplace=True)
    
        #WITH WATTIME DATA
        
        #make negative moers = 0
        df_daily[df_daily < 0] = 0
        
        mw_demanded_per_plant_per_day2  = df_daily.multiply(daily_mw_demanded, axis=1)
        mw_demanded_per_plant_per_day2['date'] = pd.to_datetime(mw_demanded_per_plant_per_day2.index)
        mw_demanded_per_plant_per_day2['month'] = pd.DatetimeIndex(mw_demanded_per_plant_per_day2['date']).month
        mw_demanded_per_plant_per_day2['year'] = pd.DatetimeIndex(mw_demanded_per_plant_per_day2['date']).year
        mw_demanded_per_plant_per_day2['day'] = pd.DatetimeIndex(mw_demanded_per_plant_per_day2['date']).day
        mw_demanded_per_plant_per_day2.set_index(['year','month','day'],inplace = True)
        mw_demanded_per_plant_per_day2.pop('date')
        
        transposed_df2 = mw_demanded_per_plant_per_day2.stack().reset_index()
        transposed_df2.rename(columns={"level_3": "plant_unit", 0:'marginalMW'}, inplace = True)
        
        df_merged2 = pd.merge(transposed_df2, df_merged1, right_on = ['plant_unit','year','month','day'], left_on = ['plant_unit','year','month','day'], how='outer')
        df_merged2.rename(columns={"marginalMW_x": "marginalMW_wattime", 'marginalMW_y':'marginalMW_NO_wattime'}, inplace = True)
        
        # Calculate pollutant emissions for both Wattime and NO Wattime or combined 
        df_merged2_light = calculate_emissions(df_merged2, miner, wattime_data, period = 'daily')

        return df_merged2_light
        
    # MONTHLY
    elif period == 'monthly':
        
        #WITHOUT WATTIME DATA
        
        mw_demanded_per_plant_per_month1 = monthly_mw_demanded / n_plants
        # Aggregate from hourly to daily marginal data
        df_monthly1 = df_moers_num.groupby(df_moers['Date'].dt.to_period('M')).mean() # Aggregate from daily to monthly marginal data
        # build a MOER table without considering WATTIMe data (all power plants contribute equally)
        df_monthly1[:] = np.where(df_monthly[:] > -1 , 1/n_plants, df_monthly[:])
        
        df_monthly_times_miner1 = df_monthly1.multiply(monthly_mw_demanded, axis=1) #portion for the current miner supplied by each power plant
        
        # create a moers df starting 2018
        cols = list(df_monthly_times_miner1.columns)
        
        df_monthly_times_miner2 = pd.DataFrame(columns=cols, index=date_range)
        df_monthly_times_miner2.index = pd.to_datetime(df_monthly_times_miner2.index).to_period('M')
        df_monthly_times_miner2 = df_monthly_times_miner2.fillna(df_monthly_times_miner1.iat[0, 0]) # select one value from the df_monthly_times_miner1 table (theyre all the same!)
        
        
        #start date (select only month in which the miner was operating)
        df_monthly_times_miner2 = df_monthly_times_miner2.loc[(df_monthly_times_miner2.index > start_date)] 
        
        df_monthly_times_miner2['month'] = df_monthly_times_miner2.index.month
        df_monthly_times_miner2['year'] = df_monthly_times_miner2.index.year
        df_monthly_times_miner2.set_index(['year','month'],inplace = True)
        
        transposed_df = df_monthly_times_miner2.stack().reset_index()
        transposed_df.rename(columns={"level_2": "plant_unit", 0:'marginalMW'}, inplace = True)
        df_merged = pd.merge(transposed_df, df_unit_rates, right_on = ['plant_unit','month'], left_on = ['plant_unit','month'])
        
    
        #WITH WATTIME DATA
        df_monthly[df_monthly < 0] = 0
        
        mw_demanded_per_plant_per_month2  = df_monthly.multiply(monthly_mw_demanded, axis=1)
        
        #start date
        mw_demanded_per_plant_per_month2 = mw_demanded_per_plant_per_month2.loc[(mw_demanded_per_plant_per_month2.index > start_date)]
        
        mw_demanded_per_plant_per_month2['month'] = mw_demanded_per_plant_per_month2.index.month
        mw_demanded_per_plant_per_month2['year'] = mw_demanded_per_plant_per_month2.index.year
        mw_demanded_per_plant_per_month2.set_index(['year','month'],inplace = True)
        
        transposed_df = mw_demanded_per_plant_per_month2.stack().reset_index()
        transposed_df.rename(columns={"level_2": "plant_unit", 0:'marginalMW'}, inplace = True)
        df_merged2 = pd.merge(transposed_df, df_merged, right_on = ['plant_unit','year','month'], left_on = ['plant_unit','year','month'], how='outer')
        df_merged2.rename(columns={"marginalMW_x": "marginalMW_wattime", 'marginalMW_y':'marginalMW_NO_wattime'}, inplace = True)
    

     # Calculate pollutant emissions for both Wattime and NO Wattime or combined 
        df_merged2_light = calculate_emissions(df_merged2, miner, wattime_data, period = 'monthly')

        return df_merged2_light
        
        