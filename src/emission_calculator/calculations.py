import numpy as np 
import pandas as pd 
from .config import HOURS_PER_DAY, DAYS_PER_YEAR, MONTHS_PER_YEAR

def calculate_mw_demand(df_miners, condition):
    """
    Calculate the MW demand for a miner based on power capacity and uptime.

   Args:
        df_miners (pd.DataFrame): DataFrame containing the miner information.
        condition (pd.Series): Condition to select the specific miner.

    Returns:
        tuple: daily_mw_demanded, monthly_mw_demanded
    """
    # Extract the power capacity in MW for the selected miner
    mw_power_capacity = df_miners.loc[condition, 'mw'].item()
    
    # Calculate the yearly MW demand at full capacity
    yearly_mw_demand = mw_power_capacity * HOURS_PER_DAY * DAYS_PER_YEAR * df_miners.loc[condition, 'uptime'].item()
        
    # Calculate the daily and monthly MW demand
    daily_mw_demanded = yearly_mw_demand / DAYS_PER_YEAR
    monthly_mw_demanded = yearly_mw_demand / MONTHS_PER_YEAR
    
    return daily_mw_demanded, monthly_mw_demanded

def calculate_emissions(df_merged2, miner, wattime_data, period='daily'):
    """
    Calculate pollutant emissions for both Wattime and NO Wattime scenarios.

    Args:
    df_merged2 : pandas.DataFrame
        A DataFrame containing the merged data for marginal MW and pollutant rates.
        It should include columns for 'marginalMW_wattime', 'marginalMW_NO_wattime',
        and the pollutant-specific rates (e.g., 'co2_lbs_per_mwh', 'nox_lbs_per_mwh').

    miner : str
        The identifier for the miner. This value is added as a column in the output DataFrame.

    wattime_data : bool or None
        A flag to determine which set of emissions data to return:
        - If True, return only Wattime-related columns.
        - If False, return only NO Wattime-related columns.
        - If None, return both Wattime and NO Wattime columns.

    period : str, optional (default='daily')
        The period of the data being processed. It can be either 'daily' or 'monthly':
        - 'daily' includes the 'day' column in the final DataFrame.
        - 'monthly' excludes the 'day' column.

    Returns:
        A DataFrame with the calculated emissions data, including the appropriate columns
        based on the `wattime_data` flag and the selected period.

    """
    # Define the pollutants to calculate emissions for
    pollutants = ['co2', 'nox', 'so2', 'pm25']

    # Compute emissions for both Wattime and NO Wattime scenarios
    for pollutant in pollutants:
        df_merged2[f'{pollutant}_lbs_wattime'] = df_merged2['marginalMW_wattime'] * df_merged2[f'{pollutant}_lbs_per_mwh']
        df_merged2[f'{pollutant}_lbs_NO_wattime'] = df_merged2['marginalMW_NO_wattime'] * df_merged2[f'{pollutant}_lbs_per_mwh']

    df_merged2.drop_duplicates(inplace=True)
    df_merged2['miner'] = miner

    if period == 'daily':
        columns_base = ['year', 'month', 'day', 'miner', 'plant_unit', 'height', 'temp', 'diam', 'velocity', 'PlumeHeight', 'LAT', 'LON']
    elif period == 'monthly':
        columns_base = ['year', 'month', 'miner', 'plant_unit', 'LAT', 'LON']  # No 'day' column for monthly data
    else:
        raise ValueError("Invalid period specified. Use 'daily' or 'monthly'.")

    columns_no_wattime = columns_base + ['marginalMW_NO_wattime'] + [f'{pollutant}_lbs_NO_wattime' for pollutant in pollutants]
    columns_wattime = columns_base + ['marginalMW_wattime'] + [f'{pollutant}_lbs_wattime' for pollutant in pollutants]
    columns_combined = columns_base + ['marginalMW_wattime', 'marginalMW_NO_wattime'] + [f'{pollutant}_lbs_wattime' for pollutant in pollutants] + [f'{pollutant}_lbs_NO_wattime' for pollutant in pollutants]
    
    # Select columns based on wattime_data flag
    if wattime_data == False:
        df_merged2_light = df_merged2[columns_no_wattime]
    elif wattime_data == True:
        df_merged2_light = df_merged2[columns_wattime]
    else:
        df_merged2_light = df_merged2[columns_combined]

    return df_merged2_light



