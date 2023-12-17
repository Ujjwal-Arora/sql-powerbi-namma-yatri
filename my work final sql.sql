select * from successful_trips;

select * from trips_details;

select * from loc;

select * from duration;

select * from payment;


--total trips

select count(distinct tripid) 
from trips_details;


--total active drivers

select count(distinct driverid) 
from successful_trips;

-- total earnings

select sum(fare) from successful_trips;

-- total Completed successful_trips

select sum(end_ride) from trips_details;

--total searches
select COUNT(searches)
from trips_details

--total searches which got estimate
select sum(searches_got_estimate)
from trips_details


--total searches for quotes
select sum(searches_for_quotes)
from trips_details



--total searches which got quotes
select sum(searches_got_quotes)
from trips_details


--total driver cancelled
select count(*) - sum(driver_not_cancelled)
from trips_details


--total otp entered
select sum(otp_entered)
from trips_details


--total end ride
select sum(end_ride)
from trips_details


--cancelled bookings by driver
select *
from trips_details
where searches_got_quotes=1 and driver_not_cancelled=0


--cancelled bookings by customer
select *
from trips_details
where searches_got_quotes=1 and customer_not_cancelled=0


--average distance per trip
select avg(distance)
from successful_trips



--average fare per trip
select avg(fare)
from successful_trips

--distance travelled
select sum(distance)
from successful_trips


-- which is the most used payment method 
select top 1 method, count(*) as number_of_times_method_used
from successful_trips
join payment
on successful_trips.faremethod=payment.id
group by faremethod,method 
order by number_of_times_method_used desc


-- the highest payment was made through which instrument
with cte as (select *,rank() over (order by fare desc) as rnk
			from successful_trips)
select method
from cte 
join payment
on cte.faremethod=payment.id
where rnk=1

-- which two locations had the most successful_trips
with cte as (select name ,count(*) as number_of_successful_trips,ROW_NUMBER() over(order by count(*) desc) as rw
from successful_trips
join assembly 
on successful_trips.loc_from=assembly.id
group by loc_from,name 
)
select *
from cte
where rw<=2

--top 5 earning drivers
with cte as (select driverid,sum(fare) as total_earnings_per_driver,DENSE_RANK()over(order by sum(fare) desc) as rnk
			from successful_trips
			group by driverid
			)
select *
from cte 
where rnk<=5

-- which duration had most successful_trips
with cte as (select duration,count(*) as number_of_trips,rank() over(order by count(*) desc) as rnk
			from successful_trips
			group by duration)
select * 
from cte 
where rnk=1

-- which driver , customer pair had more orders
with cte as (select driverid,custid,count(*) as number_of_duo_trips,rank() over(order by count(*) desc) as rnk
			from successful_trips
			group by driverid,custid
			)
select *
from cte
where rnk=1

-- search to estimate rate
select SUM(searches_got_quotes)*100/SUM(searches_got_estimate)
from trips_details
--(% of times when the customers aggreed to the given estimated price which can show how competitive our prices are,etc)


-- estimate to search for quote rates
select SUM(searches_for_quotes)*100/SUM(searches_got_estimate)
from trips_details

-- quote acceptance rate
select SUM(searches_got_quotes)*100/SUM(searches_for_quotes)
from trips_details


-- quote to booking rate
select SUM(otp_entered)*100/SUM(searches_got_quotes)
from trips_details


-- booking cancellation rate
select (count(tripid)-SUM(end_ride))*100.0/count(tripid)
from trips_details


-- conversion rate
select SUM(end_ride)*100.0/count(tripid)
from trips_details



-- which areas got highest successful_trips in each duration
with cte as (select duration,loc_from,COUNT(*) as number_of_trips
			from successful_trips
			group by duration,loc_from
			),
cte2 as (select *,rank() over (partition by duration order by number_of_trips desc) as rnk
from cte )
select * 
from cte2
where rnk=1

or 

with cte as (select duration,loc_from,COUNT(*) as number_of_trips,rank() over (partition by duration order by count(*) desc) as rnk
			from successful_trips
			group by duration,loc_from
			)
select *
from cte
where rnk=1


-- which area got the highest fares, cancellations
--area with max fare
with cte as (select loc_from,SUM(fare) as total_fares,rank() over(order by sum(fare) desc) as rnk
			from successful_trips
			group by loc_from)
select *
from cte 
where rnk=1
--area with max customer cancellation
with cte as (select loc_from,count(*)-sum(customer_not_cancelled) as cancelled_by_customer,rank() over(order by count(*)-sum(customer_not_cancelled) desc) as rnk
			from trips_details
			group by loc_from)
select *
from cte 
where rnk=1
--area with max driver cancellation
with cte as (select loc_from,count(*)-sum(driver_not_cancelled) as cancelled_by_driver,rank() over(order by count(*)-sum(driver_not_cancelled) desc) as rnk
			from trips_details
			group by loc_from)
select *
from cte 
where rnk=1
--area with max total cancellation
with cte as (select loc_from,count(*)-sum(otp_entered) as cancelled_by_customer,rank() over(order by count(*)-sum(otp_entered) desc) as rnk
			from trips_details
			group by loc_from)
select *
from cte 
where rnk=1


-- which duration got the highest fares
with cte as (select duration,sum(fare) as total_fare,rank() over(order by sum(fare) desc) as rnk
			from successful_trips
			group by duration)
select *
from cte 
where rnk=1