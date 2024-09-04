import sys
import os 
import warnings
warnings.filterwarnings('ignore')

from args import parser

sys.path.append(os.path.abspath(os.path.join('../src')))

from emission_calculator import complete_dataset

def main(args_list=None):
    if args_list is None:
        args_list = sys.argv[1:]
    args = parser.parse_args(args_list)

    if args.daily:
        period = 'daily'
    else:
        period = 'monthly'
    
    if args.save_path:
        complete_dataset(period=period, base_dir=args.base_dir, save_path=args.save_path)
    else:
        complete_dataset(period=period, base_dir=args.base_dir)
if __name__ == '__main__':
    main()
