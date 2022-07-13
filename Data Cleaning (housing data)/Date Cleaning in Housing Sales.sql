Use
Portfolioproject
Go

Select TOP 100 * from Portfolioproject.[dbo].[HousingData]

-- Converting datetime to date for Sales Date

ALTER Table Portfolioproject.[dbo].[HousingData]
ALTER COLUMN SaleDate Date

Select SaleDate from Portfolioproject.[dbo].[HousingData]

-- Removing nulls in the address by putting address corresponding to parcelID
Select * from Portfolioproject.[dbo].[HousingData]
Where PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
from Portfolioproject.[dbo].[HousingData] a
JOIN Portfolioproject.[dbo].[HousingData] b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

--Dividing address into (Address, City, State)
-- Property address split
Select PropertyAddress from Portfolioproject.[dbo].[HousingData]

Select PropertyAddress,
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,Len(PropertyAddress)-CHARINDEX(',',PropertyAddress)) as City
from Portfolioproject.[dbo].[HousingData]

ALTER TABLE Portfolioproject.[dbo].[HousingData]
ADD Property_address nvarchar(25), Property_city nvarchar(15)

UPDATE Portfolioproject.[dbo].[HousingData]
SET Property_address= SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
	Property_city= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,Len(PropertyAddress)-CHARINDEX(',',PropertyAddress))

--Owner address split
Select
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) as [Address],
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) as [City],
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) as [State]
from Portfolioproject.[dbo].[HousingData]

ALTER TABLE Portfolioproject..HousingData
ADD Owner_address NVARCHAR(35),
	Owner_city NVARCHAR(15),
	Owner_state NVARCHAR(10)
GO

ALTER TABLE Portfolioproject..HousingData ALTER COLUMN Owner_address NVARCHAR(40)


UPDATE Portfolioproject..HousingData
SET 
Owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
Owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
Owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
GO

Select Owner_address,Owner_city, Owner_state 
from Portfolioproject..HousingData

-- Change Y to YES and N to No
UPDATE Portfolioproject..HousingData
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
	END

Select DISTINCT SoldAsVacant
from Portfolioproject..HousingData

--Deleting duplicates
With RowNumCTE AS (
Select *, ROW_NUMBER() OVER
		(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) rwn
From Portfolioproject..HousingData )
DELETE
From RowNumCTE 
Where rwn > 1

--Dumping Unused Columns
ALTER TABLE Portfolioproject..HousingData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

		