create database zomato;
use zomato;
##first we create a new database here 

CREATE TABLE goldusers_signup(userid integer,
gold_signup_date date);
select * from goldusers_signup;
## here we create a table using "CREATE TABLE" commmand.

INSERT INTO goldusers_signup (userid,gold_signup_date) 
VALUES (1,'2017-09-22'), 
(3,'2017-04-21'); 
## insert data into created table.

drop table if exists users; 
CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) VALUES (1,'2014-09-02'), (2,'2015-01-15'), (3,'2014-11-04'); 

drop table if exists sales; 
CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) VALUES (1,'2017-04-09',2), (3,'2019-12-18',1), (2,'2020-07-22',3), (1,'2019-10-23',2), (1,'2018-03-19',3), (3,'2016-12-20',2), (1,'2016-11-09',1), (1,'2016-05-20',3), (2,'2017-09-24',1), (1,'2017-03-11-',2), (1,'2016-03-11',1), (3,'2016-11-10',1), (3,'2017-12-07',2), (3,'2016-12-15',2), (2,'2017-11-08',2), (2,'2018-09-10-',3); 
 select * from sales;
 
drop table if exists product; 
CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) VALUES (1,'p1',980), (2,'p2',870), (3,'p3',330); 
select * from sales; 
select * from product; 
select * from goldusers_signup; 
select * from users;

##lets solve the question using MySql.
# Q1: What is the total amount each customer spent on Zomato?

select 
s.userid, sum(p.price) as spent_amount
from sales s
inner join product p on  s.product_id = p.product_id
group by 1;

# Q2: How many days each customer visited Zomato?

select userid , count(distinct created_date) as "days_visit"
from sales
group by userid;

# Q:3: What is the first product purchased by each of the customer?

select * from 
(select *,
rank() over(partition by userid order by created_date) as `rank`
from sales) a where `rank` = 1

# Q4: what is most purchased item on the menu and how many times was it purchased by all the customer?

select userid, count(product_id) from sales 
where product_id = 
(select product_id 
from sales
group by product_id
order by count(product_id) desc
limit 1) 
group by userid;


# Q5: Which item was most favorate from each of the customer?
select * from
(select *,
rank() over(partition by userid order by cnt desc)`rank` from
(select userid,product_id, count(product_id) cnt from sales group by 1,2)a)
b where `rank` = 1


# Q6: which item was first purchased by the customer after they become a member?
select* from (
select a.*, rank() over(partition by userid order by created_date)`rank` from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date >= gold_signup_date) 
as a) 
b where `rank` = 1

# Q7: Which item was purchased  just before the customer become a member?
select* from (
select a.*, rank() over(partition by userid order by created_date desc)`rank` from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date <= gold_signup_date) 
as a) 
b where `rank` = 1


# Q8: What is the total order and amount spent for each member before they become a member?
select userid, count(created_date) as order_purchased, sum(price)as total_amount_spent from
(select a.*, b.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date
from sales as s
inner join goldusers_signup as g 
on s.userid =g.userid and created_date < gold_signup_date)a 
inner join product b 
on a.product_id = b.product_id)c
group by userid

# Q9:  If buying each products generates points for eg 5rs = 2 Zomato points and
each product has diferent purchasinng points for eg. p1 5rs=1 Zomato point, for p2 
10rs=5 Zomato point and p3 5rs=1 Zomato point
Calculate points collect by each customer and for which product most points has been given till now>
Ans.
select userid, sum(total_points) * 2.5 as total_points_earned from 
(select c.*, amount/ points as total_points from
(select b.*, case when product_id = 1 then 5
when product_id = 2 then 2
when product_id=3 then 5 
else 0 end as  points from
(select a.userid, a.product_id, sum(price) as amount from
(select s.*, p.price
from sales as s
inner join product as p
on s.product_id = p.product_id)a
group by userid, product_id)b)c)d
group by userid




# Q10: In the first one year after a customer joins the gold program (including their join date) 
irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent 
who earned more 1 or 3 and what was their points earnings in thier first yr?
1 zp=2rs
0.5 zp 1rs
select c.*,d.price * 0.5 total_points_earned from
(select a.userid, a.created_date,a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and 
DATEDIFF(CREATED_DATE,Gold_signup_date)<=365)c inner join product d on c.product_id=d.product_id;




