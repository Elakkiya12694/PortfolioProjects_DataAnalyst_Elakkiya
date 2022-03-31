/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject].[dbo].[DataCleaning]

 ---Standardize Date format
 Select SaleDateConverted 
 from PortfolioProject..DataCleaning

 Alter table DataCleaning
 Add SaleDateConverted Date;


 Update DataCleaning
 Set SaleDateConverted=CONVERT(date,SaleDate)

 ----Populate Property address data
 select *
 from PortfolioProject..DataCleaning
 order by ParcelID


 Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 from PortfolioProject..DataCleaning a
 Join PortfolioProject..DataCleaning b
   on a.ParcelID =b.ParcelID
   and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

---Updating the null values of PropertyAddress having the same ParcelID to its appropriate PropertyAddress
Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..DataCleaning a
Join PortfolioProject..DataCleaning b
   on a.ParcelID =b.ParcelID
   and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

 select *
 from PortfolioProject..DataCleaning
 where PropertyAddress is null
 order by ParcelID


 ---Breaking out Address into individual columns (Address, City, State) using SUBSTRING
 select PropertyAddress
 from PortfolioProject..DataCleaning

 select 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..DataCleaning

---Updating address and city in new separate columns
Alter table DataCleaning
Add PropertySplitAddress NVARCHAR(255);

Update DataCleaning
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table DataCleaning
Add PropertySplitCity NVARCHAR(255);

Update DataCleaning
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

 select PropertySplitAddress, PropertySplitCity
 from PortfolioProject..DataCleaning


 ----Breaking out OwnerAddress into separate individual columns (Address, City, State) using PARSENAME
 select OwnerAddress
 from DataCleaning

 select 
 PARSENAME(Replace(OwnerAddress,',','.'),3),
 PARSENAME(Replace(OwnerAddress,',','.'),2),
 PARSENAME(Replace(OwnerAddress,',','.'),1)
 from DataCleaning







 