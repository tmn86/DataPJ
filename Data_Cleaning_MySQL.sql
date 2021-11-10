/*Cleaning Data using MySQL*/


Use DataPJ;


#---------------**** Populate Property Address Data *****---------------#

Select * from NashvilleHousing
order by Parcelid;



#----Check if IFNULL works using self join------


Select a1.ParcelID, a1.PropertyAddress, a2.ParcelID, a2.PropertyAddress,
ifnull(a1.PropertyAddress, a2.PropertyAddress) from 
NashvilleHousing a1 join NashvilleHousing a2 
on a1.ParcelID = a2.ParcelID and a1.UniqueID <> a2.UniqueID
where a1.PropertyAddress is null;


#-----------------Update table using self join---------------

Update
NashvilleHousing a1 join NashvilleHousing a2 
on a1.ParcelID = a2.ParcelID and a1.UniqueID <> a2.UniqueID
Set a1.PropertyAddress = ifnull(a1.PropertyAddress, a2.PropertyAddress)
where a1.PropertyAddress is null;

#-------Double check

Select a1.ParcelID, a1.PropertyAddress, a2.ParcelID, a2.PropertyAddress from 
NashvilleHousing a1 join NashvilleHousing a2 
on a1.ParcelID = a2.ParcelID and a1.UniqueID <> a2.UniqueID;





#--------------*** Breaking down Address into individual col (Address, City, State) ***----------#


Select PropertyAddress
From NashvilleHousing;


#-----Split PropertyAddress into Address line and City


Select 
substring(PropertyAddress, 1, locate(',',PropertyAddress) -1) as Address,
substring(PropertyAddress, locate(',',PropertyAddress) + 1, length(PropertyAddress)) as City
from NashvilleHousing;

#-----Add more columns for splitted address---


Alter Table NashvilleHousing
Add column PropertyAddressLine varchar(255),
add column PropertyAddressCity varchar(255);


Alter Table NashvilleHousing
Add column PropertyAddressLine varchar(255),
add column PropertyAddressCity varchar(255);



#--------Update splitted address---


Update NashvilleHousing
Set PropertyAddressLine = substring(PropertyAddress, 1, locate(',',PropertyAddress) -1);

Update NashvilleHousing
Set PropertyAddressCity = substring(PropertyAddress, locate(',',PropertyAddress) + 1, length(PropertyAddress));




#---------------------------***** Split Owner Address ***------------------------#

Select OwnerAddress from NashvilleHousing;



#-----Split OwnerAddress into Address line, City and State--------


Select
Substring_index(OwnerAddress,',',1) as Address,
substring(Substring_index(OwnerAddress,',',2), locate(',', Substring_index(OwnerAddress,',',2)) +1,
length(Substring_index(OwnerAddress,',',2))) as City,
Substring_index(OwnerAddress,',',-1) as State
from NashvilleHousing;


#----------Add new columns for split address-------------


Alter Table NashvilleHousing
Add column OwnerAddressLine varchar(255),
add column OwnerAddressCity varchar(255),
add column OwnerAddressState varchar(255);


#----------Update splitted address into new columns---------


Update NashvilleHousing
Set OwnerAddressLine = Substring_index(OwnerAddress,',',1);

Update NashvilleHousing
Set OwnerAddressCity = substring(Substring_index(OwnerAddress,',',2), locate(',', Substring_index(OwnerAddress,',',2)) +1,
length(Substring_index(OwnerAddress,',',2)));

Update NashvilleHousing
Set OwnerAddressState = Substring_index(OwnerAddress,',',-1);






#-------**** Change Y and N into Yes and No in "Sold as Vacant" field ****-------------------#



Select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing 
group by SoldAsVacant;

Select
SoldAsVacant,
Case 
when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end
from NashvilleHousing;


#-------Update---

Update NashvilleHousing
set SoldAsVacant = Case 
when SoldAsVacant = 'N' then 'No'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end;


#--------------------------- ******** Remove duplicates ***** ----------------------------#


#-----Check for duplicates using row_num() to mark number of row that appear more than 1 time-----


Select *, 
row_number() over(
Partition by ParcelId, PropertyAddress, SalePrice,SaleDate, LegalReference
order by UniqueId)
From NashvilleHousing;

#-------------Using CTE to filter out duplicated rows------------


With RowNumCTE as (
select *,
row_number() over(
Partition by ParcelId, PropertyAddress, SalePrice,SaleDate, LegalReference
order by UniqueId) row_num
From NashvilleHousing
)
Select * from RowNumCTE where row_num > 1
Order by SaleDate;


#------------Using CTE with SELF JOIN to filter out duplicated rows-------------


With RowNumCTE as (
select *,
row_number() over(
Partition by ParcelId, PropertyAddress, SalePrice,SaleDate, LegalReference
order by UniqueId) row_num
From NashvilleHousing
)
Select *, row_num from RowNumCTE rn join NashvilleHousing nh 
on rn.ParcelId = nh.ParcelId and 
rn.PropertyAddress = nh.PropertyAddress and 
rn.SalePrice = nh.SalePrice and
rn.SaleDate = nh.SaleDate and 
rn.LegalReference = nh.LegalReference
where row_num > 1 and rn.UniqueId <> nh.UniqueId;


#-----------Using CTE with SELF JOIN to filter out duplicated rows (join on UniqueID)-------------


With RowNumCTE as (
select *,
row_number() over(
Partition by ParcelId, PropertyAddress, SalePrice,SaleDate, LegalReference
order by UniqueId) row_num
From NashvilleHousing
)
Select *, row_num from RowNumCTE rn join NashvilleHousing nh 
on rn.UniqueId = nh.UniqueId
where row_num > 1;
 
#-------Make a check point before modifying the table dataset------

Commit;



#--------------------Drop duplicated rows--------------------



With RowNumCTE as (
select *,
row_number() over(
Partition by ParcelId, PropertyAddress, SalePrice,SaleDate, LegalReference
order by UniqueId) row_num
From NashvilleHousing
)
Delete from nh using RowNumCTE rn join NashvilleHousing nh 
on rn.UniqueId = nh.UniqueId
where row_num > 1;





#------------------ ***** Delete Unuded Columns ******--------------------------------#

/* Alter table NashvilleHousing
Drop column OwnerAddress, 
drop column PropertyAddress; */

