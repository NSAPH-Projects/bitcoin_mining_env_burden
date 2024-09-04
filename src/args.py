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