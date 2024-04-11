/*
Question #1:
Return users who have booked and completed at least 10 flights, ordered by user_id.

Expected column names: `user_id`
*/

WITH total_flights AS(
	SELECT u.user_id,
		SUM(CASE WHEN s.flight_booked = 'true' 
			AND cancellation = 'false' THEN 1
			ELSE 0 END) AS completed_flights
	FROM users AS u
	JOIN sessions AS s
	ON u.user_id = s.user_id
	GROUP BY u.user_id)
SELECT user_id
FROM total_flights
WHERE completed_flights >= 10
ORDER BY user_id;

/*
Question #2: 
Write a solution to report the trip_id of sessions where:

1. session resulted in a booked flight
2. booking occurred in May, 2022
3. booking has the maximum flight discount on that respective day.

If in one day there are multiple such transactions, return all of them.

Expected column names: `trip_id`
*/

WITH may_flights AS(
	-- obtain trip id, discount amount, and calendar day for 05/2022 where a flight was booked WITH a discount
	SELECT trip_id, 
		flight_discount_amount,
		DATE_PART('day', session_end) AS may_day
	FROM sessions
	WHERE CAST(session_end AS text) LIKE '2022-05%'
		AND flight_booked = 'true'
		AND flight_discount = 'true'),
max_day_discount AS(
	-- select the maximum discount for each of the 31 days in May 2022
	SELECT may_day, 
		MAX(flight_discount_amount) AS max_daily_discount
	FROM may_flights
	GROUP BY may_day)
-- join CTEs based on calendar day, get trip id's where their discount matches the max day discount
SELECT f.trip_id
	--, f.flight_discount_amount, f.may_day, d.max_daily_discount
FROM may_flights AS f
JOIN max_day_discount AS d
ON f.may_day = d.may_day
WHERE f.flight_discount_amount = d.max_daily_discount
ORDER BY f.trip_id;

/*
Question #3: 
Write a solution that will, for each user_id of users with greater than 10 flights, 
find out the largest window of days between 
the departure time of a flight and the departure time 
of the next departing flight taken by the user.

Expected column names: `user_id`, `biggest_window`
*/

--- paste Q1 query to obtain the user_id list of users with >10 flights, just change >= to >
-- this list of user_ids with >10 flights is frequent_flyers

WITH total_flights AS(
	-- obtain users' number of flights
	SELECT u.user_id,
		SUM(CASE WHEN s.flight_booked = 'true' 
			AND cancellation = 'false' THEN 1
			ELSE 0 END) AS completed_flights
	FROM users AS u
	JOIN sessions AS s
	ON u.user_id = s.user_id
	GROUP BY u.user_id),
frequent_flyers AS(
	-- select users with > 10 flights
	SELECT user_id
	FROM total_flights
	WHERE completed_flights > 10
	ORDER BY user_id),
/* select user_id, their departure time
over the resulting table, add a new column for the difference between the current departure_time and the previous one. Use frequent_flyers with an inner join to obtain only users with > 10 flights */
last_prev_departure AS (
SELECT s.user_id,
	f.departure_time,
	(DATE(f.departure_time) - DATE(LAG(f.departure_time) 
		OVER (PARTITION BY s.user_id ORDER BY f.departure_time))) AS time_between_flights
FROM sessions s
JOIN flights AS f 
ON s.trip_id = f.trip_id
JOIN frequent_flyers AS ff 
ON s.user_id = ff.user_id
WHERE f.trip_id NOT IN(
	-- only select trips that were not cancelled
	SELECT f.trip_id
	FROM flights AS f
	JOIN sessions AS s
	ON f.trip_id = s.trip_id
	WHERE s.cancellation = 'true'))
-- group by user and select the max time_between_flights for each
SELECT user_id,
	MAX(time_between_flights)
FROM last_prev_departure
GROUP BY user_id
ORDER BY user_id;

/*
Question #4: 
Find the user_id’s of people whose origin airport is Boston (BOS) 
and whose first and last flight were to the same destination. 
Only include people who have flown out of Boston at least twice.

Expected column names: user_id
*/
WITH main AS(
	-- obtain variables of interest and filter flights originating from BOS
	SELECT u.user_id,
	s.trip_id,
	s.cancellation AS trip_cancelled,
	f.destination,
	DATE(f.departure_time) AS departure_time
	FROM flights AS f
	JOIN sessions AS s
	ON s.trip_id = f.trip_id
	JOIN users AS u
	ON u.user_id = s.user_id
	WHERE origin_airport = 'BOS'
	ORDER BY 1, 2),
bos_departures AS(
	-- remove cancelled flights
	SELECT *
	FROM main
	WHERE trip_id NOT IN (
		SELECT trip_id 
		FROM main 
		WHERE trip_cancelled = 'true')),
num_flights AS(
	-- counts number of times a user has flown from boston, plus date of first and last flights
	SELECT user_id,
	COUNT(user_id) AS flights_from_bos,
	MIN(departure_time) AS first_departure,
	MAX(departure_time) AS last_departure
	FROM bos_departures
	GROUP BY user_id
	ORDER BY user_id)
/* joins num_flights with b1, which is just bos_departures filtering users who have flown from BOS at least twice and where departure_time corresponds to first_departure in num_flights (i.e., b1 is essentially a table with information of exlcusively user's first flight). Then also joins b2, which is essentially a table with information of exclusively user's last flight. Finally, filters for records where b1 and b2 have the same destination.*/
SELECT b1.user_id -- ,
	--b1.destination AS first_destination,
	--b1.departure_time AS first_departure_date,
	--b2.destination AS last_destination,
	--b2.departure_time AS last_departure_date
FROM bos_departures AS b1
JOIN num_flights AS n
ON n.user_id = b1.user_id
JOIN bos_departures AS b2
ON n.user_id = b2.user_id
WHERE n.flights_from_bos >= 2
	AND n.first_departure = b1.departure_time
	AND n.last_departure = b2.departure_time
	AND b1.destination = b2.destination;
