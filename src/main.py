import sys
import os 
import warnings
warnings.filterwarnings('ignore')

from args import parser

sys.path.append(os.path.abspath(os.path.join('../src')))

from emission_calculator import complete_dataset
from inmap_processing import inmap_data

def main(args_list=None):
    if args_list is None:
        args_list = sys.argv[1:]
    args = parser.parse_args(args_list)
    if args.emissions:
        complete_dataset(base_dir=args.base_dir, save_path=args.save_path)
    else:
        #check to make sure that input data is the complete dataset
        path = args.base_dir + 'df_complete_2022_2023.csv'
        if not os.path.isfile(path):
            raise ValueError('Cannot find a file named df_complete_2022_2023.csv in the base_dir specified.')
        #check to make sure that save_path is a directory
        if not os.path.isdir(args.save_path):
            raise ValueError('Specified save_path is not a valid directory. Please specify a directory in which to save the output.')
        save_path = args.save_path + '/emissions_2022_2023/'
        os.makedirs(save_path)
        inmap_data(input_data=path, output_data_path=save_path)

if __name__ == '__main__':
    main()
