-- Create Database--

CREATE DATABASE Netflix_db;


-- Create Table --

Drop TABLE IF EXISTS netflix;

CREATE TABLE netflix (
    show_id TEXT PRIMARY KEY,
    "type" TEXT,
    title TEXT,
    director TEXT,
    "cast" TEXT,
    country TEXT,
    date_added DATE,
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT,
    year_added INT,
    month_added INT

)


SELECT * FROM netflix;

--Business Problems


-- 1. Count the number of Movies vs TV Shows

SELECT 
type,COUNT(*) as total_count 
FROM netflix 
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows

SELECT 
     type,
	 rating,
	 total_count 
	 FROM
(
     SELECT type,rating, count(*) as total_count,RANK() OVER(partition by type ORDER BY count(*) DESC) as rk 
     from netflix 
     group by 1,2 
)    as t1
WHERE 
     rk=1;


-- 3. List all movies released in a specific year (eg.2020)

SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


-- 4. Monthly Content Addition in a Specific Year (eg.2021)

SELECT month_added,count(*) as title_added
FROM netflix
WHERE year_added=2021
GROUP BY month_added
ORDER BY month_added;


-- 5. Top 5 Countries by TV show count

SELECT country, count(*) as tv_show_count
FROM netflix
WHERE type = 'TV Show'
GROUP BY country
ORDER BY tv_show_count DESC
LIMIT 5;


-- 6. Directors with More Than 3 Shows

SELECT director, count(*) as total_count
FROM netflix
WHERE director != 'Not Available'
GROUP BY director
HAVING count(*)>3
ORDER BY total_count DESC


-- 7. Find the top 5 countries with the most content on Netflix

SELECT 
  country,
  COUNT(*) AS total_content
FROM (
    SELECT 
      TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country
    FROM netflix
) AS t1
WHERE country != 'Unknown'
GROUP BY country
ORDER BY total_content DESC
LIMIT 5

--other method to solve same business problem using Common Table Expression (CTE)

WITH country_counts AS (
  SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country
  FROM netflix
)

SELECT 
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank,
  country,
  COUNT(*) AS total_content
FROM country_counts
WHERE country != 'Unknown'
GROUP BY country
ORDER BY rank
LIMIT 5;


-- 8. Indentify the longest movie.

SELECT type,
title,
SPLIT_PART(duration,' ',1)::INT as longest_duration
FROM netflix
WHERE type = 'Movie'
AND
duration IS NOT NULL
ORDER BY longest_duration DESC
LIMIT 1

-- 9. Find all the movies/TV shows by director 'Rajiv Chilaka'.

SELECT * 
FROM
(
SELECT *, 
UNNEST(STRING_TO_ARRAY(director,',')) AS director_name
FROM 
netflix
)
WHERE director_name = 'Rajiv Chilaka'


-- other method to solve same business problem using LIKE

SELECT * FROM netflix WHERE director LIKE '%Rajiv Chilaka%'

--other method to solve same business problem using Common Table Expression (CTE)

with CTE as 
(
SELECT *,
UNNEST(STRING_TO_ARRAY(director,',')) as new_director
FROM netflix
)

SELECT *,new_director FROM CTE WHERE new_director = 'Rajiv Chilaka'


-- 10. List all TV shows with more than 5 seasons.

SELECT * ,
SPLIT_PART(duration,' ',1)::INT AS new_duration
FROM netflix 
WHERE type = 'TV Show' 
AND 
SPLIT_PART(duration,' ',1)::INT >5


-- 11. Count the number of content items in each genre.

SELECT
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
COUNT(*) as total_content
FROM netflix
GROUP BY genre;


-- 12. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';


-- 13. Find all content without a director.

SELECT * FROM netflix WHERE director = 'Not Available';


/* 
14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
category,
TYPE,
COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2