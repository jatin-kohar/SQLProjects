/* 

Cleaning Data in SQL Queries

*/

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing


-- Standardising date format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

/*
Alternate method of standardising date
*/
ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD SaleDate_1 Date;

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET SaleDate_1 = CONVERT(Date, SaleDate)



------------------------------------------------------------------------------------------------------------------

-- Populating Property Address Data

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null



------------------------------------------------------------------------------------------------------------------

-- Converting Address into Individual Columns

SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(225);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(225);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing


SELECT OwnerAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD Owner_Address nvarchar(225);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET Owner_Address =PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD OwnerCity nvarchar(225);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD OwnerState nvarchar(225);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM DataCleaningProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------

-- Removing Duplicates from our database

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num
FROM DataCleaningProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT * 
FROM RowNumCTE
ORDER BY PropertyAddress



-----------------------------------------------------------------------------------------------------------

-- Deleting unused columns

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate