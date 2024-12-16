--Standardize Date Format
SELECT SaleDate,SalesDateConverted
FROM [PortfolioProject].[dbo].[NashvilleHousing]

update [PortfolioProject].[dbo].[NashvilleHousing]
set SaleDate = convert(date,SaleDate);

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add SalesDateConverted date;

update [PortfolioProject].[dbo].[NashvilleHousing]
set SalesDateConverted = convert(date,SaleDate);


--Populate Property address data
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
join [PortfolioProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] a
join [PortfolioProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns
SELECT PropertyAddress,OwnerAddress
FROM [PortfolioProject].[dbo].[NashvilleHousing];

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM [PortfolioProject].[dbo].[NashvilleHousing]

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add PropertySplitAddress nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add PropertySplitCity nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
FROM [PortfolioProject].[dbo].[NashvilleHousing];

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitAddress nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitCity nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

alter table [PortfolioProject].[dbo].[NashvilleHousing]
add OwnerSplitState nvarchar(255);

update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);


--Change Y and N to Yes and No in "Sold as vacant" field
SELECT distinct SoldAsVacant, count(SoldAsVacant)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2;

update [PortfolioProject].[dbo].[NashvilleHousing]
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						else SoldAsVacant
						end
FROM [PortfolioProject].[dbo].[NashvilleHousing];


--Remove Duplicates
SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

alter table [PortfolioProject].[dbo].[NashvilleHousing] add row_num int  identity(1,1);

delete from [PortfolioProject].[dbo].[NashvilleHousing]
where row_num in (
SELECT max(row_num)
FROM [PortfolioProject].[dbo].[NashvilleHousing]
group by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
having count(*)>1);

alter table [PortfolioProject].[dbo].[NashvilleHousing] drop column row_num;

WITH RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate, 
				 SalePrice,
				 LegalReference
				 order by UniqueID
	) row_num
FROM [PortfolioProject].[dbo].[NashvilleHousing]
--order by ParcelID
)

SELECT * FROM RowNumCTE
where row_num>1
order by PropertyAddress;

DELETE 
FROM RowNumCTE
where row_num>1;


--Delete unused column
SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousing];

alter table [PortfolioProject].[dbo].[NashvilleHousing]
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

