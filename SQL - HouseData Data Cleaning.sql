-- Using SQL Queries for Data Cleansing/Scrubbing
Select *
From PortfolioProject.dbo.[Housing Data]

-------------------------------------------------------------------

-- Changing Date Format
Select SaleDate
From PortfolioProject.dbo.[Housing Data]

-- Creating new Date column
ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add SaleDateConverted Date;

-- Duplicating data but casting it to Date from DateTime format
Update PortfolioProject.dbo.[Housing Data]
SET SaleDateConverted = CONVERT(Date, saleDate)

-- Checking New Column for approp Date format
Select SaleDateConverted
From PortfolioProject.dbo.[Housing Data]

-------------------------------------------------------------------

-- Cleaning null Property Address rows
Select *
From PortfolioProject.dbo.[Housing Data]
Where PropertyAddress is null

-- Start by assessing what could be linked with Property Address
Select *
From PortfolioProject.dbo.[Housing Data]
--Where PropertyAddress is null
Order by ParcelID

-- Upon Understanding that 'PercelID's have same Property Addresses, I will populate the
-- nulls w/ the same 'ParcelID' using 'UniqueID' to differentiate b/w them
Select alpha.ParcelID, alpha.PropertyAddress, beta.ParcelID, beta.PropertyAddress, ISNULL(alpha.PropertyAddress, beta.PropertyAddress)
From PortfolioProject.dbo.[Housing Data] alpha
JOIN PortfolioProject.dbo.[Housing Data] beta
	on alpha.ParcelID = beta.ParcelID
	AND alpha.[UniqueID ] <> beta.[UniqueID ]
Where alpha.PropertyAddress is null

-- Updating PropertyAdress
Update alpha
SET PropertyAddress = ISNULL(alpha.PropertyAddress, beta.PropertyAddress)
From PortfolioProject.dbo.[Housing Data] alpha
JOIN PortfolioProject.dbo.[Housing Data] beta
	on alpha.ParcelID = beta.ParcelID
	AND alpha.[UniqueID ] <> beta.[UniqueID ]
Where alpha.PropertyAddress is null

-------------------------------------------------------------------

-- Cleaning 'PropertyAddress' into Address, City, State using Substring
Select *
From PortfolioProject.dbo.[Housing Data]

-- Using a common delimiter in Substring to separate data, in this case it's a comma
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.[Housing Data]

-- Adding new columns for Address & City
ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.[Housing Data]

-------------------------------------------------------------------

-- Cleaning 'OwnerAddress' into Address, City, State using Parsename
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.[Housing Data]

-- Adding new columns for Address, City, State
ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE PortfolioProject.dbo.[Housing Data]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.[Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update PortfolioProject.dbo.[Housing Data]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update PortfolioProject.dbo.[Housing Data]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------

-- Checking Data in 'SoldAsVacant'
Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.[Housing Data]

-- Counting Unique Fields
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.[Housing Data]
Group by SoldAsVacant
Order by 2

-- Changing Y & N to Yes & No for consistency
Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject.dbo.[Housing Data]

-- Update Statement
Update PortfolioProject.dbo.[Housing Data]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

-------------------------------------------------------------------

-- Finding out duplicates using CTE
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) row_num
From PortfolioProject.dbo.[Housing Data]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Deleting Duplicated
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) row_num
From PortfolioProject.dbo.[Housing Data]
)
DELETE
From RowNumCTE
Where row_num > 1

-------------------------------------------------------------------

-- Deleting Unused Columns
Select *
From PortfolioProject.dbo.[Housing Data]


ALTER TABLE PortfolioProject.dbo.[Housing Data]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.[Housing Data]
DROP COLUMN SaleDate

-------------------------------------------------------------------
