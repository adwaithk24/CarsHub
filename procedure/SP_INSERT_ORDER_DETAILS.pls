create or replace procedure sp_insert_order_details (
pi_customer_id ORDERS.CUSTOMER_ID%type,
pi_pickup_Date_time ORDERS.PICKUP_DATE_TIME%type,
pi_drop_Date_time ORDERS.DROP_DATE_TIME%type,
pi_pickup_location ORDERS.PICKUP_LOCATION%type,
pi_drop_location ORDERS.DROP_LOCATION%type,
pi_vehicle_id ORDERS.VEHICLE_ID%type
) as
v_card_id card_details.card_id%type:=0;
v_vehicle_id_count NUMBER:=0;
v_customer_status customers.user_Status%type;
v_customer_count number:=0;
v_card_id_count number;
v_store_id number:=0;
e_no_vehicles exception;
e_no_card exception;
e_inactive_customer exception;
e_customer_not_found exception;
e_wrong_pickup_location exception;
e_wrong_pickup_time exception;
    BEGIN
        select count(*) into v_customer_count from customers where customer_id=pi_customer_id;
        select count(card_id) into v_card_id_count from card_details where customer_id=pi_CUSTOMER_ID;
        select count(user_status) into v_customer_status from customers where customer_id=pi_customer_id and lower(user_status)='inactive';
        select count(store_id) into v_store_id from store_location where store_id in (pi_pickup_location,pi_drop_location);
		select count(v.vehicle_id) into v_vehicle_id_count
		from vehicles v where lower(v.vehicle_status) = 'available' and v.store_id= pi_PICKUP_LOCATION and v.vehicle_id=pi_vehicle_id and v.vehicle_id not in (select vehicle_id from orders 
		where pickup_date_time < pi_DROP_DATE_TIME and drop_date_time > pi_PICKUP_DATE_TIME and order_status!= 'cancelled');
        dbms_output.put_line(v_vehicle_id_count); 
    if v_customer_count=0 THEN
        raise e_customer_not_found ;
        elsif v_customer_status>0 THEN
        raise e_inactive_customer;
        elsif v_store_id=0 then
        raise e_wrong_pickup_location;
        elsif v_vehicle_id_count = 0 THEN
        RAISE e_no_vehicles;
        elsif v_card_id_count =0 then
        raise e_no_card;
        elsif trunc(pi_pickup_Date_time)>trunc(pi_drop_date_time) then
        raise e_wrong_pickup_time;
    ELSE
        insert into orders values (s_order_id.nextval,
		pi_CUSTOMER_ID,
		pi_PICKUP_DATE_TIME,
		pi_DROP_DATE_TIME,
		pi_PICKUP_LOCATION,
		pi_DROP_LOCATION,
		pi_VEHICLE_ID,
		(select card_id from card_details where customer_id=pi_CUSTOMER_ID and rownum=1),
		'confirmed',
        (SELECT ((trunc(pi_drop_Date_time) - trunc(pi_pickup_Date_time))*24* v.base_cost)+(extract(hour from pi_drop_Date_time - pi_pickup_Date_time )*v.base_cost) as total_amount
from vehicles v where v.vehicle_id = pi_vehicle_id),
		'NA');
        commit;
        dbms_output.put_line('Order placed');        
    END IF;

EXCEPTION
    WHEN e_no_vehicles THEN
        DBMS_OUTPUT.PUT_LINE('No Vehicles Available for this location, Please select a different vehicle');
    when e_inactive_customer then
    DBMS_OUTPUT.PUT_LINE('Please complete the pending transaction');
    when e_no_card then
    DBMS_OUTPUT.PUT_LINE('Please add Card details to book a car');
    when e_customer_not_found then
    DBMS_OUTPUT.PUT_LINE('Please enter a valid customer id');
    when e_wrong_pickup_location then
    DBMS_OUTPUT.PUT_LINE('Please enter a valid pickup/drop location');
    when e_wrong_pickup_time then 
    DBMS_OUTPUT.PUT_LINE('Please enter a valid pickup/drop time');
    
commit;
end sp_insert_order_details;