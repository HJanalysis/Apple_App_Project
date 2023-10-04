Create Table applestore_description_combined As 
select * from applestore_description1
Union ALL
select * from applestore_description2
union ALL
select * from applestore_description3
union ALL
select * from appleStore_description4

** EXPLORATORY DATA ANALYSIS**
-- check the unique apps in both data setsAppleStore

Select count(distinct id) As UniqueappIds
From AppleStore

Select count(distinct id) As UniqueappIds
From applestore_description_combined

--check missing values in key fields

select count(*) As MissingValues
From AppleStore
where track_name is null or user_rating is null or prime_genre is NULL

select count(*) As MissingValues
From applestore_description_combined
where app_desc is null

--Findout the number of apps per genre

select prime_genre, count(*) as Numapps
From AppleStore
Group by prime_genre
order by Numapps DESC

--Get an overview of the apps rating 

Select min(user_rating) as MinRating,
max(user_rating) as MaxRating,
avg(user_rating) As AvgRating
From AppleStore

--Basic Price Aggregation

SELECT 
    AVG(price) AS AvgPrice,
    MIN(price) AS MinPrice,
    Max(price) As MaxPrice
FROM AppleStore

--identifying top rated 10 apps 

SELECT 
    track_name, 
    user_rating, 
    rating_count_tot
FROM AppleStore
ORDER BY user_rating DESC
LIMIT 10;

**DATA ANALYSIS**

--Determine whether paid apps have higher rating then free apps 

select CASE
           when price > 0 then 'Paid'
           Else 'Free'
        End as app_type,
        avg(user_rating) as Avg_rating
From AppleStore
group by app_type

--Check if apps with more supported language have higer rating 

select CASE
           when lang_num < 10 then '<10 langauges'
           when lang_num between 10 and 30 then '10-30 languages'
           else '>30 languages'
       end as language_bucket,
       avg(user_rating) as Avg_rating
From AppleStore
group by language_bucket
order by avg_rating desc

--Check genres with low rating 

select prime_genre,
       avg(user_rating) as Avg_Rating
From AppleStore
group by prime_genre
order by avg_Rating ASC
Limit 10

--check if there is correlation between the length of the app description and the user rating

select CASE
           when length(b.app_desc) < 500 then 'Short'
           when length (b.app_desc) between 500 and 1000 then 'Medium'
           else 'Long'
       end As description_length_bucket,
       avg(a.user_rating) as average_rating
from AppleStore as A
join applestore_description_combined as B
on a.id = b.id 

group by description_length_bucket
order by average_rating desc 

--check the top-rated apps for each genre

select prime_genre, track_name, user_rating
from (
      select prime_genre, track_name, user_rating,
      rank() over(partition by prime_genre order by user_rating desc, rating_count_tot desc) as rank from AppleStore
  ) as a 
  WHERE a.rank = 1