SELECT * 
FROM [Nashville RealEstate]..NashvilleHousing

--Reformatting the Date column (SaleDate)

ALTER TABLE nashvillehousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM [Nashville RealEstate]..NashvilleHousing

---------------------------------------------------------
-- populate PropertyAddress null values

SELECT PropertyAddress
FROM [Nashville RealEstate]..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville RealEstate]..NashvilleHousing a
JOIN [Nashville RealEstate]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville RealEstate]..NashvilleHousing a
JOIN [Nashville RealEstate]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


------------------------------------------------------------------------
--split the PropertyAddress string into 2 substrings (Address and City)
--e.g split "1808  FOX CHASE DR, GOODLETTSVILLE" into	"1808  FOX CHASE DR"	and  "GOODLETTSVILLE"

SELECT	PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1),
		SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) -1, LEN(PropertyAddress))
FROM [Nashville RealEstate]..NashvilleHousing


ALTER TABLE [Nashville RealEstate]..NashvilleHousing
ADD PropertyAddressSplit NVARCHAR(255),
	PropertyCitySplit NVARCHAR(255);

UPDATE [Nashville RealEstate]..NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

UPDATE [Nashville RealEstate]..NashvilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertyAddress, PropertyAddressSplit, PropertyCitySplit
FROM [Nashville RealEstate]..NashvilleHousing

----------------------------------------------------------------------------------
--split the OwnerAddress into three sections the address itself, city and state
--e.g. split "1808  FOX CHASE DR, GOODLETTSVILLE, TN" into	"1808  FOX CHASE DR", "GOODLETTSVILLE"	and  "TN"

SELECT	OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM [Nashville RealEstate]..NashvilleHousing


ALTER TABLE [Nashville RealEstate]..NashvilleHousing
ADD OwnerAddressSplit NVARCHAR(255),
	OwnerCitySplit NVARCHAR(255),
	OwnerStateSplit NVARCHAR(255);

UPDATE [Nashville RealEstate]..NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

UPDATE [Nashville RealEstate]..NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

UPDATE [Nashville RealEstate]..NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT OwnerAddress, OwnerAddressSplit, OwnerCitySplit, OwnerStateSplit
FROM [Nashville RealEstate]..NashvilleHousing

------------------------------------------------------------------------------
-- generalize the column "SoldAsVacanT"values into "Yes" and "No"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville RealEstate]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT	SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END
FROM [Nashville RealEstate]..NashvilleHousing

UPDATE  [Nashville RealEstate]..NashvilleHousing
SET SoldAsVacant =	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END

---------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT	*,
		ROW_NUMBER() OVER( PARTITION BY ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference ORDER BY UniqueID ) row_num
FROM [Nashville RealEstate]..NashvilleHousing
)
--SELECT *
--FROM RowNumCTE
DELETE
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------
-- Delete unused columns

ALTER TABLE [Nashville RealEstate]..NashvilleHousing
DROP COLUMN PropertyAddress,
			OwnerAddress,
			TaxDistrict

SELECT *
FROM  [Nashville RealEstate]..NashvilleHousing