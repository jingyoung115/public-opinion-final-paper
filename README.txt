README

Project title: Who Says Matters: The Impact of Inclination-Oriented Media Consumption on Political Trust in China

Last updated: November 19, 2024

Overview
This repository contains replication materials for the study examining the relationship between international media consumption and trust in central government, including Monte Carlo simulations for measurement error analysis.

Repository Structure
yang-replication materials/
├── 2017_data_SSCN.dta
├── 2018_data_SSCN.dta
├── 2019+2020-1_data_SSCN.dta
├── 2020-2_data_SSCN.dta
├── 2021_data_SSCN.dta
├──yang-data_cleaning.do
├── graph
│   ├── wave1-4/
│   └── wave5-8/
├── table
│   ├── wave1-4/
│   └── wave5-8/
├── wave
├── processed_data
├── Lab Book.txt
├── yang-public opinion final paper.pdf
└── README.txt

List of files in the zipped file:
	README file:
		README.txt
	Lab book file:
		Lab Book.txt
	Paper Manuscript:
		yang-public opinion final paper.pdf
	Raw data:
		"yang-replication materials\2014-2015-2017_data_SSCN.dta"
		"yang-replication materials\2018_data_SSCN.dta"
		"yang-replication materials\2019+2020-1_data_SSCN.dta"
		"yang-replication materials\2020-2_data_SSCN.dta"
		"yang-replication materials\2021_data_SSCN.dta"
		"yang-replication materials\renamed_1920-1.dta"
	Do files:
		"yang-replication materials\yang-data_analysis.do"
		"yang-replication materials\yang-data_cleaning.do"
	Folders:
		graph
		processed_data
		table
		wave

Requirements
	Stata 

Instructions for data creation:
	1. Open Stata
	2. Run yang-data_cleaning.do
	3. This script processes raw data and saves cleaned datasets in the wave folder

instructions for analysis runs:
	1. Run yang-data_analysis.do
	This script performs all analyses and generates:
		Graphs (saved in graph folder)
		Tables (saved in table folder)

Output Files
	wave/: Contains processed datasets
	graph/: Contains all visualization outputs
	table/: Contains statistical tables

Contact
	Author: Jing Yang
	Email: jing-yang-1@uiowa.edu
	Institution: Department of Political Science, University of Iowa
