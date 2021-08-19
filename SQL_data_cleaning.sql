--DATA CLEANING WITH SQL 
---------------------------------------
--TASKS
---------------------------------------
SELECT * FROM  PortfolioProject..NashVille

--STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashVille

ALTER TABLE NashVille ADD SaleDateConverted DATE;

UPDATE NashVille SET SaleDateConverted = CONVERT(date, SaleDate);

--POPULATE THE PROPERTY ADDRESS DATA

 SELECT * FROM  PortfolioProject..NashVille
 WHERE PropertyAddress IS NULL;
--THERE ARE 29 NULL VALUES IN TERMS OF P.A 

 SELECT * FROM  PortfolioProject..NashVille
 --WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;
-- WHEN WE LOOK AT THE PARCEL ID, WE SEE THAT THE SAME PARCEL ID HAS THE SAME PROPERTY A.
-- SO LET'S POPULATE THEM INTO ONE PIECE

----------------
SELECT A.ParcelID,A.PropertyAddress, B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashVille AS A
JOIN NashVille AS B ON A.ParcelID = B.ParcelID
WHERE A.PropertyAddress IS NULL
AND A.UniqueID <> B.UniqueID;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashVille AS A
JOIN NashVille AS B ON A.ParcelID = B.ParcelID
WHERE A.PropertyAddress IS NULL
AND A.UniqueID <> B.UniqueID

-- WHAT WE DID ? 
-- CLEARLY, WE RECOGNIZED THAT WEN THE SAME PARCEL ID IS SHARED, IN THE SAME WAY PROPERTY A. DONE. 
-- WE DECIDED TO NOT LEAVE THIS PROPERTY A. NULL AS WE HAVE A LINKED COLUMN WHICH IS PARCEL ID.

-------------------------
-- BREAKING OUT ADDRESS INTO INDIVUDUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Splitted_Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))
FROM 
NashVille

ALTER TABLE NashVille
ADD SplittedAddress NVARCHAR(50);

UPDATE NashVille 
SET SplittedAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashVille
ADD SplittedCity NVARCHAR(50);

UPDATE NashVille 
SET SplittedCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT * FROM
NashVille;

--DO THE SAME THING FOR OwnerAddress

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM 
NashVille;

ALTER TABLE Nashville
ADD OwnerSplittedAddress NVARCHAR(255);

UPDATE NashVille
SET OwnerSplittedAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville
ADD OwnerSplittedCity NVARCHAR(255);

UPDATE NashVille
SET OwnerSplittedCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Nashville
ADD OwnerSplittedState NVARCHAR(255);

UPDATE NashVille
SET OwnerSplittedState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT * FROM  PortfolioProject..NashVille


-------------------------
--CHANGE Y AND N TO "YES" AND "NO" IN SOLD AS VACANT FIELD

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM 
NashVille
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashVille

UPDATE NashVille
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
------------------
--REMOVE DUPLICATES
WITH CT AS
(
SELECT *,
ROW_NUMBER() 
OVER(
PARTITION BY ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference 
ORDER BY UniqueID
) AS row_num
FROM 
NashVille	
)
SELECT *
FROM 
CT
WHERE row_num <> 1 
-- NOW THERE IS NO ANY DUPLICATE ATTRIBUTE.

---DROP UNUSED COLUMNS

SELECT * FROM PortfolioProject..NashVille

ALTER TABLE PortfolioProject..NashVille
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject..NashVille
DROP COLUMN SaleDate








