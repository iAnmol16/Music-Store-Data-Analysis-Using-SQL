-- Creating tables' schemas 
CREATE TABLE Artist( ArtistId INT, Name VARCHAR(100))
CREATE TABLE Album( AlbumId INT, Title VARCHAR(100), ArtistId INT)
CREATE TABLE Playlist(PlaylistId INT,Name VARCHAR(100))
CREATE TABLE Playlist_track( PlaylistId INT, TrackId INT)
CREATE TABLE track(track_id INT,
name VARCHAR(150),
album_id INT,
media_type_id INT,
genre_id INT,
composer VARCHAR(200),
milliseconds INT,
bytes INT,
unit_price DECIMAL(3,2) )

CREATE TABLE customer(customer_id INT,
first_name VARCHAR(20),
last_name VARCHAR(20),
company VARCHAR(50),
address VARCHAR(50),
city VARCHAR(50),
state VARCHAR(10),
country VARCHAR(20),
postal_code VARCHAR(20),
phone VARCHAR(20),
fax VARCHAR(20),
email VARCHAR(50),
support_rep_id INT)

CREATE TABLE employee(
employee_id INT,
last_name VARCHAR(20),
first_name VARCHAR(20),
title VARCHAR(50),
reports_to INT,
levels VARCHAR(5),
birthdate DATE,
hire_date DATE,
address VARCHAR(50),
city VARCHAR(30),
state VARCHAR(20),
country VARCHAR(20),
postal_code VARCHAR(20),
phone VARCHAR(20),
fax VARCHAR(20),
email VARCHAR(50) )

CREATE TABLE genre(genre_id INT,name VARCHAR(20))

CREATE TABLE invoice(invoice_id INT,
customer_id INT,
invoice_date DATE,
billing_address VARCHAR(80),
billing_city VARCHAR(20),
billing_state VARCHAR(20),
billing_country VARCHAR(20),
billing_postal_code VARCHAR(20),
total DECIMAL(6,2) )

CREATE TABLE invoice_line(invoice_line_id INT,
invoice_id INT,
track_id INT ,
unit_price DECIMAL(5,2),
quantity INT )

CREATE TABLE media_type(
media_type_id INT,
name VARCHAR(30) )

--Coping data to the tables by changing the names in path_name and the table name itself
COPY track --table_name
FROM 'C:\Projects Data Analysis\MusicDatabase Inlighn Tech\track.csv' --path_name
DELIMITER ','
HEADER CSV

-- Queries Solutions  -->

-- 1. Easy Level Queries:

-- Q1: Find the most senior employee based on job title.
SELECT CONCAT(first_name,' ',last_name), levels 
FROM employee 
ORDER BY levels DESC
LIMIT 1

SELECT * FROM employee --For everything from employee_table

-- Q2: Determine which countries have the most invoices.
SELECT billing_country,
COUNT(billing_country) AS Most_billing
FROM  invoice
GROUP BY billing_country
ORDER BY billing_country DESC
LIMIT 1


--Q3: Identify the top 3 invoice totals.
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3


--Q4: Find the city with the highest total invoice amount to determine the best location for
--a promotional event.
SELECT billing_city,SUM(total) AS Total FROM invoice
GROUP BY billing_city
order by SUM(total) DESC
LIMIT 1


--Q5: Identify the customer who has spent the most money.
SELECT c.Customer_id,CONCAT(c.first_name,' ',c.last_name) AS Customer_Name,SUM(i.total) AS Total FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.Customer_id, Customer_Name
ORDER BY Total DESC
LIMIT 1

-- 2. Moderate Level Queries:

--  Q1: Find the email, first name, and last name of customers who listen to Rock music.
SELECT c.email, c.first_name, c.last_name, g.name AS Genre  FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON t.track_id = il.track_id
JOIN genre g
ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY c.email, c.first_name, c.last_name, g.name

SELECT * FROM genre


--  Q2: Identify the top 10 rock artists based on track count.
SELECT ar.name AS Artist_name, COUNT(track_id) AS Track_count FROM album a
JOIN artist ar
On a.artistId = ar.artistId
JOIN track t
ON t.album_id = a.albumId
JOIN genre g
ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY COUNT(track_id) DESC
LIMIT 10

--  Q3: Find all track names that are longer than the average track length.
SELECT name, ROUND(milliseconds,2) FROM track 
WHERE milliseconds > (SELECT  ROUND(AVG(milliseconds),2) FROM track)
ORDER BY ROUND(milliseconds,2)  DESC

--AVERAGE Track length in milliseconds - 393599.21
SELECT  ROUND(AVG(milliseconds),2) FROM track


-- 3. Advanced Level Queries:

-- Q1: Calculate how much each customer has spent on each artist.
SELECT CONCAT(first_name,' ',last_name) AS customer_name,ar.name, SUM(i.total) AS Total_spent FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON t.track_id = il.track_id
JOIN album a
ON t.album_id = a.albumId
JOIN artist ar
On a.artistId = ar.artistId
GROUP BY ar.name, customer_name
ORDER BY  ar.name 

-- • Q2: Determine the most popular music genre for each country based on purchases.
WITH Tem AS (SELECT c.country AS Country,g.name AS Most_Famous_Genre, SUM(i.total) AS Total_Purchase, DENSE_RANK() OVER(PARTITION BY c.country ORDER BY SUM(i.total) DESC)AS Ranks
FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON t.track_id = il.track_id
JOIN genre g
ON g.genre_id = t.genre_id
GROUP BY c.country, g.name)

SELECT Country, Most_Famous_Genre, Total_Purchase FROM Tem
WHERE Ranks = 1

-- • Q3: Identify the top-spending customer for each country.

WITH new_t AS (
SELECT c.country AS Country,
	   CONCAT(c.first_name,' ',c.last_name) AS Customer_Fullname,
	   SUM(i.total) AS top_spending,
	   DENSE_RANK() OVER(PARTITION BY c.country ORDER BY SUM(i.total) DESC)AS Ranks 
FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
GROUP BY c.country, Customer_Fullname
ORDER BY c.country, Customer_Fullname)

SELECT Country,Customer_Fullname, top_spending FROM new_t
WHERE Ranks = 1



