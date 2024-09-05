# Bitcoin Mining Environmental Burden Analysis

## Overview

This repository contains code and data for analyzing the environmental burden of Bitcoin mining. The entire data pipeline identifies the annual emissions that each plant produces due to the Bitcoin miner’s marginal electricity demand.

## Table of Contents

1. [Introduction](#introduction)
2. [Repository Structure](#repository-structure)
3. [Installation](#installation)
4. [Data](#data)
5. [Emission Calculator Module](#emission-calculator-module)
6. [InMAP Processing Module](#inmap-processing-module)
7. [Pipeline](#pipeline)

## Introduction

Bitcoin mines, massive computing clusters generating cryptocurrency tokens, consume vast amounts of electricity. The amount of fine particle (PM2.5) air pollution created due to their electricity consumption, and its effect on environmental health, is explored in this study. We identified the largest mines in the United States in 2022, the electricity-generating plants responding to their demand, and the communities most affected by Bitcoin mine-attributable air pollution. This repository provides the tools and data necessary to reproduce our analysis.

## Repository Structure 
- `data/`: This directory contains subfolders for input and output files. It includes symlinks to the actual data files and documentation for internal use.<br>
  - `input_private/`: A folder containing the raw datasets related to Bitcoin mining and environmental impact that need to be processed.
  - `intermedidate/`: A folder where intermediate datasets are stored during the data processing workflow. These datasets serve as checkpoints or partial results that facilitate step-by-step data processing.
- `notes/` : ncludes python files related to data analysis, exploration and visualization.
- `src/`: Contains the main modules and scripts used in the analysis.
  - `emission_calculator/`: This module calculates environmental emissions related to Bitcoin mining operations.
  - `inmap_processing/`: This module handles the processing of data for InMAP (Intervention Model for Air Pollution) tasks.
- `README.md`: Provides an overview of the project, including instructions on how to set up the environment and run the analysis.
- `requirements.yml`: Conda environment setup and lists the Python packages required to run the scripts. 


## Installation

To get started with this project, you need to set up your development environment. Follow these steps:

 1. **Clone the Repository**

    Clone the repository and create a conda environment.

    ```bash
    git clone <https://github.com/<user>/repo>
    cd <repo>

    conda env create -f requirements.yml
    conda activate <env_name>
    ```

2. **Prepare your Data**

    Add symlinks to input, and intermediate folders inside the corresponding /data subfolders.
    For example:

    ```bash
    export HOME_DIR=$(pwd)

    cd $HOME_DIR/data/
    ln -s <input_path> .

    cd $HOME_DIR/data/
    ln -s <intermediate_path> .
    ```
 The README.md files inside the /data contain path documentation for NSAPH internal purposes.

## Data 

This project relies on various datasets that provide crucial information about Bitcoin miners, power plants, demographic data, and environmental factors such as air pollution. The datasets are organized and linked within the project directory structure for efficient processing and analysis.

Below are the datasets included in the input_private folder:

### Bitcoin Miners Data
- **File Name**: `crypto_loc_summary_calvertcity.xlsx`
- **Description**: This file contains detailed information about Bitcoin miners, including their geographic locations and operational data. It serves as a primary dataset for understanding the distribution and impact of Bitcoin mining activities.

### WattTime Balancing Authorities Files
- **File Name**: `{area}_plant_mix.csv`
- **Description**: These files contain marginal power contribution coefficients for 19 power plants within different balancing authorities. The data allows you to evaluate the impact of specific power plants on energy consumption and the corresponding emissions related to Bitcoin mining.

### Power Plants Specs (Condensed Unit Rates)
- **File Name**: `condensed_unit_rates.csv`
- **Description**: This dataset provides essential specifications and unit rates for power plants, enabling a detailed analysis of their operational efficiency and environmental impact.


Below are the datasets included in the intermediate folder:

### Complete Emissions Dataset 
- **File Name** : `df_complete_2022_2023.csv`
- **Description** :  This dataset includes emissions data for all miners between August 2022 and July 2023. 

### Emissions Shapefiles 
- **File Name**: `emissions_2022_2023`
- **Description** : The set of files with the prefix emissions_2022_2023 represents a geospatial dataset in shapefile format. These dataset contains spatial information related to emissions, such as the geographic distribution of emissions, which can be visualized using GIS software. 

## Emission Calculator Module

The 'emission_calculator` module calculates the enviormental emissions of all the plants, particularly in terms of emissions such as CO2, NOx, SO2, and PM2.5. It includes scripts for loading the data, performing the calculations and processing the complete emissions datasets. The core functionality of the module incldues : 
- **Loading Data**: Use functions in data_loader.py to load data related to miners, MOERs, and unit rates.
- **Calculating Emissions**: The primary function, find_miner_emissions, calculates emissions for a given miner and period.
- **Processing a Complete Dataset**: Use complete_dataset to process emissions data for all miners and save the results.

## InMAP Processing Module 

The 'inmap_processing' module processes emissions data and output it in a geospatial format suitable for InMAP modeling. This module specifically converts emissions data into shapefiles, allowing for spatial analysis and visualization of environmental impacts across different geographic locations. 

## Pipeline 

Run the script directly using Python, passing parameters via the command line (if required) to execute the full workflow: 

```bash
python src/main.py --emissions --base_dir <path_to_base_directory> --save_path <path_to_save_directory>
```



