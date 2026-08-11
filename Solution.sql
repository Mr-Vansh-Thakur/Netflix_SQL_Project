USE NetflixDB
-- 15 Business Problems & Solutions
SELECT * FROM Netflix
-- 1. Count the number of Movies vs TV Shows
SELECT 
type,
COUNT(*) as Total_Count
FROM Netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows
SELECT
    type,
    rating
FROM(
SELECT
    type,
    rating,
    COUNT(*) AS Total_Count,
    RANK() OVER ( PARTITION BY type ORDER BY COUNT(*) DESC ) AS Ranking
FROM Netflix
GROUP BY type, rating
)t
WHERE Ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM Netflix
WHERE type = 'Movie' AND 
release_year = 2020

--4. Find the top 5 countries with the most content on Netflix
SELECT TOP 5
    TRIM(value) AS new_country,
    COUNT(show_id) AS total_content
FROM Netflix
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(show_id) desc;

-- 5. Identify the longest movie
SELECT TOP 1
    type,
    title,
    CAST(TRIM(REPLACE(duration, 'min', '')) AS INT) AS new_duration
FROM Netflix
WHERE type = 'Movie'
ORDER BY new_duration DESC;

-- 6. Find content added in the last 5 years
SELECT *,
TRY_CONVERT(DATE, date_added) as DateAfterConvert
FROM Netflix
WHERE TRY_CONVERT(DATE, date_added) >= (
    SELECT DATEADD(YEAR, -5, GETDATE())
);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *,
    TRIM(value) AS new_director
FROM Netflix
CROSS APPLY STRING_SPLIT(director, ',')
WHERE TRIM(value) = 'Rajiv Chilaka'

SELECT *
FROM Netflix
WHERE director LIKE ('%Rajiv Chilaka%')

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM Netflix
WHERE type = 'TV Show'
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- 9. Count the number of content items in each genre
SELECT 
    TRIM(value) AS genre,
    COUNT(show_id)
FROM Netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value)
ORDER BY COUNT(show_id) DESC;


-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!
SELECT TOP 5
    YEAR(TRY_CONVERT(DATE, date_added)) AS release_year,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS avg_content_percentage
FROM Netflix
WHERE country = 'India'
GROUP BY YEAR(TRY_CONVERT(DATE, date_added))
ORDER BY avg_content_percentage DESC;

-- 11. List all movies that are documentaries
SELECT * 
FROM Netflix
WHERE listed_in LIKE ('%Documentaries%');

-- 12. Find all content without a director
SELECT *
FROM Netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
    SELECT *
    FROM Netflix
    WHERE casts LIKE '%Salman Khan%'
    AND release_year > YEAR(GETDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT TOP 10
TRIM(Value) as new_caste,
COUNT(show_id) as Actor_Count_in_India
FROM Netflix
CROSS APPLY STRING_SPLIT(casts,',')
WHERE country LIKE ('%India%')
GROUP BY TRIM(Value)
ORDER BY COUNT(show_id) DESC

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
---the description field. Label content containing these keywords as 'Bad' and all other 
---content as 'Good'. Count how many items fall into each category.

WITH New_Table AS
(
    SELECT *,
        CASE
            WHEN description LIKE '%kill%'
              OR description LIKE '%violence%'
            THEN 'Bad'
            ELSE 'Good'
        END AS Category
    FROM Netflix
)
SELECT
    Category,
    COUNT(*) AS Total_Count
FROM New_Table
GROUP BY Category;