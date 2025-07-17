# 🧹 World Layoffs Data Cleaning with SQL

This project focuses on cleaning a dataset of global layoffs using SQL. The original dataset contained inconsistencies and missing values across fields, such as company names, industries, dates, and employee counts. The purpose of this project was to transform the raw data into a clean, analysis-ready format.

## 📊 About the Dataset

This dataset was provided as part of a data cleaning project in [Alex The Analyst’s Data Analyst Bootcamp](https://www.youtube.com/@AlexTheAnalyst). It includes information on tech layoffs from companies around the world. The raw data had several quality issues, such as missing values, inconsistent formatting, and duplicate entries.


## 📄 File Included
- `World_Layoffs_Data_Cleaning.sql`: SQL script with step-by-step cleaning queries

## 🧰 Tools Used
- SQL (please note the exact dialect: MySQL)
- GitHub for version control

## 🧼 Key Data Cleaning Tasks
- Removed duplicate entries
- Standardized text fields (e.g. casing, whitespace)
- Handled NULL values appropriately
- Converted dates to a consistent format
- Removed irrelevant columns

## 💡 What I Learned
- Best practices for SQL data cleaning
- Common data quality issues in real-world datasets
- How to make data suitable for analysis

## 🔍 Sample Query
```sql
-- Standardize company names by trimming whitespace
UPDATE layoffs
SET company = TRIM(company);

## 🚀 Next Steps
Perform trend analysis (layoffs by industry, region, etc.)

Connect cleaned data to Tableau or Power BI for visualization
