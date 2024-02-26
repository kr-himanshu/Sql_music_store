use music_db;

-- 1. Who is the senior most employee based on job title?

select concat(first_name," ",last_name) as name from employee
order by levels desc limit 1;

-- 2. Which countries have the most Invoices?

select billing_country,count(*) as num_invoice from invoice
group by billing_country
order by num_invoice desc limit 1;

-- 3. What are top 3 values of total invoice?

select total from invoice
order by total desc limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music 
--    Festival in the city we made the most money. Write a query that returns one city that 
--    has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--    totals.

select billing_city,sum(total)as revenue from invoice
group by billing_city
order by revenue desc limit 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--    Write a query that returns the person who has spent the most money.

select c.customer_id,concat(c.first_name,"  ",c.last_name) as name,sum(i.total) as Amt_spent
from customer c
join invoice i on i.customer_id=c.customer_id
group by c.customer_id
order by Amt_spent desc limit 1;

-- 6.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--   Return your list ordered alphabetically by email starting with A.

select distinct email, first_name,last_name from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
where track_id in 
(select track_id from track t join genre g on t.genre_id=g.genre_id
 where g.name like "Rock")
 order by email;
 
 -- 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
--     query that returns the Artist name and total track count of the top 10 rock bands.

select a.artist_id,a.name,count(*) as num_tracks from track t
join album ab on t.album_id=t.album_id
join artist a on ab.artist_id=a.artist_id
join genre g on g.genre_id=t.genre_id
where g.name like "Rock"
group by a.artist_id
order by num_tracks desc limit 10;

-- 8.Return all the track names that have a song length longer than the average song length. 
--   Return the Name and Milliseconds for each track. Order by the song length with the 
--   longest songs listed first.

select name,milliseconds as track_length from track
where milliseconds > ( select avg(milliseconds) as avg_track_length from track)
order by track_length desc;

-- 9. Find how much amount spent by each customer on artists? Write a query to return
--    customer name, artist name and total spent.

select c.customer_id,concat(c.first_name," ",c.last_name) as cust_name, art.name as artist_name,sum(il.unit_price*il.quantity) amt_spent from invoice i 
join customer c on i.customer_id=c.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join artist art on art.artist_id=a.artist_id
group by c.customer_id,art.artist_id
order by c.customer_id;

-- 10. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres

with popular_genre as (
select i.billing_country as country,g.genre_id,g.name,count(il.quantity) as qty,
row_number() over (partition by i.billing_country order by count(il.quantity) desc) as rn from invoice i 
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
group by i.billing_country,g.genre_id
order by i.billing_country, qty ) 
select country,name,qty from popular_genre 
where rn=1;

-- 11. Write a query that determines the customer that has spent the most on music for each 
--     country. Write a query that returns the country along with the top customer and how
--     much they spent. For countries where the top amount spent is shared, provide all 
--     customers who spent this amount.

with cte as (
select i.customer_id,concat(c.first_name," ",c.last_name) as cust_name,i.billing_country,sum(total),
row_number() over(partition by billing_country order by sum(total) desc) as rn
from invoice i
join customer c on i.customer_id=c.customer_id
group by customer_id,billing_country
order by billing_country)

select * from cte 
where rn=1;