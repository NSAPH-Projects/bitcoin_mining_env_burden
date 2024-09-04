from .config import BASE_DIR, SAVE_PATH
from .data_loader import load_miners_data, save_complete_dataset, load_unit_rates
from .find_miner_emissions import find_miner_emissions
import pandas as pd

def complete_dataset(period = 'monthly', save = True, base_dir = BASE_DIR, save_path = SAVE_PATH):
    """
    Generates and saves a complete dataset of the miners emissions for a specified period.

    Args:
        period (str) : The aggregrations for calculating the emissions (daily or monthly. Deafults to 
                       monthly).
        save (bool, optional): Whether to save the resulting dataset to a CSV file. Defaults to True.
        save_path (str, optional): The path where the dataset should be saved if `save` is True. 
                                   Defaults to SAVE_PATH.

    Returns:
        pd.DataFrame : A DataFrame comtaining the complete emissions data of all the unique miners in 
        the miners data using the find_miner_emissions functions. The data is filtered for the period 
        August 2022 to July 2023. 
    """
    
    #load miners data
    print('complete_dataset', base_dir)
    df_miners = load_miners_data(base_dir=base_dir)
    
    #Initialize an empty list to hold the DataFrames
    df_complete = []

    #Loop over each unique miner ID in df_miners
    for miner in df_miners.id.unique():
        print(miner)
        # Calculate emissions for the uniques miners
        df = find_miner_emissions(miner=miner, period=period, base_dir=base_dir)
        # Append the resulting emissions DataFrame of all the unique miners
        df_complete.append(df)

    #concatenate all the DataFrames in the list into a single DataFrame
    df_complete = pd.concat(df_complete, ignore_index=True)
     
    #group by relevant fields to aggregate emissions data by year and month
    df_complete_peryear_month = df_complete.groupby(['miner', 'plant_unit', 'LAT', 'LON', 'year', 'month']).sum().reset_index()

   #filter for August 2022 to July 2023
    df_complete_2022_2023 = df_complete_peryear_month[
        ((df_complete_peryear_month.year == 2022) & (df_complete_peryear_month.month >= 8)) |
        ((df_complete_peryear_month.year == 2023) & (df_complete_peryear_month.month <= 7))
    ]

    #save the complete dataset
    name = save_path + 'df_complete_2022_2023.csv'
    df_complete_2022_2023.to_csv(name, index=False)
    print(f"Dataset saved to {name}")

    return df_complete_2022_2023