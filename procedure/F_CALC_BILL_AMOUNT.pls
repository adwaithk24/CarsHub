create or replace FUNCTION f_calc_bill_amount(bill_order_id IN NUMBER) 
   RETURN NUMBER 
   is total_amount NUMBER(11,2);
BEGIN 
   SELECT ((trunc(o.drop_date_time) - trunc(o.pickup_date_time ))*24* v.base_cost)+(extract(hour from o.drop_date_time - o.pickup_date_time )*v.base_cost) as total_amount 
   into total_amount
from vehicles v join orders o on v.vehicle_id = o.vehicle_id where o.order_id = bill_order_id ;
RETURN(total_amount); 
 END;
