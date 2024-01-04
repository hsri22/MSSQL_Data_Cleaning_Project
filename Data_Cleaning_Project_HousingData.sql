/*

DATA CLEANING PROJECT ON NASHVILLE HOUSING DATA

*/

SELECT * 
FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--Above script says rows have been updated but result does not change when viewing
--Script below makes a new column with fixed format (we can remove SaleDate column later)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--SELECT *
--FROM NashvilleHousing
--WHERE PropertyAddress is NULL

-- We can assume that the NULL addresses can be filled 
-- if we have a reference point. Since it is unlikely that
-- the address of a property changes



--SELECT *
--FROM NashvilleHousing
--ORDER BY ParcelID

-- Looking at ParcelID, we see that ParcelID is distinct to a specific Property Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Above we can look at the ParcelIDs and the Property is is linked to

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- all isnull in 'a' will be values from 'b'
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

-- In this dataset the ',' seperates the address and city

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, -- CHARINDEX finds where the ',' is and only returns the address until that point
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City -- start after ',' and go to end 
FROM NashvilleHousing

-- Udpate Table Adress
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- Udpate Table City
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Looking at OwnerAddress Data & spliting it

SELECT OwnerAddress 
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3), -- PARSNAME seperates if there is a '.' so we first replace the ',' to a '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2), --'2' is 2nd '.' from right
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) -- '1' is 1st '.' from right
FROM NashvilleHousing


-- Update Table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress =	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity =	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

--Update Table

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS Row_Num
FROM NashvilleHousing
ORDER BY ParcelID

-- looking at the we see two rows in the data that are identical 
-- in terms of ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
-- even though the unique ID is different. This is assumed to be a dublicate


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS Row_Num
FROM NashvilleHousing
)

--SELECT *
--FROM RowNumCTE
--WHERE Row_Num > 1
--ORDER BY PropertyAddress

-- The script above shows all the duplicate values

DELETE
FROM RowNumCTE
WHERE Row_Num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




