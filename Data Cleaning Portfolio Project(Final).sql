/* Cleaning Data in SQL Queries*/
select * from DataCleaning.dbo.NashvilleHousing$

/* Standardize Date Format*/
select saledate,convert(date,saledate)
from DataCleaning.dbo.NashvilleHousing$

update DataCleaning.dbo.NashvilleHousing$
set saledate = CONVERT(DATE,SALEDATE)

Alter table DataCleaning.dbo.NashvilleHousing$ add saledateconverted date

update DataCleaning.dbo.NashvilleHousing$
set saledateconverted = convert(date,saledate)

select saledateconverted from DataCleaning.dbo.NashvilleHousing$

-------------------------------------------------------------

--Populate Property Address data----

select * from DataCleaning.dbo.NashvilleHousing$
where PropertyAddress is null
order by ParcelID


select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(A.PropertyAddress,b.PropertyAddress)
from DataCleaning.dbo.NashvilleHousing$ a
join DataCleaning.dbo.NashvilleHousing$ b on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(A.PropertyAddress,b.PropertyAddress)
from DataCleaning.dbo.NashvilleHousing$ a
join DataCleaning.dbo.NashvilleHousing$ b on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null

select * from DataCleaning.dbo.NashvilleHousing$ 
where PropertyAddress is null
order by ParcelID

------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address, City, State)

select SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from DataCleaning.dbo.NashvilleHousing$ 

Alter table DataCleaning.dbo.NashvilleHousing$ 
add PropertyCity nvarchar(255)

Alter table DataCleaning.dbo.NashvilleHousing$ 
add PropertySplitAddress nvarchar(255)

update DataCleaning.dbo.NashvilleHousing$ 
set PropertyCity = SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

update DataCleaning.dbo.NashvilleHousing$ 
set PropertySplitAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

----Table Schema------
SELECT Column_Name, Data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing$';

select * from NashvilleHousing$

---------------------------------------------------------
select OwnerAddress from NashvilleHousing$

select PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from NashvilleHousing$

Alter table DataCleaning.dbo.NashvilleHousing$ 
add OwnerCity Nvarchar(255)

Alter table DataCleaning.dbo.NashvilleHousing$ 
add OwnerState Nvarchar(255)

Alter table DataCleaning.dbo.NashvilleHousing$ 
add OwnerSplitAddress Nvarchar(255)

SELECT Column_Name, Data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing$';

update DataCleaning.dbo.NashvilleHousing$ 
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

update DataCleaning.dbo.NashvilleHousing$ 
set OwnerCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

update DataCleaning.dbo.NashvilleHousing$ 
set OwnerState = PARSENAME(REPLACE(owneraddress,',','.'),1)

select * from DataCleaning.dbo.NashvilleHousing$

----Change Yes and No---------

select distinct(Soldasvacant), count(soldasvacant) 
from DataCleaning.dbo.NashvilleHousing$
group by Soldasvacant
order by 2

select soldasvacant,
	case when soldasvacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else soldasvacant
    end 
from DataCleaning.dbo.NashvilleHousing$ 

update DataCleaning.dbo.NashvilleHousing$ 
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else soldasvacant
end 

select * from DataCleaning.dbo.NashvilleHousing$ 
where soldasvacant = 'N'

---------------Remove Duplicates----------------
----Windows Functions-----

WITH ROWNUMECTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueid) as Row_Num
from DataCleaning.dbo.NashvilleHousing$
--order by ParcelID
)
SELECT * FROM ROWNUMECTE WHERE ROW_NUM > 1
--DELETE FROM ROWNUMECTE WHERE ROW_NUM > 1

select * FROM DataCleaning.dbo.NashvilleHousing$

----Delete unused columns------
ALTER TABLE DataCleaning.dbo.NashvilleHousing$
DROP COLUMN PropertyAddress,OwnerAddress

ALTER TABLE DataCleaning.dbo.NashvilleHousing$
DROP COLUMN SaleDate
