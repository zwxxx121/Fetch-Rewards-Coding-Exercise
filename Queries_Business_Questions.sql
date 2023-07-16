# First I import 3 json files into fetch database.
# Each table_json has a single column 'C1' and each row represents an object.
# Create 3 tables Receipts, Users, Brand based on the given data schemas.
drop table if exists Receipts;
create table Receipts(
    _id varchar(100) primary key ,
    bonusPointsEarned bigint,
    bonusPointsEarnedReason varchar(255),
    createDate bigint,
    dateScanned bigint,
    finishedDate bigint,
    modifyDate bigint,
    pointsAwardedDate bigint,
    pointsEarned decimal(10,2),
    purchaseDate bigint,
    purchasedItemCount int,
    rewardsReceiptItemList json,
    rewardsReceiptStatus varchar(50),
    totalSpent decimal(10,2),
    userId varchar(100)
);

drop table if exists Users;
create table Users_temp (
    _id varchar(100),
    state varchar(10),
    createdDate bigint,
    lastLogin bigint,
    role varchar(20),
    active varchar(10)
);

drop table if exists Brand;
create table Brand (
    _id varchar(100) primary key,
    barcode varchar(100),
    brandCode varchar(100),
    category varchar(100),
    categoryCode varchar(100),
    cpg json,
    topBrand varchar(10),
    name varchar(100)
);

# Insert values into created tables by flattening json files with json_unquote() and json_extract()
insert into Receipts (
    select json_unquote(json_extract(C1, '$._id.$oid')) as _id,
       json_unquote(json_extract(C1, '$.bonusPointsEarned')) as bonusPointsEarned,
       json_unquote(json_extract(C1, '$.bonusPointsEarnedReason')) as bonusPointsEarnedReason,
       json_unquote(json_extract(C1, '$.createDate.$date')) as createDate,
       json_unquote(json_extract(C1, '$.dateScanned.$date')) as dateScanned,
       json_unquote(json_extract(C1, '$.finishedDate.$date')) as finishedDate,
       json_unquote(json_extract(C1, '$.modifyDate.$date')) as modifyDate,
       json_unquote(json_extract(C1, '$.pointsAwardedDate.$date')) as pointsAwardedDate,
       json_unquote(json_extract(C1, '$.pointsEarned')) as pointsEarned,
       json_unquote(json_extract(C1, '$.purchaseDate.$date')) as purchaseDate,
       json_unquote(json_extract(C1, '$.purchasedItemCount')) as purchasedItemCount,
       json_extract(C1,'$.rewardsReceiptItemList') as rewardsReceiptItemList,
       json_unquote(json_extract(C1, '$.rewardsReceiptStatus')) as rewardsReceiptStatus,
       json_unquote(json_extract(C1, '$.totalSpent')) as totalSpent,
       json_unquote(json_extract(C1, '$.userId')) as userId
    from receipts_json
);

insert into Users_temp (
    select json_unquote(json_extract(C1, '$._id.$oid')) as _id,
       json_unquote(json_extract(C1, '$.state')) as state,
       json_unquote(json_extract(C1, '$.createdDate.$date')) as createdDate,
       json_unquote(json_extract(C1, '$.lastLogin.$date')) as lastLogin,
       json_unquote(json_extract(C1, '$.role')) as role,
       json_unquote(json_extract(C1, '$.active')) as active
    from users_json
);

# Drop duplicates in Users table
create table Users (
    select * from Users_temp
    group by _id, state, createdDate, lastLogin, role, active
);
# set primary key of Users table
describe Users;
alter table Users
add primary key (_id);
# There's a value in the child table that does not exist in the parent table.
# Some users who purchased are not recorded in the user table, so cannot add foreign key.
# alter table Receipts
# add constraint foreign key (userId)
# references Users (_id);

insert into Brand (
    select json_unquote(json_extract(C1, '$._id.$oid')) as _id,
       json_unquote(json_extract(C1, '$.barcode')) as barcode,
       json_unquote(json_extract(C1, '$.brandCode')) as brandCode,
       json_unquote(json_extract(C1, '$.category')) as category,
       json_unquote(json_extract(C1, '$.categoryCode')) as categoryCode,
       json_unquote(json_extract(C1, '$.cpg')) as cpg,
       json_unquote(json_extract(C1, '$.topBrand')) as topBrand,
       json_unquote(json_extract(C1, '$.name')) as name
    from brands_json
);

# two products with different brands have the same barcode
select  count(_id)
from Brand
group by barcode
order by count(_id) desc;

# flatten nested list in Receipts.rewardsReceiptItemList
select count(j.barcode)
from Receipts, json_table(rewardsReceiptItemList, '$[*]' columns (barcode varchar(100) path '$.barcode')) j;

# Answers of Question 2:
# What are the top 5 brands by receipts scanned for most recent month? dateScanned
# The data we have doesn’t include the most recent month, so I assume the max year month is the current year month.
with receipt_brand as (
    select Receipts._id as receipt_id, dateScanned,
       j.barcode, b._id as brand_id, b.name
    from Receipts, json_table(rewardsReceiptItemList, '$[*]' columns (barcode varchar(100) path '$.barcode')) j
    inner join Brand b
    on j.barcode=b.barcode
)
select brand_id, name, count(distinct receipt_id) as ScanFrequency
from receipt_brand
where FROM_UNIXTIME(dateScanned/1000)>=DATE_SUB((
    select max(FROM_UNIXTIME(dateScanned/1000))
    from receipt_brand),INTERVAL 1 MONTH)
group by brand_id, name
order by ScanFrequency Desc
limit 5;

# If the data is real-time, then we can use the following query:
with receipt_brand as (
    select Receipts._id as receipt_id, dateScanned,
       j.barcode, b._id as brand_id, b.name
    from Receipts, json_table(rewardsReceiptItemList, '$[*]' columns (barcode varchar(100) path '$.barcode')) j
    inner join Brand b
    on j.barcode=b.barcode
)
select brand_id, name, count(distinct receipt_id) as ScanFrequency
from receipt_brand
where
DATE_FORMAT(FROM_UNIXTIME(dateScanned/1000),"%Y-%M") = DATE_FORMAT(NOW(),"%Y-%M") -- The current month.
group by brand_id,name
order by ScanFrequency Desc
limit 5;

# How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
# Missing data in 2020-12, so we don’t have receipts data in the previous month.
select distinct YEAR(FROM_UNIXTIME(dateScanned/1000)) as year,
           MONTH(FROM_UNIXTIME(dateScanned/1000)) as month
from Receipts
order by year desc, month desc;
# If the data is more complete, then we can use the following query:
with receipt_brand as (
    select Receipts._id as receipt_id,dateScanned,
       j.barcode, b._id as brand_id, b.name
    from Receipts, json_table(rewardsReceiptItemList, '$[*]' columns (barcode varchar(100) path '$.barcode')) j
    inner join Brand b
    on j.barcode=b.barcode
)
select curr.brand_id, curr.name, count(distinct curr.receipt_id) as ScanFrequency
from receipt_brand curr, receipt_brand prev
where
DATE_FORMAT(FROM_UNIXTIME(curr.dateScanned/1000),"%Y-%M") = DATE_FORMAT(NOW(),"%Y-%M") -- current month
AND DATE_FORMAT(FROM_UNIXTIME(curr.dateScanned/1000),"%Y-%M")
    = DATE_FORMAT(DATE_SUB(FROM_UNIXTIME(prev.dateScanned/1000),INTERVAL 1 MONTH),"%Y-%M") -- previous month
AND curr.brand_id = prev.brand_id
group by curr.brand_id, curr.name
order by ScanFrequency Desc
limit 5;
# This query includes two instances of the Receipts table, aliased as curr and prev. This allows for comparisons and joining of rows between the current month and the previous month.
# The where condition checks:
# if the dateScanned column in the current month matches the current month and year
# if the dateScanned column in the current month matches the previous month and year by adding 1 month to pre_month.dateScanned
# if the rows being compared have the same brand_id


# When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
# Assuming finishing means acceptance, the average spend of receipts being accepted is greater.
select rewardsReceiptStatus, avg(totalSpent) as `average spend`
from Receipts
group by rewardsReceiptStatus
order by `average spend`;

# When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
# Assuming finishing means acceptance, total number of items purchased from receipts being accepted is greater.
select rewardsReceiptStatus, sum(purchasedItemCount) as `total number of items`
from Receipts
group by rewardsReceiptStatus
order by `total number of items`;

# Which brand has the most spend among users who were created within the past 6 months?
# the latest month is 2021-03, so when calculating past 6 months, I assume the max is the current year-month.
# use finalPrice
with userpastsix as(
    select _id, createdDate
    from Users
    where FROM_UNIXTIME(createdDate/1000)>=DATE_SUB((
    select max(FROM_UNIXTIME(createdDate/1000))
    from Users),INTERVAL 6 MONTH)
    and role = 'consumer'
)
select brandId, name, sum(finalPrice) as `spend among users`
from (
    select userId, b.barcode, finalPrice, b._id as brandId, b.name,k.receiptId
    from (
        select  j.barcode, j.finalPrice, r.userId, r._id as receiptId
        from Receipts r,
             json_table(rewardsReceiptItemList,
                 '$[*]' columns (barcode varchar(100) path '$.barcode',
                                 finalPrice decimal(10,2) path '$.finalPrice')) j
    )k
    inner join userpastsix u
    on u._id = k.userId
    inner join Brand b
    on b.barcode = k.barcode
    group by userId, barcode, finalPrice, brandId, name, receiptId
     )t
group by brandId, name
order by `spend among users` desc
limit 1;
# Tostitos has the most spend among users who were created within the past 6 months.

# Which brand has the most transactions among users who were created within the past 6 months?
with userpastsix as(
    select _id, createdDate
    from Users
    where FROM_UNIXTIME(createdDate/1000)>=DATE_SUB((
    select max(FROM_UNIXTIME(createdDate/1000))
    from Users),INTERVAL 6 MONTH)
    and role = 'consumer'
)
select brandId, name, count(distinct receiptId) as `transactions among users`
from(
    select userId, b.barcode, b._id as brandId, b.name,k.receiptId
    from (
        select barcode, r.userId, r._id as receiptId
        from Receipts r, json_table(rewardsReceiptItemList, '$[*]' columns (barcode varchar(100) path '$.barcode')) j
    )k
    inner join userpastsix u
    on u._id = k.userId
    inner join Brand b
    on b.barcode = k.barcode
    )t
group by brandId,name
order by `transactions among users` desc
limit 1;
# Tostitos has the most transactions among users who were created within the past 6 months.

