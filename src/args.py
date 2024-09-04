""" CLI argument definitions """

from argparse import ArgumentParser, RawDescriptionHelpFormatter


parser = ArgumentParser(
    description=__doc__,
    formatter_class=RawDescriptionHelpFormatter)

parser.add_argument(
    '--base_dir',
    required=True,
    help='Base directory for the data.'
    )

parser.add_argument(
    '--save_path',
    help='Output directory for the dataset.')

group = parser.add_mutually_exclusive_group(required=True)

group.add_argument('--daily', dest='daily', action='store_true', default=False,
    help='Calculate daily.')

group.add_argument('--monthly', dest='monthly', action='store_true', default=False,
    help='Calculate monthly.')
