---Views
CREATE OR REPLACE VIEW car_availability AS
select v.vehicle_type,v.vehicle_manufacturer,v.vehicle_model,v.base_cost 
from vehicles v where v.vehicle_status = 'Active' and v.store_id=2 and v.vehicle_id not in (select vehicle_id from orders 
where (pickup_date_time < '12-13-2022' and drop_date_time > '12-10-2022') and order_status!= 'cancelled');


select * from car_availability;

CREATE OR REPLACE VIEW user_preference AS
select v.vehicle_type,v.vehicle_model,((sysdate - c.date_of_birth) / 365) as age,c.gender,
CASE
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (12,1,2) THEN 'winter'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (3,4,5) THEN 'spring'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (6,7,8) THEN 'summer'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (9,10,11) THEN 'fall'
END as season,
count(o.order_id) as number_of_bookings
from vehicles v join orders o on v.vehicle_id=o.vehicle_id 
join customers c on c.customer_id=o.order_id 
group by ((sysdate - c.date_of_birth) / 365),c.gender,
CASE
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (12,1,2) THEN 'winter'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (3,4,5) THEN 'spring'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (6,7,8) THEN 'summer'
    WHEN EXTRACT(MONTH FROM o.pickup_date_time) IN (9,10,11) THEN 'fall'
END,
v.vehicle_type,v.vehicle_model;

select * from user_preference;

CREATE OR REPLACE VIEW store_employees AS
SELECT e1.store_id,e1.employee_id as employeeid, e1.first_name ||e1.last_name as EmployeeName, 
       e1.employee_id as ManagerId, e2.first_name ||e2.last_name AS ManagerName
FROM   employees e1
       JOIN employees e2
       ON e1.employee_id = e1.employee_id ;

select * from store_employees;


CREATE OR REPLACE VIEW customer_order_history AS
select c.customer_id,c.first_name,c.last_name,o.order_id, 
v.vehicle_model, pl.store_name as pickuplocation,dl.store_name as droplocation, 
o.pickup_date_time,o.drop_date_time, o.bill_amount,o.payment_status from
(select s.store_name from store_location s join orders o on o.pickup_location=s.store_id) pl,
(select s.store_name from store_location s join orders o on o.drop_location=s.store_id) dl,
customers c join orders o on c.customer_id=o.customer_id 
join vehicles v on o.vehicle_id=v.vehicle_id 
where c.customer_id = 2;

select * from customer_order_history;

CREATE OR REPLACE VIEW tracking_view AS
select o.order_id, o.customer_id, o.pickup_date_time, o.drop_date_time, o.pickup_location, o.drop_location, o.vehicle_id, t.current_location 
from orders o join tracking t on o.order_id=t.order_id where o.order_status='in_progress';

select * from tracking_view;

CREATE OR REPLACE VIEW delayed_orders AS
select o.order_id, o. customer_id, t.tracking_id, t.current_location, t.tracking_status, t.last_update_date_time 
from orders o join tracking t on o.order_id=t.tracking_id where o.order_status='in_progress' and t.last_update_date_time > o.drop_date_time;

select * from delayed_orders;



