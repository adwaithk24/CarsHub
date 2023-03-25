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

--VEHICLES
CREATE TABLE Vehicles ( 
  vehicle_id number(10) CONSTRAINT vehicle_id PRIMARY KEY, 
  vehicle_type varchar2(255) NOT NULL, 
  vehicle_manufacturer varchar2(255) NOT NULL, 
  vehicle_model varchar2(255) NOT NULL, 
  chasis_no varchar2(255) NOT NULL Unique, 
  engine_no varchar2(255) NOT NULL Unique, 
  vehicle_location varchar2(255) NOT NULL, 
  vehicle_owner varchar2(255) NOT NULL, 
  base_cost number(9,2) NOT NULL, 
  purchase_date date NOT NULL, 
  vehicle_status varchar2(255) Default ON NULL 'Available', 
  vehicle_no varchar2(255) NOT NULL Unique, 
  store_id number(10) NOT NULL,
     constraint vehicle_status_flag_chk CHECK (vehicle_status in ('Available','Unavailable'))
); 

--CAR_HEALTH
CREATE TABLE Car_Health ( 
  car_health_id number(10) CONSTRAINT car_health_id PRIMARY KEY, 
  vehicle_id number(10) NOT NULL Unique, 
  last_service_date date , 
  next_service_date date NOT NULL, 
  health_status varchar2(255) Default ON NULL 'OKAY', 
  renewal_date date NOT NULL, 
  insurance_type varchar2(255) Default ON NULL 'GENERAL', 
  insurance_no number(15) NOT NULL Unique, 
  check_engine_oil number(1) Default ON NULL 0 , 
  check_tier_pressure number(1) Default ON NULL 0 , 
  check_air_filter number(1) Default ON NULL 0 , 
  employee_id number(10) NOT NULL, 
  last_update_date_time timestamp NOT NULL,
    CONSTRAINT check_engine_oil_flag_chk CHECK (check_engine_oil in (0, 1)),
    CONSTRAINT check_tier_pressure_flag_chk CHECK (check_tier_pressure in (0, 1)),
    CONSTRAINT check_air_filter_flag_chk CHECK (check_air_filter in (0, 1)),
    CONSTRAINT health_status_flag_chk CHECK (health_status in ('OKAY','NOT OKAY')),
    CONSTRAINT health_id_chk FOREIGN KEY(car_health_id) REFERENCES Vehicles(vehicle_id)
);

--STORE LOCATION

--EMPLOYEES
CREATE TABLE Employees ( 
  employee_id number(10) CONSTRAINT employee_id PRIMARY KEY , 
  first_name varchar2(255) NOT NULL , 
  last_name varchar2(255) NOT NULL, 
  ssn_no varchar2(255) NOT NULL Unique, 
  designation varchar2(255) NOT NULL, 
  phone_no number(13) NOT NULL Unique, 
  email_id varchar2(255) NOT NULL Unique, 
  store_id number(10) NOT NULL, 
  address_line_1 varchar2(255) NOT NULL, 
  address_line_2 varchar2(255) , 
  city varchar2(255) NOT NULL, 
  state varchar2(255) NOT NULL, 
  country varchar2(255) NOT NULL, 
  zip_code number(6) NOT NULL, 
  manager_id number(10) NOT NULL, 
  salary number(9,2) , 
  date_of_joining date, 
    CONSTRAINT manager_id_chk FOREIGN KEY(employee_id) REFERENCES Employees(employee_id),
    CONSTRAINT email_id_chk CHECK (email_id like('%@%.%')),
    CONSTRAINT phone_no CHECK (phone_no BETWEEN 1111111111 AND 9999999999) ENABLE
); 

--CUSTOMERS


--CARD_DETAILS


--ORDERS
CREATE TABLE Orders ( 
  order_id number(10) PRIMARY KEY, 
  customer_id number(10) NOT NULL, 
  pickup_date_time timestamp NOT NULL, 
  drop_date_time timestamp NOT NULL, 
  pickup_location varchar2(255) NOT NULL, 
  drop_location varchar2(255) NOT NULL, 
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
  current_location varchar2(255) NOT NULL, 
  tracking_status varchar2(255) NOT NULL, 
  order_id number(10) NOT NULL, 
  tracking_end_date_time timestamp NOT NULL, 
  last_update_date_time timestamp NOT NULL,
  Constraint tracking_status check(tracking_status in ('in_progress','completed')),
  CONSTRAINT order_id_fk FOREIGN KEY(order_id) REFERENCES orders(order_id)
);


