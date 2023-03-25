--CLEANUP SCRIPT
set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (select 'TRACKING' table_name from dual union all
             select 'ORDERS' table_name from dual union all
             select 'CARD_DETAIILS' table_name from dual union all
             select 'CUSTOMERS' table_name from dual union all
             select 'EMPLOYEES' table_name from dual union all
             select 'STORE_LOCATION' table_name from dual union all
             select 'CAR_HEALTH' table_name from dual union all
             select 'VEHICLES' table_name from dual 
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name;
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception 
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

--CREATE VEHICLES

--CAR_HEALTH

--STORE LOCATION

--EMPLOYEES

--CUSTOMERS


--CARD_DETAILS


--ORDERS
CREATE TABLE Orders ( 
  order_id number(10) PRIMARY KEY, 
  customer_id number(10) NOT NULL, 
  pickup_date_time timestamp NOT NULL, 
  drop_date_time timestamp NOT NULL, 
  pickup_location_name varchar2(50) NOT NULL, 
  drop_location_name varchar2(50) NOT NULL, 
  vehicle_id number(10) NOT NULL, 
  card_id number(10) NOT NULL, 
  order_status varchar2(10) NOT NULL, 
  bill_amount number(9,2) NOT NULL, 
  payment_status varchar2(10),
  Constraint order_status check(order_status in ('confirmed','in_progress','completed')),
  Constraint payment_status check (payment_status in ('completed','failed','NA')),
  constraint car_interval check (pickup_date_time<drop_date_time)
  ,CONSTRAINT cust_id_fk FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
  ,CONSTRAINT vehicle_id_fk FOREIGN KEY(vehicle_id) REFERENCES vehicles(vehicle_id)
  ,CONSTRAINT card_id_fk FOREIGN KEY(card_id) REFERENCES card_details(card_id)
); 

--TRACKING

CREATE TABLE Tracking ( 
  tracking_id number(10) PRIMARY KEY, 
  current_location varchar2(50) NOT NULL, 
  tracking_status varchar2(10) NOT NULL, 
  order_id number(10) NOT NULL, 
  tracking_end_date_time timestamp NOT NULL, 
  last_update_date_time timestamp NOT NULL,
  Constraint tracking_status check(tracking_status in ('in_progress','completed')),
  CONSTRAINT order_id_fk FOREIGN KEY(order_id) REFERENCES orders(order_id)
);


