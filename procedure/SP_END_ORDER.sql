create or replace procedure sp_end_order (
pi_order_id number,
pi_end_order number,
pi_current_location tracking.current_location%type
) as 
v_store_location store_location.store_location%type;
v_drop_date_time orders.drop_date_time%type;
v_tracking_end_time tracking.tracking_end_date_time%type;
v_store_id number;
v_vehicle_id number;
v_tracking_count number;

BEGIN

select count(*) into v_tracking_count from tracking where order_id=pi_order_id;
if v_tracking_count =0 then

	select store_location into v_store_location from store_location where store_id = (select drop_location from orders where order_id=pi_order_id);
	select store_id into v_store_id from store_location where store_location=v_store_location;
	select drop_date_time into v_drop_date_time from orders where order_id=pi_order_id;
    select vehicle_id into v_vehicle_id from orders where order_id=pi_order_id;
        if v_store_location = pi_current_location then
			case when pi_end_order =1 then
			update tracking set
				tracking_end_date_time= current_timestamp,
				tracking_status = 'completed'
				where order_id=pi_order_id;
			select tracking_end_date_time into v_tracking_end_time from tracking where order_id = pi_order_id and rownum=1;
			if v_drop_date_time>= v_tracking_end_time then
			update orders set 
				order_status='completed' where order_id = pi_order_id;
			update tracking set
				tracking_status='completed' where order_id = pi_order_id;
				update vehicles set
                store_id = v_store_id where vehicle_id = v_vehicle_id;
			else
				update orders set
				drop_date_time = v_tracking_end_time,
				order_status='completed',
				bill_amount=f_calc_bill_amount(pi_order_id) where order_id = pi_order_id;
				update tracking set
				tracking_status='completed' where order_id = pi_order_id;
			end if;

			when pi_end_order = 0 then
			DBMS_OUTPUT.PUT_LINE('Tracking in progress');
			else 
			DBMS_OUTPUT.PUT_LINE('enter a valid end_order_input: 1- to end order, 0- to continue');
			end case;
		else
		DBMS_OUTPUT.PUT_LINE('Please drop the car at destination store');
		end if;  
    else 
    DBMS_OUTPUT.PUT_LINE('Order has not been started yet');
    end if;
commit;

end sp_end_order;