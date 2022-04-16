-- confirming the number of books for each year in the dataset is 50
SELECT year, COUNT(year)
FROM BestsellingBooks
GROUP BY year;

-- Which genre has more books in the top 50 bestselling books across the years 2009 up until March 2022 on amazon?
SELECT genre, COUNT(*) AS best_selling_years
FROM BestsellingBooks
GROUP BY genre
ORDER BY best_selling_years DESC;

-- Do non-fictional books always have a higher count than fictional books among the top 50 bestselling books each year on amazon?
SELECT year, genre, COUNT(genre)
FROM BestsellingBooks
GROUP by year, Genre
ORDER BY year,COUNT(genre) DESC;

-- Which author has the highest number of books in the top 50 category each year given the genre?
SELECT year, genre, author, COUNT(name)
FROM BestsellingBooks
GROUP BY year, genre, author
ORDER BY year, COUNT(*) DESC;

-- Which books did this author write?
SELECT year, author, name
FROM BestsellingBooks
WHERE author LIKE '%Meyer%';

-- Are there authors who write both fictional and non-fictional books in this dataset? 
SELECT author
FROM (SELECT author, genre, COUNT(*)
		FROM BestsellingBooks
	GROUP BY author, Genre
	ORDER BY COUNT(*) DESC)
GROUP BY author
HAVING COUNT(author) > 1;

-- Showing the authors from the previous query and their fictional and non-fictional books
SELECT author, genre, Name
FROM BestsellingBooks
WHERE author in ('DK', 'Scholastic');

UPDATE BestsellingBooks
SET name = 'the 5 love languages: the secret to love that lasts'
WHERE name LIKE 'the 5 love languges%';
UPDATE BestsellingBooks
SET name = 'oh, the places you''ll go!'
WHERE name LIKE 'Oh, the Places You''ll Go!%';

-- Are there books that have remained in the top 50 bestsellers from 2009 to 2022? Yes, 1 book 
SELECT name, COUNT(name) AS number_of_years
FROM BestsellingBooks
GROUP BY name
HAVING COUNT(name) >= (SELECT MAX(year) - MIN(year) FROM BestsellingBooks)
ORDER BY COUNT(name) DESC;

-- On average, which genre cost more across all years?
SELECT genre, ROUND(AVG(price),2) AS average_price
FROM BestsellingBooks
GROUP BY Genre
ORDER BY average_price DESC;

-- Showing the number of books and average price of books for each year and genre 
SELECT year, genre, COUNT(genre) AS number_of_books, ROUND(AVG(price), 2) AS average_price
FROM BestsellingBooks
GROUP BY year, Genre
ORDER BY year, average_price DESC;

-- Books and their maximum rating and number of reviews - some books appear in top 50 in multiple years,so the maximum rating and number of reviews would 
-- be used 
DROP VIEW IF EXISTS books_and_ratings;
CREATE VIEW books_and_ratings AS 
SELECT name, genre, MAX(userrating) AS user_rating, MAX(reviews) AS number_of_reviews, MAX(price) AS price
FROM BestsellingBooks
GROUP BY name, genre;

 -- What is the summary statistics for the reviews and ratings of fictional and non-fictional books?
 -- creating a table to use in calculating the median ratings of fictional and non-fictional books
DROP TABLE IF EXISTS temp_rating_median;
CREATE TEMP TABLE temp_rating_median AS 
SELECT genre, user_rating
FROM books_and_ratings
ORDER BY genre, user_rating;
--creating a table to use in calculating the median number of reviews for fictional and non-fictional books
DROP TABLE IF EXISTS temp_review_median;
CREATE TEMP TABLE temp_review_median AS 
SELECT genre, number_of_reviews
FROM books_and_ratings
ORDER BY genre, number_of_reviews;
-- creating a table to use in calculating the median price of books in fictional and non-fictional genres
DROP TABLE IF EXISTS temp_price_median;
CREATE TEMP TABLE temp_price_median AS 
SELECT genre, price
FROM books_and_ratings
ORDER BY genre, price;
-- Median rating of fictional and non-fictional books
WITH median_rating AS (
					SELECT a.genre, user_rating
					FROM temp_rating_median AS a
					INNER JOIN 
					(SELECT genre, CAST((MAX(ROWID) + MIN(ROWID))/2 AS INT) AS midrow
					FROM temp_rating_median
					GROUP BY genre) AS c
					ON a.ROWID = c.midrow),
-- Median number of reviews for fictional and non-fictional books
median_reviews AS (
				SELECT a.genre, number_of_reviews
				FROM temp_review_median AS a
				INNER JOIN 
				(SELECT genre, CAST((MAX(ROWID) + MIN(ROWID))/2 AS INT) AS midrow
				FROM temp_review_median
				GROUP BY genre) AS c
				 ON a.ROWID = c.midrow),		
-- Median price for fictional and non-fictional books
median_price AS (
			   SELECT a.genre, price
			   FROM temp_price_median AS a
			   INNER JOIN
			   (SELECT genre, CAST((MAX(ROWID) + MIN(ROWID))/2 AS INT) AS midrow
			   FROM temp_price_median
			   GROUP BY genre) AS c
			   ON a.ROWID = c.midrow)
				
-- summary statistics of the number of reviews and the ratings of fictional and non fictional books		 
SELECT b.genre, 		
		MIN(b.user_rating) AS min_rating,
		ROUND(AVG(b.user_rating),1) AS average_rating,
		ROUND(AVG(ra.user_rating),1) AS median_rating,
		MAX(b.user_rating) AS max_rating, 
		MIN(b.number_of_reviews) AS min_num_of_reviews,
		ROUND(AVG(b.number_of_reviews))AS average_num_of_reviews,
		AVG(re.number_of_reviews) AS median_num_of_reviews,
		MAX(b.number_of_reviews) AS max_num_of_reviews,
		MIN(b.price) AS min_price,
		ROUND(AVG(b.price), 2) AS average_price,
		ROUND(AVG(p.price),2) AS median_price,
		MAX(b.price) AS max_price
FROM books_and_ratings AS b
LEFT JOIN median_rating AS ra
ON ra.genre = b.Genre
LEFT JOIN median_reviews AS re
ON re.genre = b.Genre
LEFT JOIN median_price AS p
ON p.genre = b.genre
GROUP BY b.genre;

-- the min price for both fictional and non-fictional books is 0. Which books are these?
SELECT * 
FROM BestsellingBooks
WHERE price = 0;

-- prices and ratings for fictional and non-fictional books over the years
SELECT year, 
	  genre,
	  MIN(price) AS min_price,
	  ROUND(AVG(price),2) AS average_price,
	  MAX(price)AS max_price,
	  MIN(UserRating) AS min_rating,
	  ROUND(AVG(userrating),1) AS average_rating,
	  MAX(userrating) AS max_rating
FROM BestsellingBooks
GROUP BY year, genre
ORDER BY year;

-- which book had the lowest rating in this dataset?
SELECT * 
FROM BestsellingBooks
WHERE UserRating = (SELECT MIN(userrating) FROM BestsellingBooks);

-- How many times was this book among the top 50 books on Amazon from 2009 to 2022?; once
SELECT * 
FROM BestsellingBooks
WHERE name LIKE '%The Casual Vacancy%';

-- How many times was the author among authors of the top 50 best selling books on Amazon from 2009 to 2022?
SELECT * 
FROM BestsellingBooks
WHERE author = 'J.K. Rowling';

-- Coming back to authors, which authors have the highest number of books among the top 50 books on Amazon across all years from 2009 to 2022?
-- Creating a temporary table of the result of this query to check what these authors write about
DROP TABLE IF EXISTS top10_authors;
CREATE TEMP TABLE top10_authors AS
SELECT author, genre, 
		COUNT(author) AS book_count
FROM BestsellingBooks
GROUP BY Author, genre 
ORDER BY book_count DESC
-- limit the result to the top 10 authors with the highest number of books
LIMIT 10;

-- What do these authors write about?
SELECT * 
FROM BestsellingBooks
WHERE author IN (SELECT Author
				 FROM top10_authors)
ORDER BY author;



-- Which of these books are written as a series and which of them are repeated bestsellers from 2009 to 2022?
-- separating repeated best sellers from books written as part of a series.

WITH books_and_authors AS (
							SELECT * 
							FROM BestsellingBooks
							WHERE author IN (SELECT Author
											 FROM top10_authors)
							ORDER BY author ),
repeated_best_sellers AS (
							SELECT LOWER(TRIM(name)) AS name, COUNT(name) AS book_count
							FROM books_and_authors
							GROUP BY name
							HAVING COUNT(name) > 1
							ORDER BY book_count DESC),
 books_in_series AS (    
						  SELECT * 
						  FROM books_and_authors
						  WHERE (name LIKE '%(%)%' OR name LIKE '%Games' OR name LIKE '%Diary%')
						  AND name != 'What Pet Should I Get? (Classic Seuss)'
						  AND name != 'The Four Agreements: A Practical Guide to Personal Freedom (A Toltec Wisdom Book)'
						  GROUP BY name
						  HAVING COUNT(name) = 1
						  ),
other_books AS (		SELECT name FROM books_and_authors
						EXCEPT
						SELECT name FROM repeated_best_sellers
						EXCEPT
						SELECT name FROM books_in_series)

SELECT * FROM repeated_best_sellers

DROP TABLE IF EXISTS best_selling_series;
CREATE TEMP TABLE best_selling_series (
		name VARCHAR,
		author VARCHAR,
		user_rating FLOAT,
		average_reviews INT,
		price FLOAT,
		number_of_books INT,
		genre VARCHAR
);

INSERT INTO best_selling_series (name, author, user_rating, average_reviews, number_of_books, price, genre)
VALUES ('Dog Man', 'Dav Pilkey', 4.9, 13826, 7, 7.0, 'Fiction'),
	   ('Diary of a Wimpy Kid', 'Jeff Kinney', 4.8, 8659, 13, 9.62, 'Fiction'),
	   ('Percy Jackson and the Olympians', 'Rick Riordan', 4.8, 4862, 6, 10.17, 'Fiction'),
	   ('The Kane Chronicles', 'Rick Riordan', 4.7, 1913, 3, 11.33, 'Fiction'),
	   ('The Hunger Games', 'Suzanne Collins', 4.7, 29048, 6, 14.17, 'Fiction');
	   
SELECT * 
FROM best_selling_series