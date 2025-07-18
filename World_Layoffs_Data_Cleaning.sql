-- Data Cleaning Overview:
-- Steps:
-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Handle NULL or blank values
-- 4. Remove unnecessary columns or rows


-- Create a staging table with the same structure as the original 'layoffs' table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Verify the structure of the new table (empty at this point)
SELECT * FROM layoffs_staging;

-- Copy all data from the original table into the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Check data with a row number assigned per group of key columns to help identify duplicates
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
    ) AS row_num
FROM layoffs_staging;


-- Use a Common Table Expression (CTE) to find duplicate rows
WITH duplicate_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
-- Select all rows where row_num > 1, i.e. duplicates beyond the first occurrence
SELECT *
FROM duplicate_CTE
WHERE row_num > 1;


-- Example filter: View all records for the company 'Casper'
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


-- Attempt to delete duplicates using a CTE with ROW_NUMBER (Note: MySQL does not support DELETE directly from CTEs)
WITH duplicate_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
DELETE
FROM duplicate_CTE
WHERE row_num > 1;

-- Since MySQL doesn't allow DELETE directly on CTEs, the above will cause an error.
-- Instead, the script proceeds to create a new staging table 'layoffs_staging2' with the same structure plus 'row_num' column.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Preview rows where duplicates (row_num > 1) might exist in the new table
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Insert all rows from layoffs_staging into layoffs_staging2,
-- assigning row numbers partitioned by key columns to identify duplicates
INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Disable safe update mode to allow DELETE statements without WHERE on keys
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate rows where row_num is greater than 1 (keep the first occurrence)
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Check final cleaned data in layoffs_staging2
SELECT *
FROM layoffs_staging2;



-- Standardizing Data: Clean and format key columns for consistency


-- Preview company names alongside their trimmed versions (remove leading/trailing spaces)
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Update company column by trimming whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company);


-- Check distinct industry values to identify inconsistencies or typos
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Standardize industry names starting with 'Crypto' to exactly 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Preview distinct country values, trimming trailing periods (e.g. 'United States.')
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Update country column to remove trailing '.' from countries like 'United States.'
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Preview date values (likely in string format)
SELECT `date`
FROM layoffs_staging2;

-- Convert date strings to MySQL DATE type (format: MM/DD/YYYY)
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the data type of 'date' column from text to DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Check rows where both total_laid_off and percentage_laid_off are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Replace empty strings in industry column with NULL values for consistency
UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';


-- Verify rows where industry is NULL or empty string
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


-- Preview all records for companies starting with 'Bally'
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Find records where one row for a company has missing industry but another has it filled
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
  AND t1.location = t2.location  -- corrected from t2.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Update missing industry fields by copying non-null industry from matching company/location rows
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
  AND t1.location = t2.location  -- corrected to join condition
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Preview the full table after updates
SELECT *
FROM layoffs_staging2;

-- Find rows where both total_laid_off and percentage_laid_off are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Delete rows with NULL in both total_laid_off and percentage_laid_off
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Preview table after deletions
SELECT *
FROM layoffs_staging2;

-- Drop the auxiliary 'row_num' column, no longer needed after deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;







