# Bitcoin Mining Environmental Burden Analysis

## Overview

This repository contains code and data for analyzing the environmental burden of Bitcoin mining. The project utilizes various Python libraries and tools to explore and visualize the impact of Bitcoin mining on different environmental factors.

## Table of Contents

1. [Introduction](#introduction)
2. [Repository Structure](#repository-structure)
3. [Installation](#installation)
4. [Data](#data)

## Introduction

Bitcoin mines, massive computing clusters generating cryptocurrency tokens, consume vast amounts of electricity. The amount of fine particle (PM2.5) air pollution created due to their electricity consumption, and its effect on environmental health, is explored in this study. We identified the largest mines in the United States in 2022, the electricity-generating plants responding to their demand, and the communities most affected by Bitcoin mine-attributable air pollution. This repository provides the tools and data necessary to reproduce our analysis.

## Repository Structure 
- data/: This directory contains subfolders for input and output files. It includes symlinks to the actual data files and documentation for internal use.<br>
  - input/: Contains symlinks to the raw datasets related to Bitcoin mining and environmental impact that need to be processed.<br>
  - output/: The directory where processed datasets are saved. These datasets include relevant details along with labels indicating environmental factors or impacts.<br>
- README.md: Provides an overview of the project, including instructions on how to set up the environment and run the analysis.
- requirements.yml: Conda environment setup and lists the Python packages required to run the scripts. 


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

    Add symlinks to input, and output folders inside the corresponding /data subfolders.
    For example:

    ```bash
    export HOME_DIR=$(pwd)

    cd $HOME_DIR/data/input/ .
    ln -s <input_path> .

    cd $HOME_DIR/data/output/
    ln -s <output_path> .
    ```
 The README.md files inside the /data contain path documentation for NSAPH internal purposes.

## Data 

1. Bitcoin Miners Data
    * File Name: crypto_loc_summary_fulldates_calvertcity.xlsx
    * Description: Contains information about Bitcoin miners, including their locations and operational data. 
2. WattTime Balancing Authorities Files
    * Files Name: {area}_plant_mix.csv
    * Description: Includes marginal power contribution coefficients for 19 power plants within different balancing authorities. These file allows you to evaluate the impact of specific power plants on energy consumption and emissions. 
3. Power Plants Specs (Condensed Unit Rates)
    * File Name: condensed_unit_rates.csv
    * Description: Provides specifications and unit rates for power plants. 
4. Demographic Data
    * File Name: Tract acs
    * Description: Contains demographic information at the tract level, sourced from the American Community Survey (ACS). This data can be used to analyze the demographic characteristics of areas affected by Bitcoin mining and power plants.
5. NYC Shape File
    * File Name: tl_2019_34017_faces
    * Description: A shapefile used to plot geographic data in New York City at a higher resolution. This file is useful for visualizing data hotspots and geographic distributions in NYC.
6. Satellite PM2.5 at Tract Level
    * File Name: tl_2019_34017_faces
    * Description: Provides satellite-derived PM2.5 concentration levels at the tract level. This data can be used to analyze air quality and its relation to energy consumption and emissions from power plants and Bitcoin mining.





