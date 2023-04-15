create or replace procedure sp_tracking_insert(
pi_current_location tracking.current_location%type,
pi_order_id orders.order_id%type) as
v_order_id number;
v_order_id_count number;
v_order_status orders.order_status%type;
e_no_order_id exception;
e_order_not_started exception;
e_order_completed exception;
e_order_cancelled exception;
begin
--select count(order_id) into v_order_id_count from orders where order_id=pi_order_id and lower(order_status) = 'in_progress';
select order_status into v_order_status from orders where order_id=pi_order_id;
case --v_order_status
when lower(v_order_status) = 'confirmed' then
raise e_order_not_started;
when lower(v_order_status) = 'completed' then
raise e_order_completed;
when lower(v_order_status) = 'cancelled' then
raise e_order_cancelled;
when lower(v_order_status)  = 'in_progress' then 
insert into tracking values(s_tracking_id.nextval,pi_current_location,'in_progress',pi_order_id,
(select drop_date_time from orders where order_id=pi_order_id),current_timestamp);
DBMS_OUTPUT.PUT_LINE('vehicle tracking insert done');
else 
raise e_no_order_id;
end case;
commit;
exception when e_no_order_id
then  DBMS_OUTPUT.PUT_LINE('Order not available');
when e_order_not_started
then  DBMS_OUTPUT.PUT_LINE('Order not started');
when e_order_completed
then  DBMS_OUTPUT.PUT_LINE('Order completed');
when e_order_cancelled
then  DBMS_OUTPUT.PUT_LINE('Order cancelled');
end sp_tracking_insert;
--end sp_available_cars;