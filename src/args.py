""" CLI argument definitions """

from argparse import ArgumentParser, RawDescriptionHelpFormatter


parser = ArgumentParser(
    description=__doc__,
    formatter_class=RawDescriptionHelpFormatter)

group = parser.add_mutually_exclusive_group(required=True)

group.add_argument('--emissions', dest='emissions', action='store_true', default=False, help='Calculate emissions and create the dataset.')

group.add_argument('--inmap', dest='inmap', action='store_true', default=False, help='Inmap processing using the complete dataset.')

parser.add_argument('--base_dir', required=True, help='Base directory for the data.')

parser.add_argument('--save_path', required=True, help='Output directory for the dataset.')