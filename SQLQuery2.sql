/*
Data cleaning in SQL using Nashville's housing data

Data source: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data
*/

-- Standarize date format
-- Converting data from DateTime format to Date
-- Altering table to add a new column without removing original data

select *
from dbo.HousingData

Alter table HousingData
ADD SaleDateConverted Date

update HousingData 
Set SaleDateConverted= Convert(date,SaleDate)


-- Populate proerty address data
-- Some address were missing in the Property address column, I was able to populate that using ParcelID column

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.propertyAddress,b.PropertyAddress)
from dbo.HousingData a
inner join dbo.HousingData b
on a.ParcelID =b.ParcelID
and a.UniqueID <> b.UniqueID
where 
a.PropertyAddress is null
order by a.ParcelID

update a
SET PropertyAddress = isnull(a.propertyAddress,b.PropertyAddress)
from dbo.HousingData a
join dbo.HousingData b
on a.ParcelID =b.ParcelID
and a.UniqueID <> b.UniqueID
where 
a.PropertyAddress is null

-- Breaking out address into Individual Column (Address, City, State)
select PropertyAddress
from dbo.HousingData

select substring(propertyaddress,1,charindex(',',propertyaddress)-1) as StreetAddress
,substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as City 
from dbo.HousingData

Alter table dbo.HousingData
Add PropertySplitAddress Nvarchar(255)

update dbo.HousingData 
set PropertySplitAddress= substring(propertyaddress,1,charindex(',',propertyaddress)-1)

Alter table dbo.HousingData
Add PropertySplitCity Nvarchar(255)

update dbo.HousingData 
set PropertySplitCity= substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select *
from dbo.HousingData -- New columns were added to the table


select parsename(replace(OwnerAddress,',','.'),1) as State,
parsename(replace(OwnerAddress,',','.'),2) as City,
parsename(replace(OwnerAddress,',','.'),3) as Street
from dbo.HousingData

Alter table dbo.HousingData
Add OwnerSplitStreet Nvarchar(255)

update dbo.HousingData 
set OwnerSplitStreet= parsename(replace(OwnerAddress,',','.'),3) 

Alter table dbo.HousingData
Add OwnerSplitCity Nvarchar(255)

update dbo.HousingData 
set OwnerSplitCity= parsename(replace(OwnerAddress,',','.'),2) 

Alter table dbo.HousingData
Add OwnerSplitTx Nvarchar(255)

update dbo.HousingData 
set OwnerSplitTx= parsename(replace(OwnerAddress,',','.'),1) 

-- Change Y and N to Yes and No in the column SoldAsVacant

Alter table dbo.HousingData
Add SoldVacant varchar(255)

update dbo.HousingData
set SoldVacant = CAST(soldAsVacant as Varchar)

update dbo.HousingData
set   SoldVacant = 
case when SoldVacant= '1' then 'Yes' 
     when SoldVacant = '0' then 'No' 
     else SoldVacant end
from dbo.HousingData


-- Remove Duplicates
with Duplicate as(
select *,
row_number() over (partition by ParcelID, propertyAddress,
                                SalePrice, SaleDate,
								LegalReference 
								order by uniqueID
								) Row_num 
                                    
from dbo.HousingData)

delete
from duplicate
where 
ROW_NUM >1



-- Delete Unused columns
-- Usually this is done mostly on views, it is not standard practice to remove columns from original data

select *
from dbo.HousingData


Alter Table dbo.HousingData
Drop column OwnerAddress, TaxDistrict, PropertyAddress  -- List the columns you want to remove