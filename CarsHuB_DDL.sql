--CLEANUP SCRIPT
set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (select 'TRACKING' table_name from dual union all
             select 'ORDERS' table_name from dual union all
             select 'CARD_DETAILS' table_name from dual union all
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
CREATE TABLE VEHICLES ( 
  vehicle_id number(10) PRIMARY KEY, 
  vehicle_type varchar2(255) NOT NULL, 
  vehicle_manufacturer varchar2(255) NOT NULL, 
  vehicle_model varchar2(255) NOT NULL, 
  vehicle_no varchar2(255) NOT NULL Unique, 
  chasis_no varchar2(255) NOT NULL Unique, 
  engine_no varchar2(255) NOT NULL Unique, 
  vehicle_location varchar2(255) NOT NULL, 
  vehicle_owner varchar2(255) NOT NULL, 
  base_cost number(9,2) NOT NULL, 
  purchase_date date NOT NULL, 
  vehicle_status varchar2(255) Default ON NULL 'available', 
  store_id number(10) NOT NULL,
     CONSTRAINT c_vehicle_type CHECK (vehicle_type in ('sedan','hactchback','convertible','coupe','suv')) ENABLE,
	 CONSTRAINT c_vehicle_no CHECK (REGEXP_LIKE(vehicle_no, '^[[:alnum:][:space:]\-\'']+$')) ENABLE, CHECK (length(vehicle_no)=20) ENABLE,
     CONSTRAINT c_chasis_no CHECK (REGEXP_LIKE(chasis_no, '^[[:alnum:][:space:]\-\'']+$')) ENABLE, CHECK (length(chasis_no)=12) ENABLE,
	 CONSTRAINT c_engine_no CHECK (REGEXP_LIKE(engine_no, '^[[:alnum:][:space:]\-\'']+$')) ENABLE, CHECK (length(engine_no)=8) ENABLE,
	 CONSTRAINT c_vehicle_status CHECK (vehicle_status in ('available','unavailable')) ENABLE
);

--CAR_HEALTH
CREATE TABLE CAR_HEALTH ( 
  car_health_id number(10) PRIMARY KEY, 
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
    CONSTRAINT c_engine_oil_flag CHECK (check_engine_oil in (0, 1)) ENABLE,
    CONSTRAINT c_check_tier_pressure_flag CHECK (check_tier_pressure in (0, 1)) ENABLE,
    CONSTRAINT c_check_air_filter_flag CHECK (check_air_filter in (0, 1)) ENABLE,
    CONSTRAINT c_health_status CHECK (health_status in ('okay','not okay')) ENABLE,
	CONSTRAINT c_insurance_type CHECK (insurance_type in ('FullCoverage','Collision','General','InjuryProtection','Comprehensive')) ENABLE,
	CONSTRAINT c_service_date CHECK (next_service_date>last_service_date),
    CONSTRAINT c_health_id_fk FOREIGN KEY(car_health_id) REFERENCES VEHICLES(vehicle_id)
);

--STORE LOCATION
CREATE TABLE store_location ( 
  store_id number(10) PRIMARY KEY, 
  address_line_1 varchar2(255) NOT NULL, 
  address_line_2 varchar2(255) , 
  city varchar2(255) NOT NULL, 
  state varchar2(255) NOT NULL, 
  country varchar2(255) NOT NULL, 
  zip_code number(6) NOT NULL, 
  store_name varchar2(255) NOT NULL Unique, 
  store_location varchar2(255) NOT NULL Unique
); 

--EMPLOYEES
CREATE TABLE Employees ( 
  employee_id number(10) PRIMARY KEY , 
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
    CONSTRAINT c_manager_id_fk FOREIGN KEY(employee_id) REFERENCES EMPLOYEES(employee_id),
    CONSTRAINT c_email_id_emp CHECK (email_id like('%@%.%')),
    CONSTRAINT c_phone_no_emp CHECK (phone_no BETWEEN 1111111111 AND 9999999999) ENABLE,
    CONSTRAINT c_ssn_no CHECK (ssn_no BETWEEN 100000001 AND 999999999) ENABLE , CHECK (REGEXP_LIKE(ssn_no, '^[[:alnum:][:space:]\-\'']+$')) ENABLE, CHECK (length(ssn_no)=9) ENABLE,
    CONSTRAINT c_designation CHECK (designation in ('manager','employee')) ENABLE
); 

--CUSTOMERS
CREATE TABLE CUSTOMERS (
  customer_id number(10) PRIMARY KEY, 
  first_name varchar2(255) NOT NULL, 
  last_name varchar2(255) NOT NULL, 
  email_id varchar2(255) NOT NULL Unique, 
  phone_no number(13) NOT NULL Unique, 
  user_status varchar2(10) default on NULL 'active', 
  date_of_birth date, 
  gender varchar2(255), 
  license_no varchar2(20) NOT NULL Unique,
  address_line_1 varchar2(255) NOT NULL, 
  address_line_2 varchar2(255), 
  city varchar2(255) NOT NULL, 
  state varchar2(255) NOT NULL, 
  country varchar2(255) NOT NULL, 
  zip_code number(6) NOT NULL,
  CONSTRAINT c_user_status CHECK (user_status in ('active','inactive')) ENABLE,
  CONSTRAINT c_email_id CHECK (email_id like ('%@%.%')) ENABLE,
  CONSTRAINT c_phone_no CHECK (phone_no BETWEEN 1111111111 AND 9999999999) ENABLE,
  CONSTRAINT c_license_no CHECK (length(license_no)=10) ENABLE,
  CONSTRAINT c_date_of_birth CHECK (date_of_birth not between to_date('01-01-2002','dd-mm-yyyy') and to_date('31-12-2023','dd-mm-yyyy')) ENABLE
); 

--CARD_DETAILS
CREATE TABLE CARD_DETAILS (   
  card_id number(10) PRIMARY KEY,   
  customer_id number(10) NOT NULL,   
  card_no varchar2(16) NOT NULL Unique,  
  card_name varchar2(20) NOT NULL , 
  CONSTRAINT c_card_no CHECK ((card_no BETWEEN 1111111111111111 AND 9999999999999999)) , CHECK (REGEXP_LIKE(card_no, '^[[:alnum:][:space:]\-\'']+$')) ENABLE,
  CONSTRAINT c_customer_id_fk FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)  
); 

--ORDERS
CREATE TABLE ORDERS ( 
  order_id number(10) PRIMARY KEY, 
  customer_id number(10) NOT NULL, 
  pickup_date_time timestamp NOT NULL, 
  drop_date_time timestamp NOT NULL, 
  pickup_location varchar2(255) NOT NULL, 
  drop_location varchar2(255) NOT NULL, 
  vehicle_id number(10) NOT NULL, 
  card_id number(10) NOT NULL, 
  order_status varchar2(255) NOT NULL, 
  bill_amount number(9,2) NOT NULL, 
  payment_status varchar2(255),
  CONSTRAINT c_order_status CHECK(order_status in ('confirmed','in_progress','completed','cancelled')),
  CONSTRAINT c_payment_status CHECK (payment_status in ('completed','failed','NA')),
  CONSTRAINT c_car_interval CHECK (pickup_date_time < drop_date_time),
  CONSTRAINT C_cust_id_fk FOREIGN KEY(customer_id) REFERENCES CUSTOMERS(customer_id),
  CONSTRAINT C_vehicle_id_fk FOREIGN KEY(vehicle_id) REFERENCES VEHICLES(vehicle_id),
  CONSTRAINT C_card_id_fk FOREIGN KEY(card_id) REFERENCES CARD_DETAILS(card_id)
); 

--TRACKING
CREATE TABLE TRACKING ( 
  tracking_id number(10) PRIMARY KEY, 
  current_location varchar2(255) NOT NULL, 
  tracking_status varchar2(255) NOT NULL, 
  order_id number(10) NOT NULL, 
  tracking_end_date_time timestamp NOT NULL, 
  last_update_date_time timestamp NOT NULL,
  CONSTRAINT c_tracking_status CHECK(tracking_status in ('in_progress','completed')),
  CONSTRAINT c_order_id_fk FOREIGN KEY(order_id) REFERENCES ORDERS(order_id)
);