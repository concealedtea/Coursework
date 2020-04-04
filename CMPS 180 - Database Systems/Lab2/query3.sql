SELECT 
    movieID
    , name
    , year
    , Movies.length
FROM (
    SELECT 
        length 
    FROM movies
    where name = 'Avengers' and year = 2011
) as moviesSub 
JOIN Movies on Movies.length > moviesSub.length
ORDER BY 
    YEAR DESC
    , name ASC