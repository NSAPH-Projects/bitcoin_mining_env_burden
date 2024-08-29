#config.py 
import os 
import pandas as pd 

#root/base directory 
BASE_DIR = '/net/rcstorenfs02/ifs/rc_labs/dominici_lab/lab/data_processing/mahima_bitcoin_mining_env_burden/'

#file paths
MINERS_FILE_PATH = os.path.join(BASE_DIR,'data/input_private/crypto_loc_summary_calvertcity.xlsx')
UNIT_RATES_FILE_PATH = os.path.join(BASE_DIR,'data/input_private/condensed_unit_rates.csv')
MOERS_BASE_PATH = os.path.join(BASE_DIR,'data/input_private/')

#time config 
HOURS_PER_DAY = 24 
DAYS_PER_YEAR = 365 
MONTHS_PER_YEAR = 12 

#save complete dataset path 
SAVE_PATH = '/net/rcstorenfs02/ifs/rc_labs/dominici_lab/lab/data/bitcoin_mining_env_burden/intermediate/df_complete_2022_2023.csv'
