#data_loader.py
from .config import MINERS_FILE_PATH, UNIT_RATES_FILE_PATH, MOERS_BASE_PATH, SAVE_PATH
import pandas as pd 
import numpy as np 
import openpyxl

def load_miners_data():
    '''
    Loads the miners data from an Excel file.

    Returns:
        pd.DataFrame : A DataFarme containing the miner data. 
    '''
    return pd.read_excel(MINERS_FILE_PATH)

def load_unit_rates():
    """
    Loads the unit rates data from CSV file, and removes any unnecessary columns.

    Returns: 
        A DataFrame containing the unit rates data.
    """
    df_unit_rates = pd.read_csv(UNIT_RATES_FILE_PATH)
    df_unit_rates = df_unit_rates.drop('Unnamed: 0', axis =1)
    return df_unit_rates

def load_moers_data(area):
    """
    Loads The MOERS(Marginal Operating Emissions Rates) data for a specific area from a CSV file 
    and converts the data column to datetime format.

    Args:
        area (str) : The area for which the MOERS data is to be loaded.

    Returns: 
        A DataFrame containing he MOERS adta for a specified area with teh date columns converted to
        datetime format.
    """
    df_moers = pd.read_csv(f'{MOERS_BASE_PATH}/{area}_plant_mix.csv')
    df_moers['Date'] = pd.to_datetime(df_moers[f'{df_moers.columns[0]}'])
    return df_moers


def aggregate_moers_data(df_moers, period):
    """
    Aggregrates the MOERS data on a daily and monthly basis. 

    Args:
        df_moers (pd.DataFrame) : The MOERS data to be aggregated based on the area selected. 
        period (str) : The time period for aggreagtion (could be either daily or monthly).

    Returns: 
        - df_daily dataframe : Average per day to get the daily values.
        - df_monthly : Aggregate from daily to monthly marginal data.
        - int : The number of plants in the aggreagted data, determined by the number of numerical 
          columns in the DataFrame. 

    Notes:
        The `df_moers_num` variable is created by selecting only the numerical columns 
        from the `df_moers` DataFrame. This ensures that only relevant numerical data is 
        included in the aggregation process. Non-numerical columns like 'Date' are 
        excluded from this aggregation.
    """

    df_moers_num = df_moers.select_dtypes(include = [np.number])
    df_daily = df_moers_num.groupby(df_moers['Date'].dt.date).mean()
    n_plants = len(df_daily.columns)
    df_monthly = df_moers_num.groupby(df_moers['Date'].dt.to_period('M')).mean()
    return df_daily, df_monthly, n_plants

def save_complete_dataset(df, filepath=SAVE_PATH):
    """
    Save the complete dataset to the specified filepath.
    
    Args:
        df: The DataFrame to be saved.
        filepath: The path where the DataFrame will be saved. Defaults to the value in config.py.
    """
    df.to_csv(filepath, index=False)
    print(f"Dataset saved to {filepath}")

if __name__ == "__main__":
    #test loading miners data
    miners_data = load_miners_data()
    print("Miners Data:")
    print(miners_data.head())

    #test loading unit rates data 
    unit_rates = load_unit_rates()
    print("Unit Rates Data:")
    print(unit_rates.head())

    #test loading moers data for a specific area
    area = 'ERCOT_EASTTX'
    df_moers = load_moers_data()
    print(f"Moers Data for {area}:")
    print(df_moers.head())

  