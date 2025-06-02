use mubi;

-- створення таблиці
CREATE TABLE `movies` (
  `MovieTitile` varchar(255) DEFAULT NULL,
  `MovieID` int(10) unsigned DEFAULT NULL,
  `movie_key` int(11) NOT NULL AUTO_INCREMENT,
  `MovieReleaseDate` int(10) unsigned DEFAULT NULL,
  `MovieURL` text DEFAULT NULL,
  `MovieTitleLanguage` varchar(100) DEFAULT NULL,
  `MoviePopularity` int(11) DEFAULT NULL,
  `MovieImageURL` varchar(100) DEFAULT NULL,
  `DirectorID` text DEFAULT NULL,
  `DirectorName` text DEFAULT NULL,
  `DirectorURL` text DEFAULT NULL,
  `RatingID` int(11) DEFAULT NULL,
  `RatingUserID` int(11) DEFAULT NULL,
  `RatingURL` text DEFAULT NULL,
  `RatingScore` int(11) DEFAULT NULL,
  `RatingTimetampUTC` datetime DEFAULT NULL,
  `RatingCritic` text DEFAULT NULL,
  `RatingCriticLikes` int(11) DEFAULT NULL,
  `RatingCriticComment` int(11) DEFAULT NULL,
  PRIMARY KEY (`movie_key`)
) ENGINE=InnoDB AUTO_INCREMENT=30507884 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci


-- створення процедури конвертації JSON

DELIMITER //
CREATE OR REPLACE PROCEDURE convertJSON()
BEGIN
INSERT INTO mubi.movies (
  MovieTitile, MovieID, MovieReleaseDate, MovieURL, MovieTitleLanguage, 
  MoviePopularity, MovieImageURL, DirectorID, DirectorName, DirectorURL,
  RatingID, RatingUserID, RatingURL, RatingScore, RatingTimetampUTC,
  RatingCritic, RatingCriticLikes, RatingCriticComment
)
SELECT
  MovieTitile, MovieID, 
  IF(
    RawMovieReleaseDate IS NULL OR JSON_UNQUOTE(RawMovieReleaseDate) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawMovieReleaseDate) AS SIGNED)
  ), 
  MovieURL, MovieTitleLanguage, 
  MoviePopularity, MovieImageURL, DirectorID, DirectorName, DirectorURL,
  IF(
    RawRatingID IS NULL OR JSON_UNQUOTE(RawRatingID) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingID) AS SIGNED)
  ),
  IF(
    RawRatingUserID IS NULL OR JSON_UNQUOTE(RawRatingUserID) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingUserID) AS SIGNED)
  ), RatingURL,
  IF(
    RawRatingScore IS NULL OR JSON_UNQUOTE(RawRatingScore) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingScore) AS SIGNED)
  ),
  IF(
    RawRatingTimetampUTC IS NULL OR JSON_UNQUOTE(RawRatingTimetampUTC) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingTimetampUTC) AS DATETIME)
  ), RatingCritic, 
  IF(
    RawRatingCriticLikes IS NULL OR JSON_UNQUOTE(RawRatingCriticLikes) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingCriticLikes) AS SIGNED)
  ), 
  IF(
    RawRatingCriticComment IS NULL OR JSON_UNQUOTE(RawRatingCriticComment) = 'null',
    NULL,
    CAST(JSON_UNQUOTE(RawRatingCriticComment) AS SIGNED)
  )
FROM (
  SELECT
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MovieTitile')) AS MovieTitile,
    JSON_EXTRACT(json_data, '$.MovieID') AS MovieID,
    JSON_EXTRACT(json_data, '$.MovieReleaseDate') AS RawMovieReleaseDate,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MovieURL')) AS MovieURL,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MovieTitleLanguage')) AS MovieTitleLanguage,
    JSON_EXTRACT(json_data, '$.MoviePopularity') AS MoviePopularity,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MovieImageURL')) AS MovieImageURL,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.DirectorID')) AS DirectorID,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.DirectorName')) AS DirectorName,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.DirectorURL')) AS DirectorURL,
    JSON_EXTRACT(json_data, '$.RatingID') AS RawRatingID,
    JSON_EXTRACT(json_data, '$.RatingUserID') AS RawRatingUserID,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.RatingURL')) AS RatingURL,
    JSON_EXTRACT(json_data, '$.RatingScore') AS RawRatingScore,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.RatingTimetampUTC')) AS RawRatingTimetampUTC,
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.RatingCritic')) AS RatingCritic,
    JSON_EXTRACT(json_data, '$.RatingCriticLikes') AS RawRatingCriticLikes,
    JSON_EXTRACT(json_data, '$.RatingCriticComment') AS RawRatingCriticComment
  FROM mubi.mubi
) AS parsed;

END//
DELIMITER ;


-- виклик процедур
call convertJSON();


-- видалення процедури
DROP PROCEDURE IF EXISTS convertJSON;


-- Видалення повторів

DELETE m
FROM mubi.movies m
JOIN (
    SELECT MIN(m2.movie_key) AS min_key
    FROM mubi.movies m2
    JOIN (
        SELECT MovieID, DirectorID, RatingID
        FROM mubi.movies
        GROUP BY MovieID, DirectorID, RatingID
        HAVING COUNT(*) > 1
    ) rep
      ON m2.MovieID = rep.MovieID
     AND m2.DirectorID = rep.DirectorID
     AND m2.RatingID = rep.RatingID
    GROUP BY m2.MovieID, m2.DirectorID, m2.RatingID
) rep2
  ON m.movie_key = rep2.min_key;

-- переіменування таблиці


RENAME TABLE movies TO movies_old;

-- створення окремої таблиці фільмів

CREATE TABLE movies AS SELECT MovieTitile, MovieID, MovieReleaseDate, MovieURL, 
MovieTitleLanguage, MoviePopularity, MovieImageURL, DirectorID, DirectorName, 
DirectorURL
FROM mubi.movies_old
GROUP BY MovieID;

-- створення таблиці директорів


CREATE TABLE directors AS
SELECT CAST(cs.DirectorID AS UNSIGNED) AS DirectorID, DirectorName, DirectorURL
FROM (
  WITH RECURSIVE cast_split AS (
    SELECT
      TRIM(SUBSTRING_INDEX(DirectorID, ',', 1)) AS DirectorID,
      TRIM(SUBSTRING_INDEX(DirectorName, ',', 1)) AS DirectorName,
      TRIM(SUBSTRING_INDEX(DirectorURL, ',', 1)) AS DirectorURL,

      TRIM(SUBSTRING(DirectorID, LENGTH(SUBSTRING_INDEX(DirectorID, ',', 1)) + 2)) AS ids_rest,
      TRIM(SUBSTRING(DirectorName, LENGTH(SUBSTRING_INDEX(DirectorName, ',', 1)) + 2)) AS names_rest,
      TRIM(SUBSTRING(DirectorURL, LENGTH(SUBSTRING_INDEX(DirectorURL, ',', 1)) + 2)) AS urls_rest
    FROM mubi.movies m

    UNION ALL

    SELECT
      TRIM(SUBSTRING_INDEX(ids_rest, ',', 1)),
      TRIM(SUBSTRING_INDEX(names_rest, ',', 1)),
      TRIM(SUBSTRING_INDEX(urls_rest, ',', 1)),

      TRIM(SUBSTRING(ids_rest, LENGTH(SUBSTRING_INDEX(ids_rest, ',', 1)) + 2)),
      TRIM(SUBSTRING(names_rest, LENGTH(SUBSTRING_INDEX(names_rest, ',', 1)) + 2)),
      TRIM(SUBSTRING(urls_rest, LENGTH(SUBSTRING_INDEX(urls_rest, ',', 1)) + 2))
    FROM cast_split
    WHERE ids_rest IS NOT NULL AND ids_rest <> ''
  )
  SELECT *
  FROM cast_split
  GROUP BY DirectorID, DirectorName, DirectorURL
) AS cs
ORDER BY DirectorID;


-- Видалення повторів з таблиці директорів

CREATE TEMPORARY TABLE dir_repeats AS SELECT d.DirectorID, max(LENGTH(DirectorName)) AS len
FROM directors d
GROUP BY d.DirectorID
HAVING COUNT(d.DirectorName) > 1;


CREATE TEMPORARY TABLE rep_names AS SELECT DirectorName
FROM dir_repeats dr
RIGHT JOIN directors d
ON dr.DirectorID = d.DirectorID
WHERE NOT LENGTH(d.DirectorName) = dr.len;

DELETE d
FROM directors d
WHERE d.DirectorName IN (SELECT * FROM rep_names);


DROP TEMPORARY TABLE IF EXISTS dir_repeats;

DROP TEMPORARY TABLE IF EXISTS rep_names; 

-- Встановлення ключів фільмів та директорів

ALTER TABLE movies
ADD PRIMARY KEY (MovieID);

ALTER TABLE directors
ADD PRIMARY KEY (DirectorID);

-- Створення таблиці залежностей фільм- директор 


CREATE TABLE movies_directors AS SELECT d.DirectorID, m.MovieID
FROM directors d
RIGHT JOIN movies m 
 ON m.DirectorID REGEXP CONCAT('(^|, )', d.DirectorID, '($|,)');

 
 -- призначення ключових полів з таблиці фільм- директор 
 
ALTER TABLE movies_directors 
ADD PRIMARY KEY (DirectorID, MovieID);


-- додавання зовнішніх ключів до до фільм - дериктор

ALTER TABLE movies_directors 
ADD CONSTRAINT fk_director
FOREIGN KEY (DirectorID)
REFERENCES directors(DirectorID);


ALTER TABLE movies_directors 
ADD CONSTRAINT fk_movie_director
FOREIGN KEY (MovieID)
REFERENCES movies(MovieID);


-- видалення колонок директора з фильмів

ALTER TABLE movies
DROP COLUMN DirectorID,
DROP COLUMN DirectorName,
DROP COLUMN DirectorURL;


-- Створення таблиці ratings

CREATE TABLE ratings AS SELECT RatingID, RatingUserID, MovieID, RatingURL, 
RatingScore, RatingCritic, RatingCriticLikes, RatingCriticComment
FROM movies_old
WHERE NOT ISNULL(RatingID);

-- Створення первинного ключа

ALTER TABLE ratings
ADD PRIMARY KEY (RatingID);


-- додавання зовнішнього ключа до таблиці ratings

ALTER TABLE ratings
ADD CONSTRAINT fk_movie_ratings
FOREIGN KEY (MovieID)
REFERENCES movies(MovieID);

-- Виділення рейтинг критики в окрему таблицю

CREATE TABLE rating_critic AS SELECT r.RatingID, r.RatingCritic, r.RatingCriticComment, r.RatingCriticLikes
FROM ratings r 
WHERE NOT r.RatingCritic = "null";


-- Встановлення ключів

ALTER TABLE rating_critic 
ADD PRIMARY KEY (RatingID);

ALTER TABLE rating_critic
ADD CONSTRAINT fk_ratings
FOREIGN KEY (RatingID)
REFERENCES ratings(RatingID);

-- Видалення колонок з табилці рейтингів

ALTER TABLE ratings
DROP COLUMN RatingCritic,
DROP COLUMN RatingCriticLikes,
DROP COLUMN RatingCriticComment;

-- Видалення таблиці movies old

DROP TABLE movies_old;














 











