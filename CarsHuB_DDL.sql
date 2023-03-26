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
CREATE TABLE store_location ( 
  store_id number(10) constraint store_id primary key, 
  address_line_1 varchar2(255) NOT NULL, 
  address_line_2 varchar2(255) , 
  city varchar2(255) NOT NULL, 
  state varchar2(255) NOT NULL, 
  country varchar2(255) NOT NULL, 
  zip_code number(6) NOT NULL, 
  store_name varchar2(255) NOT NULL Unique, 
  store_location varchar2(20) NOT NULL
); 

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
CREATE TABLE customers (
  customer_id number(10) constraint customer_id primary key, 
  first_name varchar2(255) NOT NULL, 
  last_name varchar2(255) NOT NULL, 
  email_id varchar2(255) NOT NULL Unique, 
  phone_no number(13) NOT NULL Unique, 
  user_status varchar2(10) default on NULL 'active', 
  date_of_birth date, 
  gender varchar2(255), 
  address_line_1 varchar2(255) NOT NULL, 
  address_line_2 varchar2(255), 
  city varchar2(255) NOT NULL, 
  state varchar2(255) NOT NULL, 
  country varchar2(255) NOT NULL, 
  zip_code number(6) NOT NULL,
  constraint user_status_chk CHECK (user_status in ('active','inactive')),
  CONSTRAINT c_email_id_chk CHECK (email_id like ('%@%.%')),
  CONSTRAINT c_phone_no_chk CHECK (phone_no BETWEEN 1111111111 AND 9999999999) ENABLE
); 

--CARD_DETAILS
CREATE TABLE card_details (   
  card_id number(10) primary key,   
  customer_id number(10) NOT NULL,   
  card_no varchar2(16) NOT NULL Unique ,  
  card_name varchar2(20) NOT NULL, 
  CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),  
  CONSTRAINT check_card_number CHECK ((card_no BETWEEN 1111111111111111 AND 9999999999999999)) 
);   

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
  order_status varchar2(255) NOT NULL, 
  bill_amount number(9,2) NOT NULL, 
  payment_status varchar2(255),
  Constraint order_status check(order_status in ('confirmed','in_progress','completed','cancelled')),
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



--vehichle
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (1, 'Hatchback', 'Saab', '900', '70vXk902n6V', 'd6O18c9t', 'Forest Dale', 'Corissa', 43.78, to_date('2022-12-11','yyyy-mm-dd'), 'Unavailable', 'Q749Z4', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (2, 'Sedan', 'Dodge', 'Caravan', '364Pq17n7tp', '6391550b', 'Merrick', 'Fifi', 34.28, to_date('2022-10-22','yyyy-mm-dd'), 'Available', 'H268Y0', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (3, 'Coupe', 'Bentley', 'Continental Super', '79jgQ27E5Ua', 'Cbu24Y6r', 'Thackeray', 'Leigha', 36.08, to_date('2023-02-07','yyyy-mm-dd'), 'Available', 'P702J7', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (4, 'Sedan', 'Suzuki', 'SJ', '08xRT72MF8E', 'zdm78u5z', 'Eagan', 'Saba', 41.62, to_date('2021-11-08','yyyy-mm-dd'), 'Available', 'E252K1', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (5, 'SUV', 'Dodge', 'Caravan', '64t3X60GJ4L', 'FWR38J6q', 'Oriole', 'Dunc', 43.71, to_date('2021-11-08 ','yyyy-mm-dd'), 'Available', 'X422C9', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (6, 'Hatchback', 'Honda', 'Civic', '25OwE90Nod4', 'M1S30d1l', 'Walton', 'Ange', 40.14, to_date('2022-12-06','yyyy-mm-dd'), 'Available', 'O329V3', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (7, 'Coupe', 'GMC', 'Sierra 2500', '28EHb89QMsO', 'HoN00V3h', 'Independence', 'Kendell', 44.22, to_date('2022-04-16 ','yyyy-mm-dd'), 'Available', 'N964X3', 9);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (8, 'Convertible', 'Jeep', 'Wrangler', '81V8Q91FV99', '90r98g8N', 'Manitowish', 'Lynett', 44.44, to_date('2022-11-24','yyyy-mm-dd'), 'Unavailable', 'I994F9', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (9, 'SUV', 'Saturn', 'Aura', '22kAZ309Z5S', 'XiZ71B9W', 'Lerdahl', 'Joane', 40.33, to_date('2021-11-28 ','yyyy-mm-dd'), 'Available', 'Z656B3', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (10, 'SUV', 'Mitsubishi', '3000GT', '35Nbx72yV5B', 'q6q43l16', 'Atwood', 'Leena', 32.33, to_date('2023-01-17 ','yyyy-mm-dd'), 'Available', 'H257H5', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (11, 'Convertible', 'Mitsubishi', 'Eclipse', '94xOt01yR6Q', '0oa68B6M', 'Anhalt', 'Rodi', 32.69, to_date('2022-09-14 ','yyyy-mm-dd'), 'Unavailable', 'P318J6', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (12, 'Coupe', 'Mazda', 'CX-7', '74C1f84x6y6', 'SWv55E46', 'Westport', 'Royal', 40.09, to_date('2022-05-19 ','yyyy-mm-dd'), 'Unavailable', 'C280G1', 5);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (13, 'SUV', 'Porsche', 'Panamera', '76vxj37lB3t', 'Gd57335n', 'Mariners Cove', 'Mimi', 41.04, to_date('2022-01-28 ','yyyy-mm-dd'), 'Unavailable', 'A217R4', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (14, 'Sedan', 'Subaru', 'XT', '94GyN05c2VY', 'Q9015V4i', 'Eagle Crest', 'Darryl', 35.57, to_date('2022-09-24','yyyy-mm-dd'), 'Available', 'L986Z0', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (15, 'Coupe', 'Mitsubishi', 'Diamante', '293W269dkqm', 'ufz8040F', 'Cascade', 'Georgeanne', 28.58, to_date('2022-04-09 ','yyyy-mm-dd'), 'Available', 'U912I7', 10);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (16, 'Sedan', 'Mazda', 'B-Series', '08Mp82048S8', 'WqY65B7A', 'Delladonna', 'Wilmar', 42.17, to_date('2022-12-16 ','yyyy-mm-dd'), 'Unavailable', 'H050C3', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (17, 'Hatchback', 'Maserati', 'Quattroporte', '03eGb22zHmy', 'ckk90P5C', 'Westridge', 'Madelene', 25.57, to_date('2022-01-28 ','yyyy-mm-dd'), 'Available', 'G572P6', 9);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (18, 'Hatchback', 'Maserati', '430', '71Ioi375T29', 'rKR21V0f', 'Crescent Oaks', 'Jarrod', 43.79, to_date('2021-12-23','yyyy-mm-dd'), 'Available', 'A287J3', 10);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (19, 'Coupe', 'Chevrolet', 'Suburban 2500', '48VqE39KktC', 'JIY39V6b', 'Maryland', 'Hermie', 36.1, to_date('2022-04-16 ','yyyy-mm-dd'), 'Available', 'Z266B1', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (20, 'Sedan', 'Dodge', 'Dakota', '82lE637e8C9', 'Z2k98l5r', 'High Crossing', 'Allan', 41.22, to_date('2022-07-13 ','yyyy-mm-dd'), 'Available', 'L678A0', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (21, 'Coupe', 'Toyota', 'Celica', '91lMR39qwnS', 'EeF78D65', 'Mallory', 'Lindsey', 44.41, to_date('2022-03-16 ','yyyy-mm-dd'), 'Available', 'Q317B3', 10);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (22, 'Coupe', 'Mazda', 'Protege', '439ZO91CcZm', 'cII4380Y', 'Pine View', 'Timothea', 40.75, to_date('2022-05-20','yyyy-mm-dd'), 'Unavailable', 'R237O9', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (23, 'Hatchback', 'Pontiac', 'Vibe', '10sC836tiu9', '0fF13s6h', 'Sundown', 'Tibold', 40.48, to_date('2023-01-14 ','yyyy-mm-dd'), 'Available', 'N049B8', 5);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (24, 'Sedan', 'Hummer', 'H2', '25qmX76Fzui', '0Vn29Q10', 'Scoville', 'Jana', 35.97, to_date('2022-07-04','yyyy-mm-dd'), 'Available', 'Q788X6', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (25, 'Hatchback', 'Ford', 'Aerostar', '27f5h89JVv1', 'mfG17I4q', 'Hermina', 'Allyce', 42.29, to_date('2022-03-16 ','yyyy-mm-dd'), 'Available', 'B928I7', 10);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (26, 'Coupe', 'Mitsubishi', 'Pajero', '11iqk5065f6', 'DYt90k9e', 'Mandrake', 'Melania', 35.97, to_date('2022-05-05 ','yyyy-mm-dd'), 'Available', 'S523P6', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (27, 'Convertible', 'Lincoln', 'MKX', '44wLp41KcGX', 'AAn83n73', 'Corry', 'Idalina', 43.5, to_date('2023-02-03','yyyy-mm-dd'), 'Unavailable', 'O552Y8', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (28, 'SUV', 'GMC', 'Yukon XL 2500', '26Cbf57jb5P', 'KXZ5728s', 'Lerdahl', 'Norean', 35.26, to_date('2022-11-16','yyyy-mm-dd'), 'Unavailable', 'R513P7', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (29, 'Convertible', 'Mercury', 'Sable', '77e5p61obQ9', 'Cr711e3j', 'Kensington', 'Dolph', 33.85, to_date('2022-01-31','yyyy-mm-dd'), 'Available', 'X050D2', 5);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (30, 'SUV', 'Lincoln', 'Continental', '97L6O96JBfi', 'hwe80U7o', 'Harbort', 'Mayor', 43.49, to_date('2022-07-25 ','yyyy-mm-dd'), 'Unavailable', 'S069L0', 10);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (31, 'Sedan', 'Lotus', 'Esprit', '41CT9228Wy8', '9fC38T7d', 'Dennis', 'Abran', 42.82, to_date('2023-03-22','yyyy-mm-dd'), 'Available', 'Z531T9', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (32, 'Coupe', 'Chevrolet', 'Monte Carlo', '07M6X11oDJI', '9E711K36', 'Del Sol', 'Bernetta', 27.74, to_date('2022-06-09','yyyy-mm-dd'), 'Available', 'E222V4', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (33, 'Sedan', 'Ford', 'Thunderbird', '915tm02tJyF', '3bG36o76', 'Havey', 'Harmonie', 28.12, to_date('2022-06-27','yyyy-mm-dd'), 'Available', 'P557F3', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (34, 'Sedan', 'Scion', 'xD', '75Gpt45tl41', 'mhZ82R97', 'Superior', 'Cleon', 38.53, to_date('2022-08-31','yyyy-mm-dd') , 'Available', 'W880O6', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (35, 'Sedan', 'Lincoln', 'Navigator', '53NL347HFV6', 'feR2732p', 'Gateway', 'Kennie', 32.45, to_date('2022-12-06 ','yyyy-mm-dd'), 'Available', 'Z866J1', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (36, 'Hatchback', 'Hyundai', 'Equus', '10p0T89NczN', '63X30D3P', '4th', 'Barbette', 32.94, to_date('2022-06-07','yyyy-mm-dd'), 'Unavailable', 'T432E2', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (37, 'Sedan', 'BMW', 'M3', '99Rit617g2G', 'aoy90z1t', 'Claremont', 'Rasla', 33.82, to_date('2021-12-31','yyyy-mm-dd'), 'Available', 'N603I7', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (38, 'Convertible', 'Audi', 'A3', '37bw304Qoub', 'GeP08H7M', 'Merrick', 'Terese', 44.29, to_date('2022-04-09 ','yyyy-mm-dd'), 'Available', 'C065G3', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (39, 'Sedan', 'Dodge', 'Ram 1500', '83NHh47uAVJ', 'ZKF82H4U', 'Springview', 'Lissy', 28.08, to_date('2022-03-20 ','yyyy-mm-dd'), 'Available', 'Q417V9', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (40, 'Sedan', 'Pontiac', 'GTO', '88aeB60xzqN', 'yqn02L8L', 'Warbler', 'Dorothy', 28.87, to_date('2023-02-15','yyyy-mm-dd'), 'Unavailable', 'D761Q8', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (41, 'Coupe', 'GMC', 'Rally Wagon G3500', '01KAf59uiuM', 'SqG33z4J', 'Jenifer', 'Shea', 44.62, to_date('2023-03-16','yyyy-mm-dd'), 'Available', 'O912O4', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (42, 'Convertible', 'Volkswagen', 'Jetta', '38Qmo66p13o', '9YX32X8b', 'Donald', 'Carmon', 35.47, to_date('2022-09-15 ','yyyy-mm-dd'), 'Unavailable', 'N534R2', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (43, 'Sedan', 'Jeep', 'Grand Cherokee', '17a7h06VUVN', '15L82310', 'Mallory', 'Diarmid', 39.04, to_date('2021-08-27 ','yyyy-mm-dd'), 'Available', 'R668O3', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (44, 'Coupe', 'Acura', 'NSX', '390Bg40edJx', 'Flx97k91', 'Messerschmidt', 'Jarrad', 40.71, to_date('2022-02-20 ','yyyy-mm-dd'), 'Available', 'W112H6', 5);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (45, 'Convertible', 'Ferrari', '612 Scaglietti', '98Qbz606Vln', 'XGp02J1L', 'Mitchell', 'Melantha', 28.21, to_date('2022-08-02','yyyy-mm-dd'), 'Available', 'N530J9', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (46, 'Sedan', 'Chevrolet', 'Silverado 1500', '59hoS31Er3t', 'UFN9338m', 'Lakewood', 'Cchaddie', 35.2, to_date('2021-11-08 ','yyyy-mm-dd'), 'Available', 'Z530W6', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (47, 'SUV', 'Acura', 'Integra', '36H7t18ILBV', 'wY417L7b', 'Sutherland', 'Diane', 28.6, to_date('2021-11-12','yyyy-mm-dd'), 'Available', 'X754O8', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (48, 'Convertible', 'Mazda', 'Millenia', '33M3A01kmrl', 'Nfw10z8B', 'Chive', 'Eddie', 30.02, to_date('2022-03-04 ','yyyy-mm-dd'), 'Available', 'S710D0', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (49, 'Convertible', 'Buick', 'Century', '39kB184kQ03', 'Nu232o9e', 'Hanson', 'Ofelia', 40.43, to_date('2022-08-17','yyyy-mm-dd'), 'Available', 'G164Y3', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (50, 'SUV', 'Pontiac', 'Trans Sport', '57giK58XLtO', 'oQG38A2q', 'Spenser', 'Udall', 38.28, to_date('2022-04-12','yyyy-mm-dd'), 'Available', 'E841J1', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (51, 'Convertible', 'Ford', 'Contour', '61kFw39tAi5', 'Eat2694D', 'Dorton', 'Rees', 29.56, to_date('2022-09-08 ','yyyy-mm-dd'), 'Available', 'D142B0', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (52, 'Hatchback', 'Audi', 'TT', '69uM207lB6Z', 'WeK23O4D', 'Talmadge', 'Clerc', 39.19, to_date('2023-02-25','yyyy-mm-dd'), 'Available', 'F065J6', 8);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (53, 'SUV', 'Porsche', '968', '221Fh28WsOZ', 'TbG52i6e', 'Schmedeman', 'Karol', 28.92, to_date('2023-01-02','yyyy-mm-dd'), 'Available', 'L919S6', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (54, 'Hatchback', 'Bentley', 'Continental Flying Spur', '31l2Q83GaSj', '1uh2581m', 'Arrowood', 'Sancho', 38.94, to_date('2022-04-06 ','yyyy-mm-dd'), 'Available', 'Y622P3', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (55, 'Coupe', 'Ford', 'Club Wagon', '56J46943RJ5', 'JgU63E6w', 'Fordem', 'Dora', 43.68, to_date('2022-06-10 ','yyyy-mm-dd'), 'Available', 'K841F3', 7);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (56, 'Sedan', 'Mazda', 'GLC', '195Vl39DYrL', '8AE1364w', 'Comanche', 'Delphinia', 36.76, to_date('2022-07-12 ','yyyy-mm-dd'), 'Available', 'Y082I2', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (57, 'SUV', 'Mercedes-Benz', 'SL-Class', '80BsW70FTeA', 'rPz50l6M', 'Mitchell', 'Lucian', 28.43, to_date('2021-10-12 ','yyyy-mm-dd'), 'Available', 'F242C3', 9);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (58, 'Convertible', 'Dodge', 'Neon', '53xob743jSB', 'lKQ52F0Y', 'Arapahoe', 'Mattie', 42.1, to_date('2021-08-29','yyyy-mm-dd'), 'Available', 'Y244Q0', 5);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (59, 'Convertible', 'Pontiac', 'Grand Prix', '75Nuu40hN0C', 'HIK7970o', 'Maryland', 'Judie', 30.43, to_date('2022-11-27 ','yyyy-mm-dd'), 'Available', 'D494Y9', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (60, 'Convertible', 'Mercedes-Benz', 'S-Class', '0389J51ziUM', 'SSV87o6R', 'Mallory', 'Maddie', 26.66, to_date('2023-03-16','yyyy-mm-dd'), 'Available', 'F008Y6', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (61, 'Hatchback', 'Pontiac', 'Grand Am', '65k8D63i85U', 'xXe92Y9Y', 'Lake View', 'Allissa', 39.13, to_date('2022-04-26','yyyy-mm-dd'), 'Available', 'F952U8', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (62, 'SUV', 'Mazda', 'MX-5', '249uY55sIHH', 'wRi93o1I', 'Northview', 'Cherise', 30.59, to_date('2022-02-04','yyyy-mm-dd'), 'Available', 'H863M0', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (63, 'Coupe', 'BMW', 'Z3', '01qXg84BxBQ', 'JQF51O68', 'Aberg', 'Eden', 38.19, to_date('2023-03-01','yyyy-mm-dd'), 'Available', 'H580W4', 9);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (64, 'Hatchback', 'Eagle', 'Vision', '92NnV32KgPP', 'xh621b7n', 'Onsgard', 'Taddeo', 31.95, to_date('2021-11-26 ','yyyy-mm-dd'), 'Available', 'J870B8', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (65, 'SUV', 'GMC', 'Yukon XL 2500', '17cuO59ykSW', 'xrO16L1g', 'Hintze', 'Towny', 42.82, to_date('2021-12-09','yyyy-mm-dd'), 'Available', 'N604A5', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (66, 'SUV', 'Chevrolet', 'G-Series G30', '43DXr877qtl', 'XG280m7M', 'Orin', 'Lizabeth', 42.32, to_date('2023-01-18 ','yyyy-mm-dd'), 'Available', 'T738C1', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (67, 'Hatchback', 'Audi', 'R8', '08jIt75OUR9', 'HN904N1t', 'Prairieview', 'Consuela', 40.13, to_date('2022-05-21','yyyy-mm-dd'), 'Available', 'E352B5', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (68, 'SUV', 'Toyota', 'Corolla', '97mE327pdHY', 'pvy00a0B', 'American', 'Lacee', 32.96, to_date('2022-01-17','yyyy-mm-dd'), 'Available', 'W554W0', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (69, 'SUV', 'Mercury', 'Grand Marquis', '994Yn34PlIf', 'yWV5598T', 'Kenwood', 'Gill', 31.07, to_date('2022-05-10','yyyy-mm-dd'), 'Available', 'P540E1', 6);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (70, 'Sedan', 'Audi', 'Allroad', '881Zf1214xU', '4m894z4h', 'Memorial', 'Padraic', 31.17, to_date('2021-10-30','yyyy-mm-dd'), 'Available', 'Q091I6', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (71, 'Convertible', 'Ford', 'GT500', '41MSV08jE8B', '7Ac73Y9A', 'Green', 'Daloris', 37.2, to_date('2021-09-25','yyyy-mm-dd'), 'Available', 'M785T1', 2);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (72, 'SUV', 'Isuzu', 'Rodeo', '70jVW84tDt0', 'bmp26o4S', '8th', 'Karon', 44.22, to_date('2022-06-12','yyyy-mm-dd'), 'Available', 'Z877S4', 4);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (73, 'Convertible', 'Mercedes-Benz', 'Sprinter', '97vHT782ekg', 'lI948X2Z', 'Saint Paul', 'Izabel', 33.72, to_date('2022-02-13 ','yyyy-mm-dd'), 'Available', 'E197M0', 1);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (74, 'SUV', 'Alfa Romeo', '164', '7456254rQ2A', 'NaN34t4R', 'Del Sol', 'Giff', 41.92, to_date('2021-08-27 ','yyyy-mm-dd'), 'Available', 'M428T8', 3);
insert into Vehicles (vehicle_id, vehicle_type, vehicle_manufacturer, vehicle_model, chasis_no, engine_no, vehicle_location, vehicle_owner, base_cost, purchase_date, vehicle_status, vehicle_no, store_id) values (75, 'Sedan', 'Saturn', 'Sky', '37Lz116G16V', '6zQ08X1q', 'Graceland', 'Jacqueline', 34.34, to_date('2022-06-12 ','yyyy-mm-dd'), 'Available', 'T317Y1', 3);


--car_health
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (1, 1, '12-Nov-2022', '21-Apr-2022', 'OKAY', 'Comprehensive', '997884', 0, 0, 0, 30, '11-Dec-2022', '11-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (2, 2, '17-Feb-2023', '18-Dec-2021', 'OKAY', 'Collision', '982104', 1, 0, 0, 31, '17-Jan-2023', '09-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (3, 3, '06-Mar-2022', '11-Feb-2023', 'NOT OKAY', 'Injury Protection', '310485', 0, 0, 0, 49, '13-Dec-2022', '28-Apr-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (4, 4, '11-Oct-2022', '08-Sep-2021', 'OKAY', 'General', '494235', 0, 0, 0, 24, '11-Jan-2023', '07-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (5, 5, '16-May-2022', '25-Aug-2022', 'OKAY', 'Full Coverage', '973698', 0, 0, 0, 45, '26-Feb-2023', '15-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (6, 6, '29-Jan-2022', '02-Feb-2022', 'OKAY', 'Injury Protection', '044699', 0, 0, 0, 27, '21-Jun-2022', '03-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (7, 7, '17-Jun-2022', '05-Nov-2021', 'OKAY', 'Comprehensive', '510760', 0, 0, 0, 29, '31-Jan-2023', '03-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (8, 8, '03-Aug-2021', '21-Aug-2021', 'OKAY', 'Full Coverage', '687631', 0, 0, 0, 41, '24-Aug-2022', '15-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (9, 9, '15-Sep-2021', '22-Nov-2022', 'OKAY', 'Comprehensive', '202781', 0, 0, 0, 10, '23-Sep-2022', '16-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (10, 10, '22-Jun-2022', '19-May-2022', 'OKAY', 'Full Coverage', '701620', 0, 0, 0, 10, '23-May-2022', '26-Apr-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (11, 11, '07-Oct-2021', '24-Oct-2021', 'OKAY', 'Injury Protection', '842324', 1, 0, 0, 7, '26-Aug-2022', '22-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (12, 12, '26-Nov-2022', '18-Mar-2022', 'OKAY', 'Full Coverage', '885265', 1, 0, 0, 15, '22-Dec-2022', '28-Jun-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (13, 13, '20-Feb-2023', '09-Mar-2023', 'OKAY', 'Full Coverage', '977368', 0, 0, 0, 7, '26-Sep-2022', '18-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (14, 14, '18-Jun-2022', '24-Oct-2022', 'OKAY', 'Full Coverage', '248518', 0, 0, 0, 21, '26-Mar-2022', '25-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (15, 15, '13-Apr-2022', '17-Dec-2021', 'OKAY', 'Full Coverage', '397288', 0, 0, 0, 18, '01-Dec-2022', '22-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (16, 16, '17-Dec-2022', '13-Oct-2022', 'OKAY', 'Comprehensive', '471435', 1, 0, 0, 50, '14-Nov-2022', '10-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (17, 17, '30-Sep-2021', '12-Jan-2022', 'OKAY', 'General', '556814', 0, 0, 0, 12, '03-Jun-2022', '02-Apr-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (18, 18, '30-Nov-2021', '10-Feb-2022', 'OKAY', 'Collision', '422581', 1, 0, 0, 27, '17-Feb-2023', '29-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (19, 19, '27-Apr-2022', '28-Dec-2021', 'OKAY', 'Collision', '575699', 0, 0, 0, 38, '21-Nov-2022', '04-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (20, 20, '12-Oct-2021', '24-Sep-2022', 'OKAY', 'General', '172695', 1, 0, 0, 34, '28-Dec-2022', '14-Feb-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (21, 21, '02-Oct-2021', '22-Dec-2022', 'OKAY', 'Full Coverage', '138012', 1, 0, 0, 17, '22-Nov-2022', '06-Jun-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (22, 22, '15-Jan-2023', '29-Jul-2022', 'OKAY', 'Collision', '892874', 1, 0, 0, 32, '09-Mar-2023', '23-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (23, 23, '11-Nov-2022', '08-May-2022', 'OKAY', 'Injury Protection', '570888', 0, 0, 0, 30, '12-May-2022', '24-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (24, 24, '29-Sep-2022', '14-Aug-2022', 'OKAY', 'Full Coverage', '632991', 0, 0, 0, 41, '24-Dec-2022', '23-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (25, 25, '16-Jul-2022', '19-Feb-2022', 'OKAY', 'General', '819719', 1, 0, 0, 14, '24-Mar-2023', '26-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (26, 26, '04-Aug-2021', '08-Feb-2022', 'OKAY', 'Comprehensive', '414421', 1, 0, 0, 44, '06-Mar-2023', '05-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (27, 27, '04-Feb-2023', '07-Dec-2022', 'OKAY', 'Comprehensive', '928051', 0, 0, 0, 23, '11-Sep-2022', '15-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (28, 28, '07-Oct-2022', '11-Nov-2021', 'OKAY', 'Comprehensive', '802901', 1, 0, 0, 23, '05-Oct-2022', '25-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (29, 29, '14-Aug-2022', '13-Mar-2022', 'OKAY', 'General', '413719', 0, 0, 0, 18, '25-Feb-2023', '21-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (30, 30, '11-Sep-2022', '05-Mar-2023', 'OKAY', 'Injury Protection', '293419', 0, 0, 0, 42, '30-Aug-2022', '31-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (31, 31, '22-Jul-2022', '17-Jan-2023', 'NOT OKAY', 'Full Coverage', '740278', 0, 0, 0, 8, '23-Sep-2022', '05-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (32, 32, '06-Feb-2023', '03-Jun-2022', 'OKAY', 'Full Coverage', '511891', 1, 0, 0, 38, '22-Nov-2022', '16-Feb-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (33, 33, '27-Sep-2021', '01-Oct-2022', 'OKAY', 'Collision', '365661', 1, 0, 0, 15, '18-Apr-2022', '16-Oct-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (34, 34, '27-Nov-2022', '17-Sep-2022', 'OKAY', 'General', '815751', 1, 0, 0, 24, '04-Jul-2022', '13-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (35, 35, '05-Jan-2022', '16-Mar-2023', 'OKAY', 'Collision', '982608', 0, 0, 0, 26, '01-Dec-2022', '20-Apr-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (36, 36, '07-Jul-2022', '19-Dec-2021', 'OKAY', 'Full Coverage', '279306', 1, 0, 0, 10, '29-Nov-2022', '05-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (37, 37, '20-Jan-2022', '20-Dec-2022', 'OKAY', 'General', '507500', 0, 0, 0, 4, '20-Jun-2022', '30-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (38, 38, '13-Apr-2022', '11-Feb-2022', 'OKAY', 'Collision', '684199', 1, 0, 0, 50, '12-Dec-2022', '12-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (39, 39, '06-Jun-2022', '09-Feb-2022', 'OKAY', 'Full Coverage', '560993', 0, 0, 0, 17, '07-Aug-2022', '09-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (40, 40, '17-Nov-2021', '14-Mar-2023', 'OKAY', 'Injury Protection', '165865', 0, 0, 0, 37, '20-Mar-2023', '09-Nov-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (41, 41, '04-Feb-2023', '01-Mar-2023', 'OKAY', 'Injury Protection', '809491', 1, 0, 0, 30, '25-Feb-2023', '21-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (42, 42, '01-Nov-2021', '10-Jan-2023', 'OKAY', 'Injury Protection', '883104', 1, 0, 0, 30, '02-Mar-2023', '12-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (43, 43, '22-May-2022', '24-Jul-2021', 'OKAY', 'Full Coverage', '148021', 1, 0, 0, 44, '01-Sep-2022', '18-Jun-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (44, 44, '04-Feb-2023', '28-Sep-2022', 'OKAY', 'Collision', '157713', 1, 0, 0, 31, '12-Jun-2022', '13-Dec-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (45, 45, '18-Apr-2022', '22-Feb-2023', 'OKAY', 'Collision', '586262', 1, 0, 0, 45, '02-Nov-2022', '22-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (46, 46, '27-Feb-2022', '03-Feb-2023', 'OKAY', 'General', '041649', 1, 0, 0, 12, '23-Jul-2022', '18-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (47, 47, '21-Aug-2021', '18-Dec-2021', 'OKAY', 'Comprehensive', '301045', 0, 0, 0, 25, '16-Oct-2022', '05-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (48, 48, '08-Feb-2022', '05-Aug-2022', 'OKAY', 'Injury Protection', '866940', 1, 0, 0, 10, '19-Mar-2023', '18-Feb-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (49, 49, '08-Sep-2021', '18-Dec-2022', 'OKAY', 'Injury Protection', '420204', 0, 0, 0, 10, '10-Mar-2023', '18-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (50, 50, '07-Sep-2021', '23-Jan-2022', 'OKAY', 'General', '209504', 1, 0, 0, 47, '15-Aug-2022', '17-Nov-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (51, 51, '18-Mar-2022', '19-Dec-2022', 'OKAY', 'Full Coverage', '351432', 1, 0, 0, 29, '28-Nov-2022', '18-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (52, 52, '23-Oct-2022', '05-Dec-2021', 'OKAY', 'Injury Protection', '830122', 1, 0, 0, 8, '04-Apr-2022', '23-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (53, 53, '24-Dec-2021', '11-May-2022', 'OKAY', 'Full Coverage', '585610', 0, 0, 0, 1, '24-May-2022', '24-Mar-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (54, 54, '28-Dec-2022', '26-Oct-2022', 'OKAY', 'General', '870306', 1, 0, 0, 50, '28-Nov-2022', '19-Oct-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (55, 55, '22-Mar-2023', '27-Jun-2022', 'OKAY', 'Comprehensive', '091622', 0, 0, 0, 14, '06-Nov-2022', '16-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (56, 56, '14-Apr-2022', '17-Dec-2021', 'OKAY', 'Injury Protection', '456516', 0, 0, 0, 19, '19-Aug-2022', '21-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (57, 57, '13-Dec-2022', '17-Jan-2023', 'OKAY', 'Injury Protection', '896688', 1, 0, 0, 3, '22-Dec-2022', '02-Oct-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (58, 58, '12-Dec-2022', '16-Mar-2022', 'OKAY', 'Comprehensive', '838872', 0, 0, 0, 47, '12-Oct-2022', '26-Nov-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (59, 59, '13-Jan-2023', '09-Dec-2022', 'OKAY', 'Injury Protection', '226052', 1, 0, 0, 30, '22-Jan-2023', '25-Feb-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (60, 60, '07-Jan-2022', '16-Apr-2022', 'OKAY', 'Comprehensive', '234676', 0, 0, 0, 36, '01-Aug-2022', '14-Apr-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (61, 61, '13-Mar-2022', '10-Feb-2023', 'OKAY', 'Injury Protection', '060791', 0, 0, 0, 19, '12-Nov-2022', '20-Nov-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (62, 62, '26-Nov-2021', '02-Aug-2021', 'OKAY', 'General', '583546', 1, 0, 0, 21, '27-Nov-2022', '08-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (63, 63, '03-Feb-2023', '14-Sep-2022', 'OKAY', 'Full Coverage', '398301', 0, 0, 0, 3, '29-Dec-2022', '16-Jul-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (64, 64, '17-Jul-2021', '23-Jan-2022', 'OKAY', 'Full Coverage', '416723', 1, 0, 0, 17, '27-Jan-2023', '16-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (65, 65, '19-May-2022', '23-Jan-2023', 'OKAY', 'Full Coverage', '596265', 1, 0, 0, 21, '06-May-2022', '17-Oct-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (66, 66, '27-May-2022', '11-Feb-2022', 'OKAY', 'General', '564915', 1, 0, 0, 36, '26-Dec-2022', '10-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (67, 67, '23-Jun-2022', '19-Jan-2022', 'OKAY', 'Comprehensive', '415817', 1, 0, 0, 18, '14-Oct-2022', '01-Oct-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (68, 68, '02-Apr-2022', '01-Aug-2022', 'OKAY', 'Collision', '357049', 1, 0, 0, 21, '19-Feb-2023', '29-Mar-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (69, 69, '08-Jun-2022', '21-Jul-2021', 'NOT OKAY', 'Full Coverage', '767817', 1, 0, 0, 36, '26-Mar-2022', '24-Jan-2023');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (70, 70, '26-Feb-2022', '30-Mar-2022', 'OKAY', 'Injury Protection', '574100', 1, 0, 0, 38, '12-May-2022', '08-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (71, 71, '22-Oct-2022', '22-Aug-2022', 'OKAY', 'Full Coverage', '141786', 1, 0, 0, 5, '03-Jun-2022', '27-May-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (72, 72, '08-Oct-2021', '05-Feb-2022', 'OKAY', 'Collision', '110337', 0, 0, 0, 48, '11-Jun-2022', '28-Nov-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (73, 73, '01-Apr-2022', '23-Sep-2022', 'OKAY', 'Collision', '080608', 0, 0, 0, 3, '23-Feb-2023', '01-Sep-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (74, 74, '13-Apr-2022', '26-May-2022', 'OKAY', 'Full Coverage', '353426', 1, 0, 0, 6, '18-Aug-2022', '10-Aug-2022');
insert into Car_health (car_health_id, vehicle_id, last_service_date, next_service_date, health_status, insurance_type, insurance_no, check_engine_oil, check_tier_pressure, check_air_filter, employee_id, last_update_date_time, RENEWAL_DATE) values (75, 75, '18-Oct-2022', '14-Jul-2022', 'OKAY', 'Collision', '738277', 0, 0, 0, 44, '07-Dec-2022', '28-Jun-2022');

--store_location
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (1, '19 Mifflin Pass', 58, 'Saint Cloud', 'Minnesota', 'United States', '56372', 'Saint Cloud', '23.0343,63.9333');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (2, '8577 Ludington Hill', 78, 'Anchorage', 'Alaska', 'United States', '99512', 'Anchorage', '43.4353,83.9313');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (3, '15589 6th Trail', 26, 'Tallahassee', 'Florida', 'United States', '32309', 'Tallahassee', '43.9323,23.4393');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (4, '39252 Cody Court', 30, 'Springfield', 'Massachusetts', 'United States', '01129', 'Springfield', '63.9343,53.1313');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (5, '112 Donald Hill', 46, 'Bridgeport', 'Connecticut', 'United States', '06606', 'Bridgeport', '43.7393,23.9323');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (6, '228 Eggendart Avenue', 94, 'Frankfort', 'Kentucky', 'United States', '40618', 'Frankfort', '23.6303,13.2313');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (7, '2 Kipling Place', 83, 'Columbus', 'Georgia', 'United States', '31904', 'Columbus', '43.0353,13.7383');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (8, '0746 Aberg Road', 20, 'Rochester', 'Minnesota', 'United States', '55905', 'Rochester', '23.7343,83.9353');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (9, '0 Starling Road', 64, 'Chicago', 'Illinois', 'United States', '60691', 'Chicago', '63.3383,63.5393');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (10, '41 Springs Court', 73, 'Hot Springs National Park', 'Arkansas', 'United States', '71914', 'Hot Springs National Park', '13.8373,93.4383');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (11, '9069 Graedel Plaza', 15, 'Alexandria', 'Virginia', 'United States', '22333', 'Alexandria', '93.5393,63.7313');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (12, '162 Butternut Alley', 88, 'Dallas', 'Texas', 'United States', '75226', 'Dallas', '13.1353,33.0353');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (13, '4 Lake View Drive', 28, 'Arvada', 'Colorado', 'United States', '80005', 'Arvada', '33.6393,73.2303');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (14, '7 Hanover Center', 6, 'Toledo', 'Ohio', 'United States', '43666', 'Toledo', '43.3343,73.0323');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (15, '8 Thackeray Plaza', 16, 'El Paso', 'Texas', 'United States', '88569', 'El Paso', '23.0303,53.1343');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (16, '3822 Morningstar Alley', 12, 'Fort Smith', 'Arkansas', 'United States', '72905', 'Fort Smith', '83.9333,33.5353');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (17, '52447 Autumn Leaf Park', 98, 'Wichita', 'Kansas', 'United States', '67220', 'Wichita', '73.8343,73.0353');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (18, '553 Bayside Crossing', 81, 'Harrisburg', 'Pennsylvania', 'United States', '17121', 'Harrisburg', '93.3353,93.1363');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (19, '919 Morrow Drive', null, 'Philadelphia', 'Pennsylvania', 'United States', '19125', 'Philadelphia', '13.8343,43.8313');
insert into store_location (store_id, address_line_1, address_line_2, city, state, country, zip_code, store_name, store_location) values (20, '5 Grover Avenue', 17, 'Houston', 'Texas', 'United States', '77201', 'Houston', '13.4373,13.7353');

--employees
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (1, 'Sarine', 'Chalfain', '189-64-7495', 'manager', '8033968302', 'schalfain0@utexas.edu', 1, '2 Fallview Plaza', 'Room 1377', 'Columbia', 'South Carolina', 'United States', '29203', 1, 22.62, to_date('2022-03-01','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (2, 'Murial', 'Eite', '120-58-8420', 'manager', '3184301924', 'meite1@imgur.com', 2, '65473 Hauk Court', 'Suite 14', 'Shreveport', 'Louisiana', 'United States', '71166', 2, 20.31, to_date('2022-03-06','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (3, 'Mignonne', 'Leyre', '259-74-4467', 'manager', '8043293476', 'mleyre2@fc2.com', 3, '90635 Mayfield Alley', 'Apt 189', 'Richmond', 'Virginia', 'United States', '23242',3 , 23.00, to_date('2022-10-09','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (4, 'Colin', 'Swiggs', '146-36-4764', 'manager', '5205316838', 'cswiggs3@toplist.cz', 4, '5 Karstens Drive', null, 'Phoenix', 'Arizona', 'United States', '85025', 4, 29.79,to_date( '2022-07-23','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (5, 'Valerie', 'Hatje', '260-49-4586', 'manager', '2029685487', 'vhatje4@blogtalkradio.com', 5, '42 Rusk Place', 'PO Box 38196', 'Washington', 'District of Columbia', 'United States', '20210', 5, 23.70, to_date('2023-01-30','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (6, 'Mick', 'Bradford', '417-38-9606', 'manager', '8609848327', 'mbradford5@jigsy.com', 6, '68 Blaine Park', null, 'Hartford', 'Connecticut', 'United States', '06152', 6, 35.00, to_date('2023-03-20','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (7, 'Giustino', 'Carrier', '399-23-2738', 'manager', '8177105882', 'gcarrier6@forbes.com', 7, '66960 Delaware Park', 'PO Box 14520', 'Irving', 'Texas', 'United States', '75062', 7, 29.08, to_date('2022-10-02','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (8, 'Quinn', 'Ubach', '313-06-1644', 'manager', '8045149070', 'qubach7@cpanel.net', 8, '1817 Scoville Road', 'Apt 1170', 'Richmond', 'Virginia', 'United States', '23213', 8, 37.17, to_date('2022-07-09','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (9, 'Davita', 'Olczyk', '695-36-2824', 'manager', '8132958450', 'dolczyk8@webnode.com', 9, '38 Birchwood Court', null, 'Saint Petersburg', 'Florida', 'United States', '337085', 9, 26.66, to_date('2021-07-22','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (10, 'Felicle', 'Abrashkov', '479-45-0229', 'manager', '2604289682', 'fabrashkov9@angelfire.com', 10, '62 Hayes Crossing', 'PO Box 14799', 'Fort Wayne', 'Indiana', 'United States', '46814', 10, 27.27, to_date('2022-03-17','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (11, 'Josiah', 'Makey', '287-70-0644', 'employee', '7014787772', 'jmakeya@dot.gov', 9, '79 Loftsgordon Center', null, 'Fargo', 'North Dakota', 'United States', '58106', 9, 23,to_date( '2022-08-10','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (12, 'Fraze', 'Monteath', '523-09-9750', 'employee', '2143570616', 'fmonteathb@xing.com', 3, '1403 Jenna Circle', 'PO Box 868', 'Dallas', 'Texas', 'United States', '75277', 3, 17.76, to_date('2021-10-23','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (13, 'Bradney', 'McAnulty', '478-29-8872', 'employee', '8501714347', 'bmcanultyc@nature.com', 9, '95022 Hovde Center', null, 'Pensacola', 'Florida', 'United States', '32505', 9, 22.18, to_date('2022-11-23','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (14, 'Benedicto', 'Thunnerclef', '123-91-4925', 'employee', '5022734626', 'bthunnerclefd@usnews.com', 1, '628 North Road', '16th Floor', 'Louisville', 'Kentucky', 'United States', '40220', 1, 28,to_date( '2022-01-12 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (15, 'Sherilyn', 'Whapham', '228-49-6347', 'employee', '5133145202', 'swhaphame@studiopress.com', 4, '2 Trailsway Hill', null, 'Cincinnati', 'Ohio', 'United States', '45271', 4, 24.51, to_date('2021-10-17','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (16, 'Ermanno', 'O''Currigan', '203-89-7721', 'employee', '8597872682', 'eocurriganf@skype.com', 3, '476 Mitchell Court', null, 'Lexington', 'Kentucky', 'United States', '40510', 3, 18.07, to_date('2022-02-25','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (17, 'Nikolaus', 'Ast', '303-46-8737', 'employee', '7731396577', 'nastg@wp.com', 10, '10 Lukken Place', '2nd Floor', 'Chicago', 'Illinois', 'United States', '60614', 10, 23.82, to_date('2022-08-26','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (18, 'Donnie', 'Pakeman', '771-42-1260', 'employee', '6191706666', 'dpakemanh@accuweather.com', 5, '8993 Onsgard Road', null, 'San Diego', 'California', 'United States', '92196', 5, 18.78,to_date( '2022-02-24 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (19, 'Dalis', 'Thurby', '828-91-6190', 'employee', '9542834096', 'dthurbyi@phoca.cz', 10, '521 Manitowish Terrace', 'PO Box 15245', 'Boca Raton', 'Florida', 'United States', '33432', 10, 26.13, to_date('2022-08-28','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (20, 'Jobyna', 'MacParland', '277-06-1718', 'employee', '9419727652', 'jmacparlandj@ocn.ne.jp', 9, '20011 Jenna Road', null, 'Naples', 'Florida', 'United States', '34108', 9, 28.65, to_date('2022-01-30 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (21, 'Niel', 'McCarter', '189-78-6012', 'employee', '7863959994', 'nmccarterk@ed.gov', 7, '118 Messerschmidt Junction', null, 'Miami', 'Florida', 'United States', '33129', 7, 21.04, to_date('2023-01-27 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (22, 'Cal', 'Graysmark', '748-31-9862', 'employee', '3231099000', 'cgraysmarkl@telegraph.co.uk', 1, '73731 Dapin Point', 'Apt 1938', 'Los Angeles', 'California', 'United States', '90076', 1, 29,to_date( '2021-09-18 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (23, 'Othello', 'Blackadder', '347-36-6663', 'employee', '3057411062', 'oblackadderm@themeforest.net', 6, '7 Mariners Cove Terrace', '17th Floor', 'Miami', 'Florida', 'United States', '33185', 6, 22.57,to_date( '2022-10-20 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (24, 'Aharon', 'Orts', '362-66-0991', 'employee', '5741079021', 'aortsn@nhs.uk', 2, '9 Farmco Parkway', 'Suite 44', 'South Bend', 'Indiana', 'United States', '46634', 2, 29.97, to_date('2022-06-29','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (25, 'Benyamin', 'Caunt', '890-71-7532', 'employee', '3349048110', 'bcaunto@huffingtonpost.com', 5, '56 Rigney Street', null, 'Montgomery', 'Alabama', 'United States', '36119', 5, 29.22,to_date( '2022-08-04 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (26, 'Sayre', 'Grizard', '738-65-6900', 'employee', '2027196970', 'sgrizardp@google.nl', 2, '11 Algoma Alley', 'Suite 38', 'Washington', 'District of Columbia', 'United States', '20205', 2, 25.51,to_date( '2022-03-30','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (27, 'Bethina', 'Kasparski', '373-36-6673', 'employee', '2251087534', 'bkasparskiq@accuweather.com', 3, '41774 Manufacturers Way', 'Room 698', 'Baton Rouge', 'Louisiana', 'United States', '70883', 3, 16.79, to_date('2021-08-07 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (28, 'Quinn', 'Mantrip', '107-22-2803', 'employee', '7134450430', 'qmantripr@360.cn', 6, '52704 Twin Pines Lane', 'Room 1671', 'Houston', 'Texas', 'United States', '77218', 6, 25.66, to_date('2022-05-03','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (29, 'Immanuel', 'Tynemouth', '505-17-2928', 'employee', '4122644944', 'itynemouths@seattletimes.com', 7, '6 Toban Plaza', null, 'Pittsburgh', 'Pennsylvania', 'United States', '15250', 7, 26,to_date( '2022-08-01','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (30, 'Kathye', 'Drew', '654-73-3444', 'employee', '7146625196', 'kdrewt@umn.edu', 6, '2 Stuart Parkway', null, 'Garden Grove', 'California', 'United States', '92844', 6, 20.97,to_date( '2021-09-03 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (31, 'Timothee', 'Don', '287-29-1410', 'employee', '8145568074', 'tdonu@usgs.gov', 6, '90 Westend Place', null, 'Erie', 'Pennsylvania', 'United States', '16522', 6, 23.30, to_date('2022-02-26','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (32, 'Tobe', 'Jermin', '690-98-9454', 'employee', '2252794868', 'tjerminv@weather.com', 5, '5709 Montana Hill', null, 'Baton Rouge', 'Louisiana', 'United States', '70826', 5, 18.83, to_date('2022-03-27','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (33, 'Gannie', 'Greaves', '807-66-2886', 'employee', '5719477401', 'ggreavesw@ox.ac.uk', 3, '9511 Fulton Court', null, 'Reston', 'Virginia', 'United States', '22096', 3, 15.56, to_date('2022-11-18','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (34, 'Jane', 'Standen', '854-67-2568', 'employee', '8506354101', 'jstandenx@washington.edu', 1, '59737 Ramsey Plaza', 'PO Box 27344', 'Panama City', 'Florida', 'United States', '32412', 1, 29.56, to_date('2022-05-21','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (35, 'Allistir', 'Wilmore', '598-60-4784', 'employee', '7542643574', 'awilmorey@loc.gov', 9, '250 Butterfield Way', null, 'Pompano Beach', 'Florida', 'United States', '33069', 9, 26.63, to_date('2022-08-19','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (36, 'Ralph', 'Shitliff', '588-39-3665', 'employee', '3123200818', 'rshitliffz@soundcloud.com', 6, '51362 Schmedeman Circle', null, 'Chicago', 'Illinois', 'United States', '60674', 6, 29.31, to_date('2022-08-24','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (37, 'Bennie', 'Emer', '329-20-8223', 'employee', '5405272667', 'bemer10@symantec.com', 1, '5 Arapahoe Place', null, 'Charlottesville', 'Virginia', 'United States', '22903', 1, 24.38, to_date('2021-08-27','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (38, 'Brinna', 'Godar', '251-34-1393', 'employee', '3231240929', 'bgodar11@ft.com', 3, '96 Nancy Drive', null, 'Inglewood', 'California', 'United States', '90305', 3, 29.53,to_date( '2022-04-29','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (39, 'Daniela', 'Tarren', '400-32-5487', 'employee', '8065627407', 'dtarren12@quantcast.com', 6, '60505 Forest Dale Circle', null, 'Amarillo', 'Texas', 'United States', '79182', 6, 28.21, to_date('2022-07-24 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (40, 'Viola', 'Follitt', '197-64-9833', 'employee', '8659472937', 'vfollitt13@usnews.com', 10, '8560 Upham Terrace', null, 'Knoxville', 'Tennessee', 'United States', '37931', 10, 20, to_date('2023-02-14 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (41, 'Kienan', 'Nursey', '500-71-8497', 'employee', '9078283180', 'knursey14@chronoengine.com', 10, '5478 Anzinger Hill', 'PO Box 75935', 'Anchorage', 'Alaska', 'United States', '99599', 10, 29.53, to_date('2021-12-27 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (42, 'Dorolisa', 'Deetch', '227-27-8256', 'employee', '3035584400', 'ddeetch15@yolasite.com', 3, '017 Kennedy Parkway', null, 'Aurora', 'Colorado', 'United States', '80044', 3, 27.17, to_date('2021-12-10','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (43, 'Joseph', 'Snook', '249-25-4745', 'employee', '3303565844', 'jsnook16@blog.com', 6, '41617 Hollow Ridge Hill', null, 'Akron', 'Ohio', 'United States', '44310', 6, 23.53, to_date('2022-11-19','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (44, 'Devin', 'Dudeney', '640-68-2990', 'employee', '3474246930', 'ddudeney17@taobao.com', 3, '0 Green Ridge Parkway', 'Suite 65', 'Brooklyn', 'New York', 'United States', '11210', 3, 21.33, to_date('2022-02-11','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (45, 'Taryn', 'McIlvaney', '526-86-8184', 'employee', '9018903876', 'tmcilvaney18@jimdo.com', 6, '04 Prentice Road', '13th Floor', 'Memphis', 'Tennessee', 'United States', '38131', 6, 22.81, to_date('2021-09-26 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (46, 'Jemie', 'Bassingden', '776-93-7909', 'employee', '2039423836', 'jbassingden19@altervista.org', 3, '153 4th Plaza', 'Apt 545', 'Stamford', 'Connecticut', 'United States', '06905', 3, 24.54, to_date('2022-05-02','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (47, 'Rebeca', 'Hallatt', '880-47-7527', 'employee', '7148416269', 'rhallatt1a@oakley.com', 2, '0 Vidon Parkway', null, 'Fullerton', 'California', 'United States', '92835', 2, 27.72, to_date('2023-02-23 ','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (48, 'Ly', 'Wilkinson', '851-99-4617', 'employee', '3363924219', 'lwilkinson1b@comcast.net', 9, '60 Sullivan Plaza', null, 'Greensboro', 'North Carolina', 'United States', '27409', 9, 26.06, to_date('2022-04-10','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (49, 'Anthe', 'Enderlein', '211-47-1155', 'employee', '3239231890', 'aenderlein1c@cmu.edu', 8, '349 Brown Drive', null, 'Los Angeles', 'California', 'United States', '90010', 8, 19.08, to_date('2021-10-17','yyyy-mm-dd'));
insert into employees (employee_id, first_name, last_name, ssn_no, designation, phone_no, email_id, store_id, address_line_1, address_line_2, city, state, country, zip_code, manager_id, salary, date_of_joining) values (50, 'Faber', 'Katz', '338-49-0712', 'employee', '7018332236', 'fkatz1d@soup.io', 10, '3 Mallory Hill', 'PO Box 54423', 'Grand Forks', 'North Dakota', 'United States', '58207', 10, 18.40, to_date('2022-10-06 ','yyyy-mm-dd'));

--customers
INSERT INTO customers (customer_id, first_name, last_name, email_id, phone_no, date_of_birth, gender, address_line_1, address_line_2, city, state, country, zip_code) 

SELECT 1, 'Mariana', 'Chippendale', 'mchippendale0@google.ca', '5708416724', '20-Feb-1990', 'Female', '97783 Meadow Ridge Point', 'Apt 337', 'Wilkes Barre', 'Pennsylvania', 'United States', '18706' FROM dual UNION ALL 

SELECT 2, 'Brody', 'Simunek', 'bsimunek1@over-blog.com', '6092975227', '29-Nov-2002', 'Male', '8 Cody Junction', 'Apt 631', 'Trenton', 'New Jersey', 'United States', '08608' FROM dual UNION ALL 

SELECT 3, 'Padraig', 'Hast', 'phast2@ocn.ne.jp', '4084449760', '01-Jul-1982', 'Male', '158 Victoria Drive', 'Apt 47', 'San Jose', 'California', 'United States', '95133' FROM dual UNION ALL 

SELECT 4, 'Heda', 'Whatling', 'hwhatling3@meetup.com', '8431201083', '19-Jul-1946', 'Agender', '5824 Pleasure Pass', 'PO Box 23050', 'Charleston', 'South Carolina', 'United States', '29424' FROM dual UNION ALL 

SELECT 5, 'Arlee', 'Niles', 'aniles4@joomla.org', '5054065164', '06-Apr-1999', 'Female', '62498 Atwood Junction', 'Suite 64', 'Albuquerque', 'New Mexico', 'United States', '87115' FROM dual UNION ALL 

SELECT 6, 'Ahmed', 'Haxbie', 'ahaxbie5@earthlink.net', '2065267017', '17-Feb-1949', 'Male', '1001 Moland Road', 'Room 311', 'Kent', 'Washington', 'United States', '98042' FROM dual UNION ALL 

SELECT 7, 'Bartholomew', 'Harvatt', 'bharvatt6@cargocollective.com', '7869769619', '01-Dec-1994', 'Male', '469 Meadow Vale Center', '12th Floor', 'Miami', 'Florida', 'United States', '33233' FROM dual UNION ALL 

SELECT 8, 'Sibeal', 'Corston', 'scorston7@webmd.com', '7185009847', '17-Jul-1945', 'Female', '4211 Jana Trail', 'Room 793', 'Brooklyn', 'New York', 'United States', '11205' FROM dual UNION ALL 

SELECT 9, 'Amelita', 'McAllaster', 'amcallaster8@booking.com', '2028847464', '06-Jun-1953', 'Female', '217 Nevada Pass', '11th Floor', 'Washington', 'District of Columbia', 'United States', '20557' FROM dual UNION ALL 

SELECT 10, 'Noami', 'Anthonies', 'nanthonies9@narod.ru', '5053375634', '14-Apr-1983', 'Female', '460 Clyde Gallagher Center', 'Room 889', 'Albuquerque', 'New Mexico', 'United States', '87140' FROM dual UNION ALL 

SELECT 11, 'Wilfrid', 'Croshaw', 'wcroshawa@virginia.edu', '2039813523', '27-Nov-1960', 'Male', '06772 Merry Street', 'Apt 1788', 'Norwalk', 'Connecticut', 'United States', '06854' FROM dual UNION ALL 

SELECT 12, 'Archaimbaud', 'Hulls', 'ahullsb@ibm.com', '9413427093', '29-Feb-1984', 'Male', '6 Hoard Avenue', 'Apt 321', 'Sarasota', 'Florida', 'United States', '34276' FROM dual UNION ALL 

SELECT 13, 'Normie', 'McConville', 'nmcconvillec@mlb.com', '4145834021', '10-Nov-1996', 'Male', '37 Mccormick Alley', 'Room 1054', 'Milwaukee', 'Wisconsin', 'United States', '53220' FROM dual UNION ALL 

SELECT 14, 'Urban', 'Ventom', 'uventomd@theglobeandmail.com', '7348682467', '10-Mar-1945', 'Male', '540 Ramsey Pass', 'Room 215', 'Detroit', 'Michigan', 'United States', '48258' FROM dual UNION ALL 

SELECT 15, 'Marcile', 'Shears', 'mshearse@desdev.cn', '3035127713', '23-Aug-1984', 'Female', '57 Trailsway Avenue', '8th Floor', 'Denver', 'Colorado', 'United States', '80270' FROM dual UNION ALL 

SELECT 16, 'Vic', 'Gellately', 'vgellatelyf@japanpost.jp', '5139725045', '23-Feb-2001', 'Male', '33898 Carey Junction', '16th Floor', 'Cincinnati', 'Ohio', 'United States', '45203' FROM dual UNION ALL 

SELECT 17, 'Nathanael', 'Roger', 'nrogerg@slate.com', '2093592618', '22-Nov-1944', 'Male', '85 Kropf Way', 'Room 835', 'Stockton', 'California', 'United States', '95205' FROM dual UNION ALL 

SELECT 18, 'Kelley', 'Smeed', 'ksmeedh@icq.com', '6144371577', '31-Oct-1990', 'Female', '02 Mockingbird Terrace', 'PO Box 50772', 'Columbus', 'Ohio', 'United States', '43215' FROM dual UNION ALL 

SELECT 19, 'Christal', 'Goldsworthy', 'cgoldsworthyi@rakuten.co.jp', '6464522466', '24-Apr-1946', 'Female', '44293 Karstens Way', 'PO Box 80022', 'New York City', 'New York', 'United States', '10060' FROM dual UNION ALL 

SELECT 20, 'Eldin', 'Marjanski', 'emarjanskij@booking.com', '3093147788', '20-May-1964', 'Male', '79 Stuart Court', 'Apt 1163', 'Peoria', 'Illinois', 'United States', '61656' FROM dual UNION ALL 

SELECT 21, 'Jonathon', 'Jouannisson', 'jjouannissonk@bravesites.com', '8011160356', '08-Aug-1976', 'Male', '14005 Buena Vista Junction', 'PO Box 81746', 'Provo', 'Utah', 'United States', '84605' FROM dual UNION ALL 

SELECT 22, 'Neal', 'Faughny', 'nfaughnyl@nba.com', '7572953809', '13-May-1962', 'Male', '190 5th Way', 'Room 1216', 'Herndon', 'Virginia', 'United States', '22070' FROM dual UNION ALL 

SELECT 23, 'Emanuel', 'Allot', 'eallotm@example.com', '3122913604', '17-Aug-1975', 'Male', '24 School Parkway', 'Suite 72', 'Aurora', 'Illinois', 'United States', '60505' FROM dual UNION ALL 

SELECT 24, 'Francklyn', 'Farres', 'ffarresn@huffingtonpost.com', '6466506932', '03-Oct-1974', 'Male', '006 Dwight Road', 'Suite 55', 'New York City', 'New York', 'United States', '10099' FROM dual UNION ALL 

SELECT 25, 'Regan', 'Wilkenson', 'rwilkensono@vinaora.com', '8084716828', '20-Feb-1972', 'Female', '7 Schmedeman Park', 'Room 1314', 'Honolulu', 'Hawaii', 'United States', '96820' FROM dual UNION ALL 

SELECT 26, 'Englebert', 'Barbosa', 'ebarbosap@eventbrite.com', '2399157577', '07-Apr-1948', 'Male', '09 Forest Street', 'Apt 339', 'Lehigh Acres', 'Florida', 'United States', '33972' FROM dual UNION ALL 

SELECT 27, 'Evanne', 'Elvish', 'eelvishq@wunderground.com', '8133549593', '26-Mar-1957', 'Agender', '82 Village Place', 'Suite 81', 'Tampa', 'Florida', 'United States', '33615' FROM dual UNION ALL 

SELECT 28, 'Zena', 'de Quesne', 'zdequesner@behance.net', '5202078650', '18-Feb-1984', 'Female', '03 Summit Hill', 'Apt 1504', 'Tucson', 'Arizona', 'United States', '85737' FROM dual UNION ALL 

SELECT 29, 'Aridatha', 'Cragoe', 'acragoes@engadget.com', '2255254841', '30-Apr-1961', 'Agender', '2537 Summer Ridge Way', '12th Floor', 'Baton Rouge', 'Louisiana', 'United States', '70883' FROM dual UNION ALL 

SELECT 30, 'Charin', 'Limerick', 'climerickt@vk.com', '2405643489', '29-Mar-1943', 'Female', '11392 Delladonna Point', 'Apt 811', 'Hagerstown', 'Maryland', 'United States', '21747' FROM dual UNION ALL 

SELECT 31, 'Gay', 'Shewan', 'gshewanu@psu.edu', '7025679354', '12-Feb-1970', 'Female', '89478 Fisk Drive', 'Room 1498', 'North Las Vegas', 'Nevada', 'United States', '89087' FROM dual UNION ALL 

SELECT 32, 'Artemus', 'Swatheridge', 'aswatheridgev@jugem.jp', '7138937125', '06-Aug-1949', 'Male', '1326 Old Gate Point', 'Apt 420', 'Houston', 'Texas', 'United States', '77271' FROM dual UNION ALL 

SELECT 33, 'Tiphani', 'Bumphries', 'tbumphriesw@addtoany.com', '7274821337', '22-Oct-1950', 'Female', '05174 Dryden Way', 'Room 1187', 'Clearwater', 'Florida', 'United States', '33763' FROM dual UNION ALL 

SELECT 34, 'Jefferey', 'Luby', 'jlubyx@w3.org', '3232371606', '01-Jul-1958', 'Male', '1 Commercial Way', '19th Floor', 'Los Angeles', 'California', 'United States', '90065' FROM dual UNION ALL 

SELECT 35, 'Mycah', 'Fladgate', 'mfladgatey@purevolume.com', '2024001630', '20-Feb-1977', 'Male', '16988 Oakridge Junction', '10th Floor', 'Washington', 'District of Columbia', 'United States', '20540' FROM dual UNION ALL 

SELECT 36, 'Cherey', 'Caudrelier', 'ccaudrelierz@senate.gov', '4197720959', '10-Sep-1947', 'Female', '79512 Westend Trail', 'Apt 712', 'Toledo', 'Ohio', 'United States', '43635' FROM dual UNION ALL 

SELECT 37, 'Demetre', 'Goulter', 'dgoulter10@weibo.com', '7022594811', '05-Jun-1997', 'Male', '6335 Sutteridge Crossing', 'PO Box 93478', 'Henderson', 'Nevada', 'United States', '89012' FROM dual UNION ALL 

SELECT 38, 'Jacob', 'MacAndie', 'jmacandie11@zimbio.com', '2622851743', '28-Mar-1945', 'Male', '29 Artisan Trail', 'Apt 664', 'Milwaukee', 'Wisconsin', 'United States', '53205' FROM dual UNION ALL 

SELECT 39, 'Aldus', 'Alcalde', 'aalcalde12@last.fm', '9412647097', '29-Jun-1990', 'Male', '693 Hazelcrest Crossing', '19th Floor', 'Orlando', 'Florida', 'United States', '32819' FROM dual UNION ALL 

SELECT 40, 'Jerrilee', 'Battershall', 'jbattershall13@tinypic.com', '7278468255', '08-Apr-1949', 'Female', '21 Muir Plaza', '10th Floor', 'Clearwater', 'Florida', 'United States', '33763' FROM dual UNION ALL 

SELECT 41, 'Bertram', 'Ludlem', 'bludlem14@gravatar.com', '8053821317', '20-Jun-1960', 'Male', '193 Arkansas Avenue', 'Suite 94', 'Santa Barbara', 'California', 'United States', '93106' FROM dual UNION ALL 

SELECT 42, 'Kalina', 'Hickenbottom', 'khickenbottom15@usa.gov', '7342924636', '24-Sep-1944', 'Female', '5708 Maple Place', 'Suite 83', 'Ann Arbor', 'Michigan', 'United States', '48107' FROM dual UNION ALL 

SELECT 43, 'Eldridge', 'Estevez', 'eestevez16@baidu.com', '4046014017', '06-Sep-1965', 'Male', '70 Sunfield Pass', 'Suite 68', 'Lawrenceville', 'Georgia', 'United States', '30045' FROM dual UNION ALL 

SELECT 44, 'Datha', 'Gittis', 'dgittis17@dropbox.com', '4022813465', '23-May-1976', 'Female', '3 Aberg Plaza', 'PO Box 28975', 'Lincoln', 'Nebraska', 'United States', '68505' FROM dual UNION ALL 

SELECT 45, 'Norrie', 'Wickendon', 'nwickendon18@desdev.cn', '7024427845', '20-Oct-2002', 'Male', '84 East Street', '11th Floor', 'Las Vegas', 'Nevada', 'United States', '89130' FROM dual UNION ALL 

SELECT 46, 'Quincy', 'Ashbey', 'qashbey19@spotify.com', '9167035285', '19-Apr-1964', 'Male', '27 Fairview Road', 'Apt 200', 'Sacramento', 'California', 'United States', '94286' FROM dual UNION ALL 

SELECT 47, 'Rodrick', 'Acome', 'racome1a@cocolog-nifty.com', '9015236177', '19-Feb-1983', 'Male', '491 North Court', 'PO Box 43344', 'Memphis', 'Tennessee', 'United States', '38143' FROM dual UNION ALL 

SELECT 48, 'Der', 'Dunckley', 'ddunckley1b@techcrunch.com', '3605454123', '15-Nov-1984', 'Male', '4998 Briar Crest Road', 'Room 11', 'Olympia', 'Washington', 'United States', '98506' FROM dual UNION ALL 

SELECT 49, 'Roda', 'Nashe', 'rnashe1c@geocities.jp', '6051384131', '12-Sep-1983', 'Genderfluid', '709 Bultman Junction', 'Suite 59', 'Sioux Falls', 'South Dakota', 'United States', '57110' FROM dual UNION ALL 

SELECT 50, 'Truman', 'Polet', 'tpolet1d@ifeng.com', '8065887862', '30-Jun-2001', 'Male', '7 Sauthoff Circle', 'Room 524', 'Amarillo', 'Texas', 'United States', '79176' FROM dual UNION ALL 

SELECT 51, 'Holt', 'Farahar', 'hfarahar1e@prlog.org', '3181429502', '07-Aug-1961', 'Male', '7 Bunting Junction', 'Suite 23', 'Monroe', 'Louisiana', 'United States', '71213' FROM dual UNION ALL 

SELECT 52, 'Dewey', 'Girardoni', 'dgirardoni1f@so-net.ne.jp', '3098409772', '22-Nov-1978', 'Male', '18400 Stang Drive', 'Suite 43', 'Carol Stream', 'Illinois', 'United States', '60158' FROM dual UNION ALL 

SELECT 53, 'Derward', 'McGahey', 'dmcgahey1g@blinklist.com', '9188268520', '03-Aug-2000', 'Male', '896 Reindahl Center', 'Room 1334', 'Tulsa', 'Oklahoma', 'United States', '74108' FROM dual UNION ALL 

SELECT 54, 'Dita', 'Benko', 'dbenko1h@dagondesign.com', '7186957122', '31-Oct-1995', 'Female', '0245 Cottonwood Parkway', 'Suite 15', 'Brooklyn', 'New York', 'United States', '11220' FROM dual UNION ALL 

SELECT 55, 'Howard', 'Everleigh', 'heverleigh1i@studiopress.com', '5179373288', '19-Mar-1988', 'Male', '2 Sundown Street', 'Apt 942', 'Lansing', 'Michigan', 'United States', '48919' FROM dual UNION ALL 

SELECT 56, 'Cody', 'Kornyakov', 'ckornyakov1j@merriam-webster.com', '5056600881', '03-Apr-1980', 'Female', '2442 Dottie Court', 'Suite 89', 'Santa Fe', 'New Mexico', 'United States', '87505' FROM dual UNION ALL 

SELECT 57, 'Pearl', 'Kretschmer', 'pkretschmer1k@hexun.com', '6198239593', '19-Jun-1966', 'Female', '50152 Surrey Lane', 'Apt 1002', 'San Diego', 'California', 'United States', '92115' FROM dual UNION ALL 

SELECT 58, 'Rodger', 'Knellen', 'rknellen1l@studiopress.com', '8585481150', '05-Oct-1992', 'Male', '593 Independence Court', 'PO Box 67691', 'San Diego', 'California', 'United States', '92110' FROM dual UNION ALL 

SELECT 59, 'Silva', 'Woodvine', 'swoodvine1m@cisco.com', '7198896797', '23-Jan-1966', 'Female', '915 Melvin Place', '15th Floor', 'Colorado Springs', 'Colorado', 'United States', '80995' FROM dual UNION ALL 

SELECT 60, 'Andras', 'Deelay', 'adeelay1n@oaic.gov.au', '3189671627', '22-May-1944', 'Male', '579 Dapin Parkway', 'Apt 1254', 'Shreveport', 'Louisiana', 'United States', '71151' FROM dual UNION ALL 

SELECT 61, 'Zack', 'Schelle', 'zschelle1o@parallels.com', '2514202689', '14-Jan-1957', 'Male', '5480 Rowland Terrace', '16th Floor', 'Mobile', 'Alabama', 'United States', '36670' FROM dual UNION ALL 

SELECT 62, 'Alexandrina', 'MacNair', 'amacnair1p@reddit.com', '7729341847', '03-Jan-1973', 'Genderqueer', '477 Melby Trail', 'Apt 894', 'Fort Pierce', 'Florida', 'United States', '34981' FROM dual UNION ALL 

SELECT 63, 'Lanie', 'Angear', 'langear1q@reference.com', '3345277958', '07-Mar-1976', 'Female', '8 Welch Way', 'Apt 1344', 'Montgomery', 'Alabama', 'United States', '36134' FROM dual UNION ALL 

SELECT 64, 'Kingsly', 'Chicco', 'kchicco1r@yellowbook.com', '9106177420', '15-Oct-1966', 'Male', '8699 Division Crossing', 'Apt 45', 'Fayetteville', 'North Carolina', 'United States', '28305' FROM dual UNION ALL 

SELECT 65, 'Dwain', 'Verillo', 'dverillo1s@cnet.com', '8132697996', '02-Feb-1944', 'Bigender', '6646 Kropf Avenue', '1st Floor', 'Tampa', 'Florida', 'United States', '33694' FROM dual UNION ALL 

SELECT 66, 'Cheryl', 'Braddon', 'cbraddon1t@lulu.com', '5102969911', '07-Mar-1967', 'Female', '47 Ohio Junction', 'Apt 1849', 'Oakland', 'California', 'United States', '94605' FROM dual UNION ALL 

SELECT 67, 'Kizzee', 'Nason', 'knason1u@github.io', '7143741976', '13-Oct-1963', 'Female', '13278 Butternut Alley', 'Room 1988', 'Orange', 'California', 'United States', '92862' FROM dual UNION ALL 

SELECT 68, 'Durward', 'Eagles', 'deagles1v@walmart.com', '5097074942', '23-Nov-1953', 'Male', '9852 Dryden Place', 'Suite 49', 'Spokane', 'Washington', 'United States', '99210' FROM dual UNION ALL 

SELECT 69, 'Alic', 'Riquet', 'ariquet1w@abc.net.au', '6149771926', '16-Dec-1950', 'Male', '3103 Hoard Place', 'PO Box 41984', 'Columbus', 'Ohio', 'United States', '43231' FROM dual UNION ALL 

SELECT 70, 'Noach', 'Ridsdole', 'nridsdole1x@msn.com', '7025326859', '02-Feb-2001', 'Male', '8 Dennis Hill', '17th Floor', 'Las Vegas', 'Nevada', 'United States', '89105' FROM dual UNION ALL 

SELECT 71, 'Wayne', 'Lygo', 'wlygo1y@nasa.gov', '4106009910', '12-May-1985', 'Male', '94 Bunting Plaza', 'Suite 11', 'Baltimore', 'Maryland', 'United States', '21282' FROM dual UNION ALL 

SELECT 72, 'Kelbee', 'Cowpe', 'kcowpe1z@china.com.cn', '8126222968', '23-Oct-1988', 'Genderfluid', '307 Northfield Center', 'PO Box 37365', 'Evansville', 'Indiana', 'United States', '47725' FROM dual UNION ALL 

SELECT 73, 'Inesita', 'Saberton', 'isaberton20@cbsnews.com', '3606256669', '09-May-1987', 'Non-binary', '6 Bowman Park', 'PO Box 85163', 'Vancouver', 'Washington', 'United States', '98687' FROM dual UNION ALL 

SELECT 74, 'Cyndie', 'Pursglove', 'cpursglove21@psu.edu', '4699326759', '28-May-1999', 'Female', '940 Grayhawk Avenue', 'PO Box 59515', 'Dallas', 'Texas', 'United States', '75205' FROM dual UNION ALL 

SELECT 75, 'Staffard', 'Klassman', 'sklassman22@europa.eu', '5858363784', '19-Jan-1948', 'Male', '6 School Point', 'Room 613', 'Rochester', 'New York', 'United States', '14604' FROM dual UNION ALL 

SELECT 76, 'Heindrick', 'Terrans', 'hterrans23@omniture.com', '6125431386', '30-Oct-1989', 'Male', '9497 Laurel Avenue', 'Apt 614', 'Minneapolis', 'Minnesota', 'United States', '55402' FROM dual UNION ALL 

SELECT 77, 'Dane', 'Widdop', 'dwiddop24@salon.com', '2123332077', '25-Nov-1952', 'Male', '181 Trailsway Alley', '8th Floor', 'Jamaica', 'New York', 'United States', '11431' FROM dual UNION ALL 

SELECT 78, 'Killy', 'Bohden', 'kbohden25@purevolume.com', '7655863303', '15-Nov-1969', 'Male', '787 Monica Plaza', 'Apt 978', 'Crawfordsville', 'Indiana', 'United States', '47937' FROM dual UNION ALL 

SELECT 79, 'Hadlee', 'Denk', 'hdenk26@arizona.edu', '7142326780', '12-Jun-1986', 'Male', '34 Buhler Junction', 'Suite 97', 'Anaheim', 'California', 'United States', '92825' FROM dual UNION ALL 

SELECT 80, 'Burch', 'Bozward', 'bbozward27@economist.com', '2126409928', '02-Jun-1986', 'Male', '327 Elmside Junction', 'Room 273', 'New York City', 'New York', 'United States', '10203' FROM dual UNION ALL 

SELECT 81, 'Etienne', 'Kordt', 'ekordt28@wikimedia.org', '9168989508', '11-Jan-1949', 'Male', '328 Mccormick Road', 'Apt 1608', 'Sacramento', 'California', 'United States', '95818' FROM dual UNION ALL 

SELECT 82, 'Gregoor', 'Longea', 'glongea29@apple.com', '2064667510', '12-Aug-1969', 'Male', '317 Dennis Plaza', 'Apt 1020', 'Seattle', 'Washington', 'United States', '98121' FROM dual UNION ALL 

SELECT 83, 'Andros', 'Ringer', 'aringer2a@cocolog-nifty.com', '9159184623', '18-Jan-1988', 'Male', '64 Aberg Plaza', 'Room 1262', 'El Paso', 'Texas', 'United States', '88569' FROM dual UNION ALL 

SELECT 84, 'Kandace', 'D''Abbot-Doyle', 'kdabbotdoyle2b@microsoft.com', '9413336114', '02-Mar-1982', 'Female', '1 Straubel Place', 'PO Box 86495', 'Sarasota', 'Florida', 'United States', '34233' FROM dual UNION ALL 

SELECT 85, 'Cosetta', 'Izacenko', 'cizacenko2c@marketwatch.com', '5015015411', '09-Nov-1949', 'Female', '608 Sachtjen Hill', 'Apt 818', 'Little Rock', 'Arkansas', 'United States', '72204' FROM dual UNION ALL 

SELECT 86, 'Tallulah', 'Lindberg', 'tlindberg2d@arizona.edu', '9155766274', '11-Oct-1977', 'Female', '78501 Johnson Avenue', 'Suite 42', 'El Paso', 'Texas', 'United States', '88530' FROM dual UNION ALL 

SELECT 87, 'Diane', 'Tozer', 'dtozer2e@europa.eu', '7017105995', '28-Jun-1965', 'Female', '0 Northland Alley', 'Suite 39', 'Grand Forks', 'North Dakota', 'United States', '58207' FROM dual UNION ALL 

SELECT 88, 'Joscelin', 'Burmaster', 'jburmaster2f@cnbc.com', '3036460868', '06-Feb-1943', 'Agender', '13 Eggendart Junction', '18th Floor', 'Denver', 'Colorado', 'United States', '80209' FROM dual UNION ALL 

SELECT 89, 'Timmy', 'Lukasik', 'tlukasik2g@hibu.com', '7166780009', '10-Nov-1950', 'Male', '550 Roth Court', '10th Floor', 'Buffalo', 'New York', 'United States', '14233' FROM dual UNION ALL 

SELECT 90, 'Edgar', 'Scales', 'escales2h@list-manage.com', '4076147745', '15-Nov-1972', 'Male', '78421 Marquette Park', 'Suite 93', 'Orlando', 'Florida', 'United States', '32868' FROM dual UNION ALL 

SELECT 91, 'Ethan', 'O''Currane', 'eocurrane2i@youku.com', '6146543034', '13-Aug-1961', 'Male', '0 Village Avenue', '2nd Floor', 'Columbus', 'Ohio', 'United States', '43226' FROM dual UNION ALL 

SELECT 92, 'Aldrich', 'Pattullo', 'apattullo2j@redcross.org', '4699007650', '23-Jan-1988', 'Male', '5 Parkside Way', 'Apt 867', 'Dallas', 'Texas', 'United States', '75251' FROM dual UNION ALL 

SELECT 93, 'Rustin', 'Rollett', 'rrollett2k@cloudflare.com', '6029172943', '23-Jan-1961', 'Male', '867 Kenwood Junction', 'Room 397', 'Phoenix', 'Arizona', 'United States', '85025' FROM dual UNION ALL 

SELECT 94, 'Pasquale', 'Redfearn', 'predfearn2l@ucsd.edu', '5035518989', '27-Oct-1984', 'Male', '267 South Road', 'Room 825', 'Portland', 'Oregon', 'United States', '97286' FROM dual UNION ALL 

SELECT 95, 'Magda', 'Geoghegan', 'mgeoghegan2m@squarespace.com', '3027578899', '16-May-1986', 'Female', '2 Stang Park', '3rd Floor', 'Wilmington', 'Delaware', 'United States', '19892' FROM dual UNION ALL 

SELECT 96, 'Yuri', 'De Maine', 'ydemaine2n@simplemachines.org', '6519767643', '27-Feb-1957', 'Male', '2 Loftsgordon Junction', 'PO Box 42797', 'Saint Paul', 'Minnesota', 'United States', '55146' FROM dual UNION ALL 

SELECT 97, 'Leoline', 'Kidson', 'lkidson2o@wiley.com', '5127683096', '21-Dec-1961', 'Female', '431 Sutherland Hill', 'Room 595', 'Austin', 'Texas', 'United States', '78778' FROM dual UNION ALL 

SELECT 98, 'Meredithe', 'Berntssen', 'mberntssen2p@theguardian.com', '9415872276', '05-Mar-1979', 'Female', '698 Hudson Crossing', 'Apt 1758', 'Sarasota', 'Florida', 'United States', '34238' FROM dual UNION ALL 

SELECT 99, 'Gawain', 'Bartod', 'gbartod2q@parallels.com', '5855760255', '17-Aug-1960', 'Male', '81 Ruskin Drive', 'Apt 108', 'Rochester', 'New York', 'United States', '14624' FROM dual UNION ALL 

SELECT 100, 'Julius', 'Rosenbusch', 'jrosenbusch2r@fema.gov', '9106935707', '07-Apr-1982', 'Male', '794 Annamark Parkway', '2nd Floor', 'Wilmington', 'North Carolina', 'United States', '28405' FROM dual; 


-- Card_details
INSERT INTO Card_Details (card_id, customer_id, card_no, card_name) 

SELECT 1, 30, '5048372235841679', 'Visa' FROM dual UNION ALL 

SELECT 2, 99, '5108750234616159', 'Dine Club' FROM dual UNION ALL 

SELECT 3, 58, '5108759353568398', 'Dine Club' FROM dual UNION ALL 

SELECT 4, 23, '5108754747552950', 'Dine Club' FROM dual UNION ALL 

SELECT 5, 61, '5048379839994390', 'Visa' FROM dual UNION ALL 

SELECT 6, 20, '5048379602090533', 'Business' FROM dual UNION ALL 

SELECT 7, 79, '5048371490404082', 'Dine Club' FROM dual UNION ALL 

SELECT 8, 9, '5048373446057345', 'Work' FROM dual UNION ALL 

SELECT 9, 7, '5108758924577904', 'Work' FROM dual UNION ALL 

SELECT 10, 40, '5048375916324485', 'Visa' FROM dual UNION ALL 

SELECT 11, 45, '5108754777147689', 'Visa' FROM dual UNION ALL 

SELECT 12, 67, '5048370156266561', 'Visa' FROM dual UNION ALL 

SELECT 13, 40, '5108756405793222', 'Mastercard' FROM dual UNION ALL 

SELECT 14, 33, '5108750119283414', 'Business' FROM dual UNION ALL 

SELECT 15, 82, '5108751227980065', 'Visa' FROM dual UNION ALL 

SELECT 16, 57, '5108757487635737', 'Visa' FROM dual UNION ALL 

SELECT 17, 85, '5108754043561705', 'Visa' FROM dual UNION ALL 

SELECT 18, 68, '5048373887192924', 'Business' FROM dual UNION ALL 

SELECT 19, 56, '5048377662521959', 'Business' FROM dual UNION ALL 

SELECT 20, 68, '5108752623103005', 'Mastercard' FROM dual UNION ALL 

SELECT 21, 18, '5108756225683728', 'Visa' FROM dual UNION ALL 

SELECT 22, 38, '5048372307349908', 'Work' FROM dual UNION ALL 

SELECT 23, 31, '5048374669263297', 'Business' FROM dual UNION ALL 

SELECT 24, 43, '5108758604253370', 'Visa' FROM dual UNION ALL 

SELECT 25, 46, '5108751613920766', 'Amex Business' FROM dual UNION ALL 

SELECT 26, 73, '5108751001199551', 'Dine Club' FROM dual UNION ALL 

SELECT 27, 11, '5108750623057189', 'Personal' FROM dual UNION ALL 

SELECT 28, 72, '5108758078314195', 'Business' FROM dual UNION ALL 

SELECT 29, 59, '5048373657805903', 'Mastercard' FROM dual UNION ALL 

SELECT 30, 95, '5048374478518790', 'Visa' FROM dual UNION ALL 

SELECT 31, 52, '5108758223014385', 'Visa' FROM dual UNION ALL 

SELECT 32, 7, '5108755938307872', 'Visa' FROM dual UNION ALL 

SELECT 33, 43, '5048373328553585', 'Work' FROM dual UNION ALL 

SELECT 34, 86, '5048375695871383', 'Visa' FROM dual UNION ALL 

SELECT 35, 35, '5108758934961700', 'Amex Business' FROM dual UNION ALL 

SELECT 36, 17, '5108755626572241', 'Visa' FROM dual UNION ALL 

SELECT 37, 60, '5048377352246404', 'Business' FROM dual UNION ALL 

SELECT 38, 51, '5048376888439467', 'Work' FROM dual UNION ALL 

SELECT 39, 75, '5048376871757891', 'Amex Business' FROM dual UNION ALL 

SELECT 40, 66, '5108757666780601', 'Mastercard' FROM dual UNION ALL 

SELECT 41, 32, '5048374084952730', 'Amex Business' FROM dual UNION ALL 

SELECT 42, 3, '5108759512492050', 'Business' FROM dual UNION ALL 

SELECT 43, 77, '5108758888278952', 'Visa' FROM dual UNION ALL 

SELECT 44, 30, '5108755111138474', 'Mastercard' FROM dual UNION ALL 

SELECT 45, 80, '5048375820101193', 'Business' FROM dual UNION ALL 

SELECT 46, 44, '5108750886175876', 'Work' FROM dual UNION ALL 

SELECT 47, 92, '5108759467974573', 'Visa' FROM dual UNION ALL 

SELECT 48, 5, '5048374242595223', 'Amex Business' FROM dual UNION ALL 

SELECT 49, 23, '5108751657010342', 'Visa' FROM dual UNION ALL 

SELECT 50, 44, '5108754392488104', 'Work' FROM dual UNION ALL 

SELECT 51, 13, '5048372112263526', 'Mastercard' FROM dual UNION ALL 

SELECT 52, 31, '5048379559211884', 'Work' FROM dual UNION ALL 

SELECT 53, 52, '5048376115311802', 'Business' FROM dual UNION ALL 

SELECT 54, 96, '5048373475466797', 'Visa' FROM dual UNION ALL 

SELECT 55, 13, '5108756544430058', 'Mastercard' FROM dual UNION ALL 

SELECT 56, 39, '5108752197882745', 'Work' FROM dual UNION ALL 

SELECT 57, 27, '5108754062313053', 'Visa' FROM dual UNION ALL 

SELECT 58, 42, '5108757876042941', 'Business' FROM dual UNION ALL 

SELECT 59, 89, '5048371016884668', 'Personal' FROM dual UNION ALL 

SELECT 60, 77, '5108751646390813', 'Dine Club' FROM dual UNION ALL 

SELECT 61, 19, '5108759956574975', 'Visa' FROM dual UNION ALL 

SELECT 62, 64, '5048371412313767', 'Mastercard' FROM dual UNION ALL 

SELECT 63, 19, '5108752613776455', 'Amex Business' FROM dual UNION ALL 

SELECT 64, 26, '5108750623172699', 'Dine Club' FROM dual UNION ALL 

SELECT 65, 46, '5048370468308358', 'Amex Business' FROM dual UNION ALL 

SELECT 66, 39, '5108750142710847', 'Business' FROM dual UNION ALL 

SELECT 67, 13, '5108755046199013', 'Mastercard' FROM dual UNION ALL 

SELECT 68, 50, '5108753007943818', 'Visa' FROM dual UNION ALL 

SELECT 69, 43, '5048376175168613', 'Mastercard' FROM dual UNION ALL 

SELECT 70, 46, '5048370416183010', 'Personal' FROM dual UNION ALL 

SELECT 71, 7, '5048377760389143', 'Personal' FROM dual UNION ALL 

SELECT 72, 73, '5108753220211472', 'Visa' FROM dual UNION ALL 

SELECT 73, 84, '5108751235459995', 'Amex Business' FROM dual UNION ALL 

SELECT 74, 27, '5048379561016180', 'Amex Business' FROM dual UNION ALL 

SELECT 75, 20, '5048373351279009', 'Business' FROM dual UNION ALL 

SELECT 76, 26, '5108756916054924', 'Amex Business' FROM dual UNION ALL 

SELECT 77, 69, '5048376475743073', 'Dine Club' FROM dual UNION ALL 

SELECT 78, 100, '5108758847607390', 'Mastercard' FROM dual UNION ALL 

SELECT 79, 69, '5048371130158924', 'Visa' FROM dual UNION ALL 

SELECT 80, 94, '5108759415961912', 'Business' FROM dual UNION ALL 

SELECT 81, 9, '5108756973730952', 'Visa' FROM dual UNION ALL 

SELECT 82, 46, '5108758637302160', 'Dine Club' FROM dual UNION ALL 

SELECT 83, 49, '5048377075769708', 'Visa' FROM dual UNION ALL 

SELECT 84, 93, '5048370380865253', 'Visa' FROM dual UNION ALL 

SELECT 85, 56, '5108754914402054', 'Visa' FROM dual UNION ALL 

SELECT 86, 90, '5108754809437439', 'Mastercard' FROM dual UNION ALL 

SELECT 87, 20, '5108757985515993', 'Personal' FROM dual UNION ALL 

SELECT 88, 56, '5108751060366422', 'Personal' FROM dual UNION ALL 

SELECT 89, 40, '5108750465692440', 'Visa' FROM dual UNION ALL 

SELECT 90, 25, '5048371885910545', 'Visa' FROM dual UNION ALL 

SELECT 91, 40, '5048374525968410', 'Personal' FROM dual UNION ALL 

SELECT 92, 42, '5048376768365717', 'Mastercard' FROM dual UNION ALL 

SELECT 93, 21, '5048375446384819', 'Work' FROM dual UNION ALL 

SELECT 94, 73, '5108757731003690', 'Business' FROM dual UNION ALL 

SELECT 95, 50, '5048372610702256', 'Personal' FROM dual UNION ALL 

SELECT 96, 34, '5048379747372192', 'Mastercard' FROM dual UNION ALL 

SELECT 97, 79, '5048378310511293', 'Personal' FROM dual UNION ALL 

SELECT 98, 29, '5048370327543542', 'Personal' FROM dual UNION ALL 

SELECT 99, 41, '5108752090876380', 'Dine Club' FROM dual UNION ALL 

SELECT 100, 29, '5108753057132163', 'Visa' FROM dual UNION ALL 

SELECT 101, 90, '5108754350348837', 'Personal' FROM dual UNION ALL 

SELECT 102, 47, '5108756269656986', 'Dine Club' FROM dual UNION ALL 

SELECT 103, 73, '5048374397003627', 'Dine Club' FROM dual UNION ALL 

SELECT 104, 77, '5048371116004936', 'Business' FROM dual UNION ALL 

SELECT 105, 7, '5108752811621081', 'Mastercard' FROM dual UNION ALL 

SELECT 106, 11, '5048377286183814', 'Amex Business' FROM dual UNION ALL 

SELECT 107, 41, '5108754454420425', 'Personal' FROM dual UNION ALL 

SELECT 108, 6, '5048378092358020', 'Dine Club' FROM dual UNION ALL 

SELECT 109, 2, '5048377790564582', 'Visa' FROM dual UNION ALL 

SELECT 110, 49, '5048375245208904', 'Visa' FROM dual UNION ALL 

SELECT 111, 95, '5048373339347043', 'Amex Business' FROM dual UNION ALL 

SELECT 112, 78, '5048375945703329', 'Dine Club' FROM dual UNION ALL 

SELECT 113, 71, '5108753711634331', 'Work' FROM dual UNION ALL 

SELECT 114, 12, '5048375810388701', 'Mastercard' FROM dual UNION ALL 

SELECT 115, 74, '5048372047661513', 'Visa' FROM dual UNION ALL 

SELECT 116, 42, '5108753204599488', 'Mastercard' FROM dual UNION ALL 

SELECT 117, 63, '5108759363584872', 'Personal' FROM dual UNION ALL 

SELECT 118, 37, '5048370426251427', 'Work' FROM dual UNION ALL 

SELECT 119, 77, '5108752679286316', 'Work' FROM dual UNION ALL 

SELECT 120, 2, '5048374569603832', 'Personal' FROM dual UNION ALL 

SELECT 121, 40, '5048375238326598', 'Personal' FROM dual UNION ALL 

SELECT 122, 1, '5108751671678033', 'Personal' FROM dual UNION ALL 

SELECT 123, 17, '5048372626886945', 'Amex Business' FROM dual UNION ALL 

SELECT 124, 8, '5048374639601816', 'Work' FROM dual UNION ALL 

SELECT 125, 61, '5108752514335419', 'Mastercard' FROM dual UNION ALL 

SELECT 126, 32, '5108759216197344', 'Visa' FROM dual UNION ALL 

SELECT 127, 76, '5048377792490265', 'Dine Club' FROM dual UNION ALL 

SELECT 128, 65, '5048377283854268', 'Personal' FROM dual UNION ALL 

SELECT 129, 52, '5048371875203786', 'Amex Business' FROM dual UNION ALL 

SELECT 130, 44, '5048378270114757', 'Visa' FROM dual UNION ALL 

SELECT 131, 67, '5108758906072338', 'Mastercard' FROM dual UNION ALL 

SELECT 132, 60, '5108754224396285', 'Dine Club' FROM dual UNION ALL 

SELECT 133, 67, '5108751224421253', 'Amex Business' FROM dual UNION ALL 

SELECT 134, 60, '5048376561736148', 'Personal' FROM dual UNION ALL 

SELECT 135, 22, '5108753847586009', 'Personal' FROM dual UNION ALL 

SELECT 136, 2, '5108752107148468', 'Business' FROM dual UNION ALL 

SELECT 137, 51, '5048373655582397', 'Work' FROM dual UNION ALL 

SELECT 138, 28, '5108759248567969', 'Mastercard' FROM dual UNION ALL 

SELECT 139, 100, '5048374076350752', 'Amex Business' FROM dual UNION ALL 

SELECT 140, 80, '5108756794805561', 'Mastercard' FROM dual UNION ALL 

SELECT 141, 39, '5108757337694090', 'Visa' FROM dual UNION ALL 

SELECT 142, 74, '5108756665643430', 'Personal' FROM dual UNION ALL 

SELECT 143, 12, '5048373886345762', 'Business' FROM dual UNION ALL 

SELECT 144, 72, '5108752049161827', 'Amex Business' FROM dual UNION ALL 

SELECT 145, 56, '5108751460355322', 'Dine Club' FROM dual UNION ALL 

SELECT 146, 95, '5048370589327444', 'Visa' FROM dual UNION ALL 

SELECT 147, 36, '5048376151117170', 'Visa' FROM dual UNION ALL 

SELECT 148, 60, '5048371658219918', 'Personal' FROM dual UNION ALL 

SELECT 149, 55, '5048375659893001', 'Business' FROM dual UNION ALL 

SELECT 150, 41, '5108750990229908', 'Work' FROM dual UNION ALL 

SELECT 151, 27, '5108757710101077', 'Business' FROM dual UNION ALL 

SELECT 152, 88, '5048373028116006', 'Dine Club' FROM dual UNION ALL 

SELECT 153, 32, '5108751028334777', 'Personal' FROM dual UNION ALL 

SELECT 154, 83, '5108754275539536', 'Personal' FROM dual UNION ALL 

SELECT 155, 49, '5108751716760283', 'Dine Club' FROM dual UNION ALL 

SELECT 156, 20, '5048376316134573', 'Business' FROM dual UNION ALL 

SELECT 157, 69, '5108756843246486', 'Visa' FROM dual UNION ALL 

SELECT 158, 20, '5048378361462743', 'Personal' FROM dual UNION ALL 

SELECT 159, 44, '5108756131060953', 'Mastercard' FROM dual UNION ALL 

SELECT 160, 39, '5108752649194996', 'Personal' FROM dual UNION ALL 

SELECT 161, 40, '5048375574466792', 'Work' FROM dual UNION ALL 

SELECT 162, 91, '5048373873227452', 'Work' FROM dual UNION ALL 

SELECT 163, 85, '5108754274178641', 'Dine Club' FROM dual UNION ALL 

SELECT 164, 51, '5108759150818582', 'Business' FROM dual UNION ALL 

SELECT 165, 41, '5048370495775066', 'Visa' FROM dual UNION ALL 

SELECT 166, 39, '5108750134236470', 'Business' FROM dual UNION ALL 

SELECT 167, 74, '5108759921026820', 'Amex Business' FROM dual UNION ALL 

SELECT 168, 75, '5048373464722085', 'Amex Business' FROM dual UNION ALL 

SELECT 169, 34, '5108752310537945', 'Visa' FROM dual UNION ALL 

SELECT 170, 35, '5108757270475846', 'Business' FROM dual UNION ALL 

SELECT 171, 35, '5108753653157887', 'Work' FROM dual UNION ALL 

SELECT 172, 76, '5108752500442732', 'Amex Business' FROM dual UNION ALL 

SELECT 173, 1, '5048374692431713', 'Personal' FROM dual UNION ALL 

SELECT 174, 92, '5048375469148588', 'Personal' FROM dual UNION ALL 

SELECT 175, 15, '5108755954539309', 'Visa' FROM dual UNION ALL 

SELECT 176, 17, '5048373098446200', 'Mastercard' FROM dual UNION ALL 

SELECT 177, 37, '5108753670033038', 'Amex Business' FROM dual UNION ALL 

SELECT 178, 86, '5108758700195566', 'Business' FROM dual UNION ALL 

SELECT 179, 49, '5108756957622357', 'Business' FROM dual UNION ALL 

SELECT 180, 72, '5108757165153508', 'Visa' FROM dual UNION ALL 

SELECT 181, 100, '5048372852113238', 'Work' FROM dual UNION ALL 

SELECT 182, 88, '5108757655515794', 'Mastercard' FROM dual UNION ALL 

SELECT 183, 23, '5048375264342410', 'Personal' FROM dual UNION ALL 

SELECT 184, 68, '5108750693639411', 'Personal' FROM dual UNION ALL 

SELECT 185, 14, '5048377304401719', 'Amex Business' FROM dual UNION ALL 

SELECT 186, 9, '5048379313467251', 'Dine Club' FROM dual UNION ALL 

SELECT 187, 99, '5048374186045342', 'Visa' FROM dual UNION ALL 

SELECT 188, 56, '5108756894768958', 'Work' FROM dual UNION ALL 

SELECT 189, 4, '5108752567129933', 'Dine Club' FROM dual UNION ALL 

SELECT 190, 29, '5108750814040531', 'Visa' FROM dual UNION ALL 

SELECT 191, 17, '5108752296595073', 'Work' FROM dual UNION ALL 

SELECT 192, 32, '5108757189970101', 'Amex Business' FROM dual UNION ALL 

SELECT 193, 32, '5048370618284459', 'Work' FROM dual UNION ALL 

SELECT 194, 16, '5108750812543973', 'Dine Club' FROM dual UNION ALL 

SELECT 195, 96, '5048371241724648', 'Dine Club' FROM dual UNION ALL 

SELECT 196, 21, '5048374728869852', 'Mastercard' FROM dual UNION ALL 

SELECT 197, 75, '5108753459607341', 'Personal' FROM dual UNION ALL 

SELECT 198, 10, '5048370646450296', 'Visa' FROM dual UNION ALL 

SELECT 199, 36, '5048378949052370', 'Dine Club' FROM dual UNION ALL 

SELECT 200, 52, '5108750863209821', 'Mastercard' FROM dual UNION ALL 

SELECT 201, 72, '5108750073566705', 'Visa' FROM dual UNION ALL 

SELECT 202, 42, '5048376070181356', 'Visa' FROM dual UNION ALL 

SELECT 203, 100, '5108758392388040', 'Mastercard' FROM dual UNION ALL 

SELECT 204, 92, '5108750819982448', 'Dine Club' FROM dual UNION ALL 

SELECT 205, 64, '5048371858155557', 'Mastercard' FROM dual UNION ALL 

SELECT 206, 48, '5108750234631208', 'Business' FROM dual UNION ALL 

SELECT 207, 44, '5048378212494291', 'Business' FROM dual UNION ALL 

SELECT 208, 2, '5108751087712780', 'Visa' FROM dual UNION ALL 

SELECT 209, 11, '5048379721890607', 'Dine Club' FROM dual UNION ALL 

SELECT 210, 41, '5048374686279052', 'Dine Club' FROM dual UNION ALL 

SELECT 211, 91, '5048376632158009', 'Personal' FROM dual UNION ALL 

SELECT 212, 34, '5048379905929379', 'Visa' FROM dual UNION ALL 

SELECT 213, 79, '5048371875919506', 'Amex Business' FROM dual UNION ALL 

SELECT 214, 40, '5108751313277798', 'Amex Business' FROM dual UNION ALL 

SELECT 215, 96, '5108753032437794', 'Visa' FROM dual UNION ALL 

SELECT 216, 68, '5048372571326244', 'Visa' FROM dual UNION ALL 

SELECT 217, 47, '5048379205218317', 'Work' FROM dual UNION ALL 

SELECT 218, 51, '5048373826663464', 'Amex Business' FROM dual UNION ALL 

SELECT 219, 38, '5048378263691605', 'Business' FROM dual UNION ALL 

SELECT 220, 48, '5048376718786236', 'Business' FROM dual UNION ALL 

SELECT 221, 82, '5048373671612251', 'Personal' FROM dual UNION ALL 

SELECT 222, 6, '5108757241142517', 'Business' FROM dual UNION ALL 

SELECT 223, 81, '5048377137233420', 'Work' FROM dual UNION ALL 

SELECT 224, 5, '5108759362262181', 'Mastercard' FROM dual UNION ALL 

SELECT 225, 66, '5108758511060579', 'Visa' FROM dual UNION ALL 

SELECT 226, 5, '5048373050626203', 'Business' FROM dual UNION ALL 

SELECT 227, 13, '5048379252444360', 'Amex Business' FROM dual UNION ALL 

SELECT 228, 48, '5108751289597120', 'Amex Business' FROM dual UNION ALL 

SELECT 229, 48, '5048374697263491', 'Work' FROM dual UNION ALL 

SELECT 230, 1, '5108754665529980', 'Visa' FROM dual UNION ALL 

SELECT 231, 28, '5048378255706486', 'Business' FROM dual UNION ALL 

SELECT 232, 37, '5048377105517853', 'Personal' FROM dual UNION ALL 

SELECT 233, 85, '5048379545715824', 'Visa' FROM dual UNION ALL 

SELECT 234, 40, '5048378066921977', 'Dine Club' FROM dual UNION ALL 

SELECT 235, 54, '5048370021089115', 'Visa' FROM dual UNION ALL 

SELECT 236, 48, '5108752471139945', 'Work' FROM dual UNION ALL 

SELECT 237, 37, '5048377042521927', 'Dine Club' FROM dual UNION ALL 

SELECT 238, 35, '5108756969674875', 'Amex Business' FROM dual UNION ALL 

SELECT 239, 58, '5108756238231077', 'Visa' FROM dual UNION ALL 

SELECT 240, 34, '5048370376656609', 'Mastercard' FROM dual UNION ALL 

SELECT 241, 46, '5108755972704406', 'Mastercard' FROM dual UNION ALL 

SELECT 242, 45, '5108753159611783', 'Personal' FROM dual UNION ALL 

SELECT 243, 86, '5108757940752152', 'Business' FROM dual UNION ALL 

SELECT 244, 8, '5048376776998269', 'Business' FROM dual UNION ALL 

SELECT 245, 60, '5108751051235511', 'Visa' FROM dual UNION ALL 

SELECT 246, 24, '5048375675184229', 'Business' FROM dual UNION ALL 

SELECT 247, 39, '5048374403864905', 'Visa' FROM dual UNION ALL 

SELECT 248, 71, '5108758419651289', 'Visa' FROM dual UNION ALL 

SELECT 249, 49, '5108754415751330', 'Personal' FROM dual UNION ALL 

SELECT 250, 100, '5108755805700241', 'Amex Business' FROM dual UNION ALL 

SELECT 251, 61, '5108750085414811', 'Business' FROM dual UNION ALL 

SELECT 252, 41, '5048377638866041', 'Personal' FROM dual UNION ALL 

SELECT 253, 8, '5108759922149993', 'Visa' FROM dual UNION ALL 

SELECT 254, 46, '5048376118036570', 'Personal' FROM dual UNION ALL 

SELECT 255, 99, '5108754983776800', 'Business' FROM dual UNION ALL 

SELECT 256, 96, '5108757391671380', 'Visa' FROM dual UNION ALL 

SELECT 257, 32, '5048372344659806', 'Mastercard' FROM dual UNION ALL 

SELECT 258, 22, '5048377487050184', 'Work' FROM dual UNION ALL 

SELECT 259, 9, '5108751171750787', 'Work' FROM dual UNION ALL 

SELECT 260, 17, '5108753867010831', 'Visa' FROM dual UNION ALL 

SELECT 261, 80, '5108751191557808', 'Personal' FROM dual UNION ALL 

SELECT 262, 91, '5108757394651652', 'Mastercard' FROM dual UNION ALL 

SELECT 263, 36, '5108751601490715', 'Visa' FROM dual UNION ALL 

SELECT 264, 48, '5048376123146737', 'Work' FROM dual UNION ALL 

SELECT 265, 35, '5108750602703217', 'Amex Business' FROM dual UNION ALL 

SELECT 266, 96, '5108752020608085', 'Visa' FROM dual UNION ALL 

SELECT 267, 92, '5048376168962196', 'Work' FROM dual UNION ALL 

SELECT 268, 80, '5048378702711576', 'Mastercard' FROM dual UNION ALL 

SELECT 269, 60, '5108750705731412', 'Visa' FROM dual UNION ALL 

SELECT 270, 32, '5048375268356465', 'Visa' FROM dual UNION ALL 

SELECT 271, 11, '5108757153146316', 'Dine Club' FROM dual UNION ALL 

SELECT 272, 95, '5108755627329484', 'Mastercard' FROM dual UNION ALL 

SELECT 273, 78, '5108759581901072', 'Visa' FROM dual UNION ALL 

SELECT 274, 98, '5048376202986482', 'Work' FROM dual UNION ALL 

SELECT 275, 65, '5108758984951759', 'Work' FROM dual UNION ALL 

SELECT 276, 65, '5108750002755619', 'Dine Club' FROM dual UNION ALL 

SELECT 277, 74, '5048379732017893', 'Visa' FROM dual UNION ALL 

SELECT 278, 6, '5108755443119705', 'Visa' FROM dual UNION ALL 

SELECT 279, 14, '5108754874700802', 'Visa' FROM dual UNION ALL 

SELECT 280, 38, '5048379157919359', 'Work' FROM dual UNION ALL 

SELECT 281, 52, '5108756266261384', 'Visa' FROM dual UNION ALL 

SELECT 282, 28, '5108752862908494', 'Dine Club' FROM dual UNION ALL 

SELECT 283, 41, '5048375623146197', 'Visa' FROM dual UNION ALL 

SELECT 284, 9, '5108758377123578', 'Mastercard' FROM dual UNION ALL 

SELECT 285, 26, '5108757533270786', 'Visa' FROM dual UNION ALL 

SELECT 286, 85, '5108758672834176', 'Personal' FROM dual UNION ALL 

SELECT 287, 79, '5108750601152523', 'Amex Business' FROM dual UNION ALL 

SELECT 288, 28, '5048378828337926', 'Business' FROM dual UNION ALL 

SELECT 289, 57, '5108756162769548', 'Amex Business' FROM dual UNION ALL 

SELECT 290, 22, '5108757789833501', 'Visa' FROM dual UNION ALL 

SELECT 291, 72, '5048375651533241', 'Personal' FROM dual UNION ALL 

SELECT 292, 14, '5108759004873833', 'Mastercard' FROM dual UNION ALL 

SELECT 293, 81, '5108752074926656', 'Dine Club' FROM dual UNION ALL 

SELECT 294, 74, '5108759323813528', 'Visa' FROM dual UNION ALL 

SELECT 295, 62, '5108758746299695', 'Amex Business' FROM dual UNION ALL 

SELECT 296, 82, '5048379107568488', 'Work' FROM dual UNION ALL 

SELECT 297, 99, '5048378357771438', 'Visa' FROM dual UNION ALL 

SELECT 298, 1, '5048370637343757', 'Visa' FROM dual UNION ALL 

SELECT 299, 33, '5048370271302770', 'Business' FROM dual UNION ALL 

SELECT 300, 32, '5108757894136386', 'Amex Business' FROM dual UNION ALL 

SELECT 301, 39, '5048379852310870', 'Work' FROM dual UNION ALL 

SELECT 302, 47, '5048373165753009', 'Dine Club' FROM dual UNION ALL 

SELECT 303, 41, '5108756816309741', 'Visa' FROM dual UNION ALL 

SELECT 304, 44, '5108752048937524', 'Amex Business' FROM dual UNION ALL 

SELECT 305, 10, '5108754926555675', 'Work' FROM dual UNION ALL 

SELECT 306, 24, '5048376516050488', 'Work' FROM dual UNION ALL 

SELECT 307, 85, '5048370174524736', 'Dine Club' FROM dual UNION ALL 

SELECT 308, 13, '5048378112827103', 'Visa' FROM dual UNION ALL 

SELECT 309, 47, '5108757162661438', 'Amex Business' FROM dual UNION ALL 

SELECT 310, 97, '5108754272805500', 'Mastercard' FROM dual UNION ALL 

SELECT 311, 28, '5108756924884817', 'Mastercard' FROM dual UNION ALL 

SELECT 312, 63, '5108750751824095', 'Business' FROM dual UNION ALL 

SELECT 313, 69, '5048374732158995', 'Business' FROM dual UNION ALL 

SELECT 314, 53, '5048371821706833', 'Visa' FROM dual UNION ALL 

SELECT 315, 52, '5048373073091609', 'Work' FROM dual UNION ALL 

SELECT 316, 64, '5108756061893563', 'Personal' FROM dual UNION ALL 

SELECT 317, 87, '5108758436256401', 'Dine Club' FROM dual UNION ALL 

SELECT 318, 17, '5108755280946616', 'Business' FROM dual UNION ALL 

SELECT 319, 17, '5048379644961451', 'Visa' FROM dual UNION ALL 

SELECT 320, 41, '5048378055926052', 'Mastercard' FROM dual UNION ALL 

SELECT 321, 33, '5048374122918958', 'Visa' FROM dual UNION ALL 

SELECT 322, 36, '5048375767535023', 'Amex Business' FROM dual UNION ALL 

SELECT 323, 14, '5108752538624954', 'Mastercard' FROM dual UNION ALL 

SELECT 324, 25, '5048372797945017', 'Personal' FROM dual UNION ALL 

SELECT 325, 95, '5108750699176913', 'Amex Business' FROM dual UNION ALL 

SELECT 326, 76, '5108754879233981', 'Work' FROM dual UNION ALL 

SELECT 327, 89, '5048379674827952', 'Business' FROM dual UNION ALL 

SELECT 328, 55, '5108753690236710', 'Personal' FROM dual UNION ALL 

SELECT 329, 90, '5048373680731811', 'Dine Club' FROM dual UNION ALL 

SELECT 330, 7, '5108750657987749', 'Visa' FROM dual UNION ALL 

SELECT 331, 74, '5108753707102616', 'Visa' FROM dual UNION ALL 

SELECT 332, 34, '5108750203346739', 'Business' FROM dual UNION ALL 

SELECT 333, 18, '5048377114678936', 'Personal' FROM dual UNION ALL 

SELECT 334, 55, '5048373504581251', 'Personal' FROM dual UNION ALL 

SELECT 335, 25, '5108755312895963', 'Business' FROM dual UNION ALL 

SELECT 336, 99, '5048371846375259', 'Amex Business' FROM dual UNION ALL 

SELECT 337, 9, '5048376723029515', 'Work' FROM dual UNION ALL 

SELECT 338, 9, '5108755148222473', 'Work' FROM dual UNION ALL 

SELECT 339, 38, '5108755948048292', 'Visa' FROM dual UNION ALL 

SELECT 340, 86, '5108754112423258', 'Work' FROM dual UNION ALL 

SELECT 341, 84, '5048379904592491', 'Work' FROM dual UNION ALL 

SELECT 342, 95, '5048377089080753', 'Visa' FROM dual UNION ALL 

SELECT 343, 16, '5108759036206796', 'Visa' FROM dual UNION ALL 

SELECT 344, 59, '5048374762109991', 'Work' FROM dual UNION ALL 

SELECT 345, 26, '5108751036534830', 'Amex Business' FROM dual UNION ALL 

SELECT 346, 63, '5048375688512218', 'Amex Business' FROM dual UNION ALL 

SELECT 347, 28, '5048370284806270', 'Amex Business' FROM dual UNION ALL 

SELECT 348, 69, '5108757785516431', 'Amex Business' FROM dual UNION ALL 

SELECT 349, 43, '5108756976022191', 'Business' FROM dual UNION ALL 

SELECT 350, 15, '5108754789272863', 'Personal' FROM dual UNION ALL 

SELECT 351, 7, '5048372376104689', 'Amex Business' FROM dual UNION ALL 

SELECT 352, 16, '5048377128839714', 'Visa' FROM dual UNION ALL 

SELECT 353, 37, '5048376834722131', 'Visa' FROM dual UNION ALL 

SELECT 354, 26, '5108759382732494', 'Amex Business' FROM dual UNION ALL 

SELECT 355, 36, '5108753991515564', 'Visa' FROM dual UNION ALL 

SELECT 356, 44, '5108753510162302', 'Work' FROM dual UNION ALL 

SELECT 357, 6, '5048377928494595', 'Work' FROM dual UNION ALL 

SELECT 358, 34, '5048375609271092', 'Visa' FROM dual UNION ALL 

SELECT 359, 22, '5048374205879671', 'Dine Club' FROM dual UNION ALL 

SELECT 360, 41, '5108755186542857', 'Business' FROM dual UNION ALL 

SELECT 361, 45, '5108756205859769', 'Amex Business' FROM dual UNION ALL 

SELECT 362, 38, '5108751334305172', 'Work' FROM dual UNION ALL 

SELECT 363, 32, '5108759394520929', 'Work' FROM dual UNION ALL 

SELECT 364, 73, '5108755278817969', 'Mastercard' FROM dual UNION ALL 

SELECT 365, 54, '5048377727792777', 'Visa' FROM dual UNION ALL 

SELECT 366, 8, '5048374985502725', 'Dine Club' FROM dual UNION ALL 

SELECT 367, 94, '5108758722357467', 'Work' FROM dual UNION ALL 

SELECT 368, 41, '5048375300856597', 'Mastercard' FROM dual UNION ALL 

SELECT 369, 89, '5048372622039804', 'Dine Club' FROM dual UNION ALL 

SELECT 370, 86, '5048373837606007', 'Business' FROM dual UNION ALL 

SELECT 371, 1, '5108753126462807', 'Dine Club' FROM dual UNION ALL 

SELECT 372, 8, '5108757731910217', 'Business' FROM dual UNION ALL 

SELECT 373, 12, '5108753943713457', 'Visa' FROM dual UNION ALL 

SELECT 374, 24, '5048372714052921', 'Business' FROM dual UNION ALL 

SELECT 375, 16, '5108754038705895', 'Dine Club' FROM dual UNION ALL 

SELECT 376, 31, '5048379700764211', 'Visa' FROM dual UNION ALL 

SELECT 377, 60, '5048375654986305', 'Business' FROM dual UNION ALL 

SELECT 378, 8, '5048377958910866', 'Dine Club' FROM dual UNION ALL 

SELECT 379, 31, '5108758496115281', 'Work' FROM dual UNION ALL 

SELECT 380, 36, '5108757266488696', 'Work' FROM dual UNION ALL 

SELECT 381, 30, '5048374449661349', 'Personal' FROM dual UNION ALL 

SELECT 382, 68, '5108753080281623', 'Amex Business' FROM dual UNION ALL 

SELECT 383, 73, '5108755175596922', 'Work' FROM dual UNION ALL 

SELECT 384, 68, '5048376720826889', 'Personal' FROM dual UNION ALL 

SELECT 385, 32, '5108754613061888', 'Business' FROM dual UNION ALL 

SELECT 386, 95, '5048377017047643', 'Business' FROM dual UNION ALL 

SELECT 387, 94, '5048374309852665', 'Amex Business' FROM dual UNION ALL 

SELECT 388, 67, '5108753888298282', 'Visa' FROM dual UNION ALL 

SELECT 389, 2, '5048379258605188', 'Business' FROM dual UNION ALL 

SELECT 390, 9, '5108755174586676', 'Amex Business' FROM dual UNION ALL 

SELECT 391, 38, '5048376630142799', 'Work' FROM dual UNION ALL 

SELECT 392, 44, '5048370381493501', 'Business' FROM dual UNION ALL 

SELECT 393, 12, '5108758133510142', 'Work' FROM dual UNION ALL 

SELECT 394, 43, '5108759198453921', 'Mastercard' FROM dual UNION ALL 

SELECT 395, 28, '5108752152384851', 'Dine Club' FROM dual UNION ALL 

SELECT 396, 29, '5108754383591445', 'Mastercard' FROM dual UNION ALL 

SELECT 397, 16, '5108759972046396', 'Work' FROM dual UNION ALL 

SELECT 398, 19, '5108753912759077', 'Visa' FROM dual UNION ALL 

SELECT 399, 41, '5108751200066247', 'Work' FROM dual UNION ALL 

SELECT 400, 89, '5048378527433562', 'Business' FROM dual UNION ALL 

SELECT 401, 22, '5108750413127887', 'Work' FROM dual UNION ALL 

SELECT 402, 20, '5048378005643450', 'Personal' FROM dual UNION ALL 

SELECT 403, 69, '5108752136930423', 'Business' FROM dual UNION ALL 

SELECT 404, 97, '5048373670801178', 'Visa' FROM dual UNION ALL 

SELECT 405, 70, '5048378427908473', 'Work' FROM dual UNION ALL 

SELECT 406, 25, '5048372339757656', 'Business' FROM dual UNION ALL 

SELECT 407, 75, '5048378326405282', 'Mastercard' FROM dual UNION ALL 

SELECT 408, 23, '5108756571209292', 'Mastercard' FROM dual UNION ALL 

SELECT 409, 32, '5048376002726252', 'Work' FROM dual UNION ALL 

SELECT 410, 4, '5048378134868010', 'Visa' FROM dual UNION ALL 

SELECT 411, 45, '5108756315687639', 'Visa' FROM dual UNION ALL 

SELECT 412, 24, '5108750328192414', 'Personal' FROM dual UNION ALL 

SELECT 413, 35, '5108750253564546', 'Amex Business' FROM dual UNION ALL 

SELECT 414, 45, '5108751312584335', 'Visa' FROM dual UNION ALL 

SELECT 415, 35, '5048374276852128', 'Amex Business' FROM dual UNION ALL 

SELECT 416, 1, '5108754009384118', 'Work' FROM dual UNION ALL 

SELECT 417, 31, '5048372874824622', 'Dine Club' FROM dual UNION ALL 

SELECT 418, 21, '5048371496126556', 'Dine Club' FROM dual UNION ALL 

SELECT 419, 80, '5048377549633084', 'Work' FROM dual UNION ALL 

SELECT 420, 47, '5048375622788197', 'Mastercard' FROM dual UNION ALL 

SELECT 421, 69, '5108752864152646', 'Visa' FROM dual UNION ALL 

SELECT 422, 73, '5048376597928180', 'Business' FROM dual UNION ALL 

SELECT 423, 43, '5048378149230412', 'Business' FROM dual UNION ALL 

SELECT 424, 1, '5048371188282816', 'Mastercard' FROM dual UNION ALL 

SELECT 425, 70, '5048374977346727', 'Personal' FROM dual UNION ALL 

SELECT 426, 3, '5048376507513668', 'Visa' FROM dual UNION ALL 

SELECT 427, 34, '5048371494645623', 'Amex Business' FROM dual UNION ALL 

SELECT 428, 30, '5108750167864826', 'Work' FROM dual UNION ALL 

SELECT 429, 53, '5048372110189228', 'Visa' FROM dual UNION ALL 

SELECT 430, 77, '5048377240651765', 'Visa' FROM dual UNION ALL 

SELECT 431, 52, '5048371350181366', 'Visa' FROM dual UNION ALL 

SELECT 432, 99, '5108757561400503', 'Business' FROM dual UNION ALL 

SELECT 433, 9, '5108753280268859', 'Mastercard' FROM dual UNION ALL 

SELECT 434, 36, '5108755293632682', 'Visa' FROM dual UNION ALL 

SELECT 435, 95, '5108750069928554', 'Dine Club' FROM dual UNION ALL 

SELECT 436, 76, '5048370187002167', 'Personal' FROM dual UNION ALL 

SELECT 437, 78, '5108752131617678', 'Amex Business' FROM dual UNION ALL 

SELECT 438, 45, '5048372407677935', 'Personal' FROM dual UNION ALL 

SELECT 439, 13, '5108755055345481', 'Mastercard' FROM dual UNION ALL 

SELECT 440, 20, '5108755604790864', 'Amex Business' FROM dual UNION ALL 

SELECT 441, 86, '5108754491576601', 'Dine Club' FROM dual UNION ALL 

SELECT 442, 36, '5048378828154834', 'Visa' FROM dual UNION ALL 

SELECT 443, 90, '5048371669446351', 'Work' FROM dual UNION ALL 

SELECT 444, 68, '5108750783712441', 'Mastercard' FROM dual UNION ALL 

SELECT 445, 83, '5048376035469458', 'Work' FROM dual UNION ALL 

SELECT 446, 77, '5108755847935136', 'Personal' FROM dual UNION ALL 

SELECT 447, 12, '5048378519037231', 'Amex Business' FROM dual UNION ALL 

SELECT 448, 13, '5048371040722256', 'Visa' FROM dual UNION ALL 

SELECT 449, 44, '5108754835398290', 'Visa' FROM dual UNION ALL 

SELECT 450, 86, '5048377115469681', 'Business' FROM dual; 

-- orders
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (1, 15, '20-Jan-2023', '28-Feb-2023', 33, 44, 29, 304, 'in_progress', 7729, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (2, 23, '14-Jan-2023', '09-Mar-2023', 44, 4, 63, 409, 'cancelled', 3794, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (3, 9, '14-Jan-2023', '28-Mar-2023', 5, 5, 55, 371, 'cancelled', 3252, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (4, 37, '26-Jan-2023', '01-Feb-2023', 16, 18, 28, 185, 'confirmed', 3604, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (5, 46, '01-Jan-2023', '15-Feb-2023', 50, 22, 42, 284, 'completed', 446, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (6, 33, '18-Jan-2023', '12-Mar-2023', 47, 49, 24, 95, 'completed', 1587, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (7, 22, '22-Jan-2023', '30-Mar-2023', 48, 43, 61, 299, 'in_progress', 3127, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (8, 2, '20-Jan-2023', '18-Feb-2023', 35, 17, 25, 1, 'cancelled', 7264, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (9, 23, '26-Jan-2023', '10-Mar-2023', 5, 11, 10, 26, 'completed', 5303, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (10, 48, '14-Jan-2023', '28-Feb-2023', 49, 34, 11, 102, 'cancelled', 3248, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (11, 16, '19-Jan-2023', '14-Feb-2023', 40, 2, 6, 29, 'cancelled', 1212, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (12, 19, '12-Jan-2023', '21-Feb-2023', 50, 49, 29, 150, 'confirmed', 3212, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (13, 46, '28-Jan-2023', '05-Mar-2023', 47, 39, 32, 215, 'confirmed', 4272, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (14, 39, '20-Jan-2023', '08-Mar-2023', 5, 5, 56, 40, 'cancelled', 6277, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (15, 28, '24-Jan-2023', '09-Mar-2023', 13, 26, 27, 294, 'cancelled', 9945, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (16, 32, '10-Jan-2023', '25-Feb-2023', 10, 25, 6, 151, 'cancelled', 5143, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (17, 49, '19-Jan-2023', '03-Mar-2023', 32, 19, 55, 186, 'completed', 8001, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (18, 47, '28-Jan-2023', '12-Mar-2023', 4, 2, 50, 168, 'cancelled', 9193, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (19, 37, '12-Jan-2023', '07-Mar-2023', 20, 21, 14, 381, 'cancelled', 2223, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (20, 40, '29-Jan-2023', '09-Feb-2023', 23, 46, 55, 12, 'completed', 8872, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (21, 4, '19-Jan-2023', '22-Mar-2023', 21, 40, 14, 401, 'confirmed', 7180, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (22, 4, '18-Jan-2023', '11-Mar-2023', 2, 44, 39, 378, 'completed', 8354, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (23, 44, '27-Jan-2023', '08-Mar-2023', 23, 14, 2, 447, 'completed', 6426, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (24, 22, '10-Jan-2023', '12-Mar-2023', 12, 7, 1, 92, 'cancelled', 4959, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (25, 23, '10-Jan-2023', '10-Mar-2023', 19, 11, 22, 122, 'confirmed', 4158, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (26, 44, '15-Jan-2023', '22-Feb-2023', 34, 13, 47, 442, 'completed', 1733, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (27, 31, '12-Jan-2023', '04-Mar-2023', 29, 44, 15, 241, 'completed', 2545, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (28, 14, '02-Jan-2023', '26-Mar-2023', 40, 35, 57, 283, 'cancelled', 136, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (29, 23, '08-Jan-2023', '06-Mar-2023', 4, 10, 14, 84, 'confirmed', 7475, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (30, 15, '08-Jan-2023', '14-Feb-2023', 22, 40, 46, 88, 'completed', 2288, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (31, 43, '18-Jan-2023', '14-Feb-2023', 18, 14, 66, 266, 'confirmed', 9678, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (32, 22, '10-Jan-2023', '04-Feb-2023', 21, 2, 14, 119, 'cancelled', 3651, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (33, 37, '20-Jan-2023', '27-Mar-2023', 12, 14, 70, 371, 'in_progress', 913, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (34, 19, '23-Jan-2023', '12-Feb-2023', 37, 35, 60, 283, 'confirmed', 6288, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (35, 39, '21-Jan-2023', '20-Feb-2023', 29, 34, 64, 429, 'completed', 2222, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (36, 13, '01-Jan-2023', '30-Mar-2023', 45, 29, 70, 159, 'cancelled', 491, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (37, 48, '27-Jan-2023', '24-Mar-2023', 6, 13, 51, 419, 'completed', 3152, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (38, 23, '18-Jan-2023', '18-Feb-2023', 24, 44, 29, 353, 'completed', 1855, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (39, 36, '07-Jan-2023', '09-Feb-2023', 26, 37, 52, 244, 'cancelled', 1045, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (40, 17, '13-Jan-2023', '28-Feb-2023', 31, 31, 1, 280, 'confirmed', 9100, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (41, 32, '23-Jan-2023', '27-Mar-2023', 32, 23, 73, 437, 'completed', 7319, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (42, 36, '25-Jan-2023', '19-Mar-2023', 11, 50, 22, 325, 'cancelled', 5649, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (43, 2, '14-Jan-2023', '19-Mar-2023', 13, 12, 30, 59, 'confirmed', 2219, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (44, 32, '11-Jan-2023', '01-Mar-2023', 39, 37, 72, 433, 'confirmed', 799, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (45, 31, '08-Jan-2023', '07-Mar-2023', 4, 33, 46, 98, 'completed', 2572, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (46, 26, '08-Jan-2023', '14-Mar-2023', 12, 32, 19, 424, 'completed', 4332, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (47, 47, '27-Jan-2023', '12-Feb-2023', 47, 45, 21, 377, 'completed', 1400, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (48, 37, '12-Jan-2023', '26-Feb-2023', 30, 48, 25, 9, 'cancelled', 4385, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (49, 48, '10-Jan-2023', '07-Feb-2023', 14, 41, 46, 38, 'confirmed', 5027, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (50, 49, '15-Jan-2023', '07-Mar-2023', 8, 41, 45, 285, 'in_progress', 8916, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (51, 31, '25-Jan-2023', '25-Feb-2023', 45, 9, 30, 134, 'confirmed', 5222, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (52, 27, '17-Jan-2023', '22-Feb-2023', 11, 50, 5, 362, 'confirmed', 2714, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (53, 24, '27-Jan-2023', '28-Feb-2023', 34, 3, 43, 208, 'cancelled', 8148, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (54, 37, '21-Jan-2023', '24-Mar-2023', 27, 21, 61, 149, 'confirmed', 9324, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (55, 10, '15-Jan-2023', '07-Mar-2023', 1, 39, 3, 6, 'confirmed', 3176, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (56, 27, '08-Jan-2023', '13-Mar-2023', 36, 6, 5, 337, 'in_progress', 2560, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (57, 3, '08-Jan-2023', '04-Feb-2023', 37, 22, 44, 159, 'cancelled', 9429, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (58, 21, '20-Jan-2023', '04-Feb-2023', 6, 26, 1, 252, 'cancelled', 9738, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (59, 40, '05-Jan-2023', '18-Mar-2023', 45, 17, 69, 331, 'in_progress', 1557, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (60, 43, '14-Jan-2023', '18-Feb-2023', 44, 11, 30, 225, 'completed', 4420, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (61, 25, '03-Jan-2023', '07-Mar-2023', 37, 37, 4, 187, 'completed', 5181, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (62, 32, '28-Jan-2023', '10-Mar-2023', 40, 26, 39, 135, 'cancelled', 3665, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (63, 3, '26-Jan-2023', '20-Mar-2023', 36, 38, 12, 442, 'completed', 7461, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (64, 21, '30-Jan-2023', '04-Feb-2023', 26, 50, 37, 149, 'cancelled', 2174, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (65, 45, '04-Jan-2023', '05-Feb-2023', 41, 11, 28, 387, 'completed', 4887, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (66, 4, '07-Jan-2023', '04-Feb-2023', 10, 48, 51, 409, 'confirmed', 3470, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (67, 15, '26-Jan-2023', '15-Mar-2023', 41, 36, 75, 216, 'confirmed', 2854, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (68, 39, '28-Jan-2023', '19-Feb-2023', 16, 48, 64, 29, 'completed', 7503, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (69, 30, '23-Jan-2023', '07-Mar-2023', 21, 47, 60, 183, 'completed', 5136, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (70, 22, '21-Jan-2023', '18-Feb-2023', 24, 44, 44, 386, 'confirmed', 7578, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (71, 44, '07-Jan-2023', '06-Feb-2023', 42, 26, 30, 26, 'cancelled', 8793, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (72, 49, '19-Jan-2023', '28-Mar-2023', 15, 24, 19, 312, 'in_progress', 598, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (73, 26, '17-Jan-2023', '24-Mar-2023', 48, 7, 2, 169, 'completed', 8809, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (74, 33, '24-Jan-2023', '07-Mar-2023', 41, 10, 13, 55, 'completed', 1210, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (75, 47, '18-Jan-2023', '02-Mar-2023', 3, 25, 8, 370, 'in_progress', 3008, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (76, 40, '09-Jan-2023', '20-Mar-2023', 30, 10, 29, 293, 'confirmed', 5740, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (77, 30, '08-Jan-2023', '07-Mar-2023', 43, 33, 56, 435, 'confirmed', 5725, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (78, 1, '29-Jan-2023', '24-Feb-2023', 23, 12, 19, 204, 'confirmed', 3339, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (79, 50, '24-Jan-2023', '16-Mar-2023', 11, 11, 70, 145, 'cancelled', 5971, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (80, 12, '02-Jan-2023', '30-Mar-2023', 15, 11, 27, 183, 'cancelled', 6322, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (81, 23, '15-Jan-2023', '27-Mar-2023', 41, 47, 66, 387, 'cancelled', 984, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (82, 6, '15-Jan-2023', '08-Mar-2023', 43, 22, 52, 75, 'completed', 8114, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (83, 30, '24-Jan-2023', '23-Feb-2023', 6, 5, 62, 111, 'completed', 4164, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (84, 46, '23-Jan-2023', '18-Feb-2023', 8, 37, 18, 270, 'confirmed', 2405, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (85, 22, '03-Jan-2023', '14-Feb-2023', 10, 1, 19, 89, 'completed', 3758, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (86, 20, '27-Jan-2023', '01-Mar-2023', 27, 31, 61, 92, 'confirmed', 5769, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (87, 13, '23-Jan-2023', '08-Mar-2023', 23, 2, 19, 134, 'cancelled', 4714, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (88, 29, '11-Jan-2023', '28-Feb-2023', 38, 42, 49, 276, 'completed', 8610, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (89, 25, '16-Jan-2023', '30-Mar-2023', 43, 7, 7, 329, 'confirmed', 5776, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (90, 32, '05-Jan-2023', '24-Mar-2023', 37, 23, 22, 300, 'confirmed', 6205, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (91, 3, '05-Jan-2023', '01-Feb-2023', 22, 45, 55, 13, 'completed', 1153, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (92, 22, '10-Jan-2023', '26-Feb-2023', 10, 50, 41, 345, 'confirmed', 2165, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (93, 32, '20-Jan-2023', '26-Mar-2023', 2, 21, 73, 264, 'completed', 6540, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (94, 6, '10-Jan-2023', '17-Mar-2023', 6, 43, 27, 14, 'completed', 1555, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (95, 28, '09-Jan-2023', '27-Feb-2023', 33, 6, 65, 137, 'in_progress', 3736, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (96, 39, '21-Jan-2023', '21-Feb-2023', 46, 1, 14, 292, 'in_progress', 8927, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (97, 26, '29-Jan-2023', '07-Mar-2023', 32, 44, 39, 356, 'completed', 4639, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (98, 36, '12-Jan-2023', '28-Feb-2023', 35, 49, 38, 421, 'in_progress', 4618, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (99, 18, '01-Jan-2023', '17-Mar-2023', 14, 22, 61, 267, 'confirmed', 1884, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (100, 30, '18-Jan-2023', '18-Feb-2023', 45, 15, 44, 64, 'cancelled', 2348, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (101, 45, '26-Jan-2023', '23-Feb-2023', 18, 9, 13, 68, 'confirmed', 7491, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (102, 6, '30-Jan-2023', '26-Feb-2023', 46, 38, 51, 128, 'in_progress', 6486, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (103, 5, '14-Jan-2023', '15-Feb-2023', 49, 33, 59, 261, 'confirmed', 9406, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (104, 2, '12-Jan-2023', '26-Feb-2023', 44, 44, 56, 237, 'in_progress', 6402, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (105, 49, '22-Jan-2023', '16-Mar-2023', 47, 48, 40, 155, 'confirmed', 7930, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (106, 28, '25-Jan-2023', '21-Mar-2023', 11, 24, 60, 288, 'cancelled', 8136, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (107, 26, '22-Jan-2023', '20-Mar-2023', 1, 22, 43, 286, 'in_progress', 257, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (108, 27, '07-Jan-2023', '01-Feb-2023', 33, 40, 47, 291, 'completed', 800, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (109, 43, '19-Jan-2023', '14-Feb-2023', 33, 44, 7, 103, 'confirmed', 8879, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (110, 3, '16-Jan-2023', '06-Feb-2023', 8, 43, 66, 327, 'in_progress', 3060, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (111, 24, '05-Jan-2023', '21-Feb-2023', 47, 42, 51, 216, 'in_progress', 8023, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (112, 47, '05-Jan-2023', '20-Feb-2023', 33, 20, 56, 301, 'cancelled', 6659, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (113, 44, '01-Jan-2023', '14-Feb-2023', 43, 19, 61, 172, 'cancelled', 4940, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (114, 33, '20-Jan-2023', '20-Mar-2023', 50, 4, 17, 90, 'completed', 881, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (115, 17, '03-Jan-2023', '14-Feb-2023', 39, 38, 28, 93, 'in_progress', 3387, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (116, 43, '12-Jan-2023', '11-Feb-2023', 11, 23, 3, 436, 'confirmed', 2024, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (117, 1, '30-Jan-2023', '26-Feb-2023', 5, 43, 9, 318, 'completed', 6888, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (118, 21, '07-Jan-2023', '16-Feb-2023', 33, 22, 37, 186, 'completed', 9891, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (119, 24, '05-Jan-2023', '17-Feb-2023', 7, 50, 28, 112, 'cancelled', 4730, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (120, 23, '07-Jan-2023', '16-Mar-2023', 38, 27, 42, 270, 'in_progress', 7240, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (121, 11, '22-Jan-2023', '03-Feb-2023', 30, 20, 40, 128, 'confirmed', 5291, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (122, 16, '03-Jan-2023', '04-Mar-2023', 27, 17, 11, 34, 'cancelled', 838, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (123, 16, '16-Jan-2023', '24-Mar-2023', 21, 30, 27, 186, 'confirmed', 9773, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (124, 13, '07-Jan-2023', '10-Mar-2023', 13, 3, 18, 13, 'in_progress', 7274, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (125, 10, '08-Jan-2023', '22-Feb-2023', 28, 15, 60, 414, 'cancelled', 6388, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (126, 37, '25-Jan-2023', '25-Mar-2023', 48, 15, 49, 61, 'in_progress', 3237, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (127, 3, '05-Jan-2023', '21-Mar-2023', 19, 48, 68, 191, 'confirmed', 6804, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (128, 8, '16-Jan-2023', '14-Mar-2023', 39, 34, 65, 403, 'completed', 2098, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (129, 5, '07-Jan-2023', '06-Feb-2023', 24, 11, 43, 190, 'in_progress', 3325, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (130, 19, '15-Jan-2023', '12-Mar-2023', 45, 45, 24, 149, 'confirmed', 500, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (131, 35, '29-Jan-2023', '25-Mar-2023', 23, 23, 18, 190, 'cancelled', 3836, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (132, 25, '28-Jan-2023', '23-Mar-2023', 18, 4, 68, 397, 'cancelled', 6379, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (133, 5, '13-Jan-2023', '26-Feb-2023', 49, 20, 52, 50, 'completed', 1983, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (134, 18, '23-Jan-2023', '12-Feb-2023', 8, 33, 67, 145, 'in_progress', 1677, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (135, 32, '16-Jan-2023', '12-Mar-2023', 37, 25, 29, 334, 'cancelled', 1420, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (136, 9, '09-Jan-2023', '16-Mar-2023', 40, 42, 27, 231, 'completed', 6612, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (137, 31, '08-Jan-2023', '24-Mar-2023', 14, 34, 8, 152, 'completed', 9242, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (138, 44, '23-Jan-2023', '23-Mar-2023', 14, 13, 10, 279, 'in_progress', 4661, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (139, 21, '23-Jan-2023', '16-Feb-2023', 43, 16, 73, 343, 'in_progress', 252, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (140, 25, '17-Jan-2023', '06-Feb-2023', 46, 24, 10, 305, 'confirmed', 8270, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (141, 11, '09-Jan-2023', '01-Feb-2023', 45, 5, 41, 13, 'confirmed', 8456, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (142, 7, '22-Jan-2023', '14-Mar-2023', 46, 47, 13, 49, 'cancelled', 8289, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (143, 16, '06-Jan-2023', '26-Mar-2023', 37, 16, 22, 425, 'in_progress', 7654, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (144, 38, '02-Jan-2023', '06-Feb-2023', 33, 29, 75, 435, 'cancelled', 6435, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (145, 7, '08-Jan-2023', '02-Feb-2023', 42, 37, 31, 333, 'confirmed', 1060, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (146, 50, '29-Jan-2023', '09-Mar-2023', 27, 47, 75, 277, 'in_progress', 3711, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (147, 25, '04-Jan-2023', '10-Feb-2023', 38, 21, 8, 435, 'in_progress', 5433, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (148, 15, '22-Jan-2023', '19-Feb-2023', 3, 29, 75, 67, 'completed', 4814, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (149, 33, '18-Jan-2023', '01-Mar-2023', 21, 7, 69, 101, 'completed', 9719, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (150, 21, '10-Jan-2023', '13-Mar-2023', 12, 4, 74, 198, 'in_progress', 3030, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (151, 14, '02-Jan-2023', '19-Mar-2023', 39, 16, 61, 396, 'confirmed', 5420, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (152, 22, '27-Jan-2023', '03-Feb-2023', 14, 19, 71, 223, 'completed', 2288, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (153, 18, '28-Jan-2023', '27-Mar-2023', 12, 35, 58, 407, 'confirmed', 8937, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (154, 48, '09-Jan-2023', '22-Feb-2023', 40, 40, 1, 28, 'completed', 9525, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (155, 16, '22-Jan-2023', '19-Mar-2023', 25, 3, 14, 95, 'cancelled', 8457, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (156, 30, '02-Jan-2023', '21-Feb-2023', 27, 20, 2, 45, 'in_progress', 556, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (157, 29, '09-Jan-2023', '20-Feb-2023', 24, 49, 22, 146, 'in_progress', 625, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (158, 24, '01-Jan-2023', '28-Feb-2023', 2, 7, 3, 258, 'cancelled', 2707, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (159, 14, '08-Jan-2023', '07-Mar-2023', 3, 17, 15, 270, 'completed', 6301, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (160, 16, '21-Jan-2023', '13-Feb-2023', 10, 9, 31, 387, 'confirmed', 1718, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (161, 22, '12-Jan-2023', '20-Mar-2023', 38, 39, 29, 86, 'confirmed', 8007, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (162, 32, '05-Jan-2023', '27-Feb-2023', 23, 30, 32, 311, 'completed', 832, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (163, 11, '07-Jan-2023', '18-Feb-2023', 9, 49, 71, 445, 'in_progress', 2990, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (164, 27, '02-Jan-2023', '27-Mar-2023', 16, 22, 41, 286, 'confirmed', 2597, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (165, 24, '02-Jan-2023', '30-Mar-2023', 4, 41, 34, 170, 'confirmed', 6028, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (166, 7, '13-Jan-2023', '03-Feb-2023', 9, 11, 9, 214, 'cancelled', 3762, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (167, 38, '29-Jan-2023', '07-Mar-2023', 1, 38, 51, 80, 'confirmed', 747, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (168, 50, '30-Jan-2023', '17-Mar-2023', 48, 12, 6, 201, 'cancelled', 5102, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (169, 15, '06-Jan-2023', '13-Feb-2023', 5, 44, 7, 327, 'in_progress', 2874, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (170, 47, '15-Jan-2023', '02-Mar-2023', 31, 39, 19, 356, 'cancelled', 525, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (171, 28, '18-Jan-2023', '17-Feb-2023', 1, 10, 28, 101, 'cancelled', 6372, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (172, 8, '17-Jan-2023', '13-Mar-2023', 23, 39, 37, 216, 'confirmed', 7299, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (173, 14, '19-Jan-2023', '16-Feb-2023', 7, 32, 43, 434, 'completed', 6810, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (174, 39, '07-Jan-2023', '13-Feb-2023', 15, 19, 13, 390, 'cancelled', 7582, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (175, 33, '19-Jan-2023', '28-Mar-2023', 41, 45, 57, 104, 'cancelled', 953, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (176, 23, '16-Jan-2023', '24-Feb-2023', 27, 20, 72, 147, 'cancelled', 7408, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (177, 16, '11-Jan-2023', '29-Mar-2023', 11, 33, 24, 54, 'in_progress', 9937, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (178, 23, '23-Jan-2023', '25-Mar-2023', 25, 41, 9, 286, 'in_progress', 1733, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (179, 35, '15-Jan-2023', '22-Feb-2023', 40, 22, 39, 5, 'confirmed', 5129, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (180, 20, '05-Jan-2023', '18-Feb-2023', 37, 19, 6, 127, 'completed', 4913, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (181, 47, '05-Jan-2023', '06-Feb-2023', 47, 27, 65, 366, 'confirmed', 3319, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (182, 4, '02-Jan-2023', '09-Mar-2023', 42, 34, 50, 355, 'completed', 3396, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (183, 17, '27-Jan-2023', '24-Mar-2023', 43, 19, 35, 246, 'confirmed', 1444, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (184, 39, '20-Jan-2023', '17-Feb-2023', 38, 21, 25, 125, 'cancelled', 8386, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (185, 10, '26-Jan-2023', '14-Feb-2023', 2, 38, 20, 426, 'confirmed', 314, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (186, 6, '02-Jan-2023', '27-Mar-2023', 31, 50, 24, 374, 'cancelled', 2917, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (187, 22, '13-Jan-2023', '04-Feb-2023', 3, 6, 70, 308, 'cancelled', 3433, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (188, 45, '16-Jan-2023', '05-Feb-2023', 29, 7, 62, 175, 'cancelled', 7455, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (189, 25, '29-Jan-2023', '12-Mar-2023', 29, 10, 63, 10, 'cancelled', 2721, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (190, 11, '07-Jan-2023', '18-Mar-2023', 31, 39, 63, 379, 'cancelled', 7782, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (191, 31, '17-Jan-2023', '13-Mar-2023', 34, 35, 3, 371, 'in_progress', 107, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (192, 9, '24-Jan-2023', '25-Mar-2023', 4, 29, 50, 206, 'cancelled', 6911, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (193, 26, '11-Jan-2023', '15-Feb-2023', 8, 14, 51, 57, 'confirmed', 2822, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (194, 45, '26-Jan-2023', '02-Mar-2023', 50, 19, 14, 350, 'completed', 3242, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (195, 23, '23-Jan-2023', '30-Mar-2023', 15, 39, 56, 311, 'confirmed', 5008, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (196, 17, '24-Jan-2023', '25-Feb-2023', 28, 6, 31, 186, 'in_progress', 5875, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (197, 37, '29-Jan-2023', '24-Mar-2023', 47, 42, 3, 440, 'in_progress', 9105, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (198, 47, '21-Jan-2023', '11-Mar-2023', 29, 45, 42, 352, 'completed', 2002, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (199, 43, '27-Jan-2023', '01-Mar-2023', 17, 16, 4, 259, 'completed', 1276, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (200, 41, '06-Jan-2023', '17-Mar-2023', 4, 18, 23, 51, 'in_progress', 1750, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (201, 35, '25-Jan-2023', '09-Mar-2023', 2, 42, 73, 367, 'in_progress', 3296, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (202, 50, '02-Jan-2023', '23-Mar-2023', 42, 16, 57, 395, 'in_progress', 6465, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (203, 17, '08-Jan-2023', '16-Mar-2023', 18, 13, 47, 10, 'in_progress', 4015, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (204, 33, '27-Jan-2023', '29-Mar-2023', 20, 47, 3, 85, 'in_progress', 9185, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (205, 11, '10-Jan-2023', '10-Feb-2023', 45, 27, 21, 216, 'in_progress', 194, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (206, 2, '04-Jan-2023', '29-Mar-2023', 20, 48, 58, 242, 'confirmed', 8241, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (207, 43, '29-Jan-2023', '13-Mar-2023', 16, 15, 50, 149, 'completed', 3205, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (208, 34, '19-Jan-2023', '07-Mar-2023', 5, 30, 28, 345, 'in_progress', 2867, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (209, 35, '02-Jan-2023', '03-Mar-2023', 18, 29, 20, 91, 'completed', 5721, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (210, 11, '02-Jan-2023', '23-Feb-2023', 26, 34, 42, 358, 'confirmed', 1635, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (211, 7, '23-Jan-2023', '27-Feb-2023', 45, 32, 58, 4, 'completed', 3357, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (212, 37, '21-Jan-2023', '22-Feb-2023', 6, 13, 1, 325, 'confirmed', 6181, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (213, 8, '03-Jan-2023', '26-Feb-2023', 14, 47, 38, 5, 'completed', 1066, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (214, 9, '25-Jan-2023', '07-Mar-2023', 16, 42, 36, 447, 'in_progress', 5246, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (215, 36, '28-Jan-2023', '24-Mar-2023', 18, 48, 43, 191, 'cancelled', 4023, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (216, 15, '16-Jan-2023', '16-Mar-2023', 42, 28, 35, 101, 'in_progress', 1834, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (217, 42, '13-Jan-2023', '17-Mar-2023', 22, 20, 32, 34, 'in_progress', 7263, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (218, 41, '07-Jan-2023', '15-Feb-2023', 16, 8, 14, 205, 'cancelled', 583, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (219, 12, '16-Jan-2023', '15-Mar-2023', 14, 21, 23, 344, 'confirmed', 2768, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (220, 45, '21-Jan-2023', '16-Feb-2023', 34, 44, 68, 343, 'confirmed', 8996, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (221, 3, '17-Jan-2023', '19-Mar-2023', 32, 10, 37, 57, 'completed', 4912, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (222, 33, '03-Jan-2023', '26-Feb-2023', 47, 11, 17, 415, 'cancelled', 5915, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (223, 40, '05-Jan-2023', '30-Mar-2023', 8, 41, 34, 156, 'cancelled', 5730, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (224, 24, '14-Jan-2023', '07-Mar-2023', 20, 2, 34, 165, 'in_progress', 9843, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (225, 8, '29-Jan-2023', '28-Feb-2023', 39, 27, 28, 25, 'in_progress', 5872, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (226, 16, '26-Jan-2023', '19-Mar-2023', 20, 7, 1, 99, 'cancelled', 9465, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (227, 47, '28-Jan-2023', '12-Mar-2023', 34, 27, 68, 85, 'in_progress', 8704, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (228, 45, '11-Jan-2023', '21-Mar-2023', 14, 29, 39, 399, 'completed', 8211, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (229, 35, '03-Jan-2023', '26-Mar-2023', 8, 33, 23, 42, 'completed', 7398, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (230, 20, '10-Jan-2023', '04-Mar-2023', 19, 35, 18, 2, 'cancelled', 8482, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (231, 41, '20-Jan-2023', '29-Mar-2023', 36, 48, 19, 199, 'confirmed', 140, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (232, 31, '13-Jan-2023', '19-Mar-2023', 26, 19, 10, 427, 'in_progress', 3017, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (233, 35, '11-Jan-2023', '23-Mar-2023', 10, 11, 15, 16, 'in_progress', 9828, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (234, 32, '19-Jan-2023', '13-Mar-2023', 32, 32, 71, 249, 'cancelled', 4316, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (235, 35, '10-Jan-2023', '19-Mar-2023', 30, 20, 64, 51, 'completed', 8926, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (236, 23, '27-Jan-2023', '30-Mar-2023', 48, 3, 69, 64, 'completed', 8690, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (237, 10, '19-Jan-2023', '23-Mar-2023', 10, 7, 39, 421, 'in_progress', 258, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (238, 9, '28-Jan-2023', '06-Mar-2023', 23, 44, 70, 439, 'completed', 9198, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (239, 1, '04-Jan-2023', '28-Mar-2023', 22, 20, 34, 384, 'completed', 648, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (240, 32, '08-Jan-2023', '03-Mar-2023', 34, 34, 3, 39, 'completed', 6637, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (241, 34, '23-Jan-2023', '29-Mar-2023', 13, 41, 32, 183, 'confirmed', 9833, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (242, 7, '24-Jan-2023', '14-Mar-2023', 29, 39, 8, 32, 'confirmed', 3698, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (243, 17, '17-Jan-2023', '06-Feb-2023', 3, 14, 29, 354, 'cancelled', 3152, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (244, 25, '09-Jan-2023', '14-Mar-2023', 49, 6, 48, 257, 'completed', 8711, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (245, 24, '07-Jan-2023', '16-Mar-2023', 50, 29, 61, 245, 'completed', 3083, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (246, 5, '19-Jan-2023', '04-Mar-2023', 27, 41, 72, 112, 'confirmed', 2146, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (247, 47, '08-Jan-2023', '22-Feb-2023', 15, 44, 44, 387, 'cancelled', 9815, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (248, 13, '13-Jan-2023', '02-Mar-2023', 30, 2, 64, 211, 'confirmed', 8677, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (249, 19, '12-Jan-2023', '10-Feb-2023', 49, 17, 4, 78, 'confirmed', 8987, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (250, 49, '10-Jan-2023', '03-Feb-2023', 6, 40, 23, 233, 'in_progress', 4277, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (251, 41, '19-Jan-2023', '04-Mar-2023', 11, 42, 64, 139, 'confirmed', 7341, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (252, 35, '04-Jan-2023', '16-Mar-2023', 20, 37, 68, 108, 'cancelled', 9530, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (253, 14, '04-Jan-2023', '19-Feb-2023', 20, 9, 44, 31, 'in_progress', 5112, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (254, 32, '27-Jan-2023', '01-Feb-2023', 17, 32, 55, 421, 'in_progress', 6122, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (255, 23, '21-Jan-2023', '05-Mar-2023', 23, 21, 21, 442, 'completed', 4392, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (256, 19, '25-Jan-2023', '08-Mar-2023', 39, 14, 38, 318, 'cancelled', 7978, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (257, 14, '15-Jan-2023', '16-Mar-2023', 16, 12, 7, 387, 'confirmed', 6255, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (258, 40, '18-Jan-2023', '22-Feb-2023', 44, 3, 7, 257, 'in_progress', 7745, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (259, 47, '02-Jan-2023', '15-Mar-2023', 48, 14, 10, 355, 'cancelled', 3919, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (260, 38, '09-Jan-2023', '11-Mar-2023', 4, 12, 20, 38, 'in_progress', 2319, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (261, 38, '04-Jan-2023', '06-Feb-2023', 42, 18, 48, 94, 'in_progress', 4567, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (262, 41, '28-Jan-2023', '04-Feb-2023', 24, 17, 1, 347, 'completed', 7417, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (263, 14, '15-Jan-2023', '01-Feb-2023', 1, 40, 9, 44, 'cancelled', 8393, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (264, 34, '28-Jan-2023', '29-Mar-2023', 25, 23, 40, 299, 'cancelled', 540, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (265, 31, '26-Jan-2023', '10-Feb-2023', 29, 23, 42, 110, 'confirmed', 1850, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (266, 9, '20-Jan-2023', '07-Feb-2023', 28, 24, 52, 3, 'cancelled', 8043, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (267, 46, '18-Jan-2023', '09-Feb-2023', 20, 28, 30, 352, 'completed', 1633, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (268, 36, '05-Jan-2023', '11-Mar-2023', 24, 43, 51, 1, 'confirmed', 235, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (269, 41, '11-Jan-2023', '14-Mar-2023', 6, 47, 39, 81, 'completed', 1369, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (270, 41, '20-Jan-2023', '14-Mar-2023', 11, 10, 66, 37, 'confirmed', 1499, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (271, 23, '07-Jan-2023', '14-Feb-2023', 27, 25, 1, 368, 'cancelled', 8025, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (272, 40, '23-Jan-2023', '22-Mar-2023', 18, 30, 3, 112, 'cancelled', 8971, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (273, 19, '01-Jan-2023', '06-Mar-2023', 2, 38, 57, 446, 'in_progress', 3657, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (274, 24, '23-Jan-2023', '02-Feb-2023', 45, 14, 6, 115, 'completed', 2876, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (275, 40, '11-Jan-2023', '15-Mar-2023', 44, 38, 67, 181, 'cancelled', 665, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (276, 35, '28-Jan-2023', '22-Feb-2023', 49, 30, 20, 184, 'in_progress', 2463, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (277, 38, '15-Jan-2023', '09-Mar-2023', 37, 6, 41, 336, 'cancelled', 7835, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (278, 45, '14-Jan-2023', '24-Feb-2023', 11, 44, 27, 390, 'cancelled', 5992, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (279, 39, '07-Jan-2023', '04-Mar-2023', 6, 50, 42, 392, 'in_progress', 826, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (280, 39, '21-Jan-2023', '14-Mar-2023', 21, 9, 59, 147, 'confirmed', 3136, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (281, 9, '09-Jan-2023', '08-Feb-2023', 38, 8, 54, 419, 'completed', 9463, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (282, 17, '17-Jan-2023', '17-Mar-2023', 16, 33, 25, 126, 'confirmed', 7732, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (283, 1, '12-Jan-2023', '17-Feb-2023', 49, 41, 60, 3, 'in_progress', 2437, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (284, 29, '19-Jan-2023', '29-Mar-2023', 5, 14, 3, 439, 'confirmed', 9956, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (285, 18, '07-Jan-2023', '30-Mar-2023', 48, 14, 34, 179, 'confirmed', 1196, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (286, 36, '30-Jan-2023', '29-Mar-2023', 35, 30, 51, 371, 'in_progress', 1672, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (287, 50, '27-Jan-2023', '23-Feb-2023', 5, 50, 69, 381, 'cancelled', 1147, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (288, 45, '13-Jan-2023', '13-Feb-2023', 47, 41, 29, 280, 'in_progress', 6991, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (289, 14, '08-Jan-2023', '03-Mar-2023', 38, 41, 31, 245, 'in_progress', 4906, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (290, 28, '19-Jan-2023', '04-Feb-2023', 31, 11, 17, 323, 'cancelled', 3469, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (291, 28, '10-Jan-2023', '04-Feb-2023', 46, 45, 57, 260, 'completed', 6118, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (292, 42, '26-Jan-2023', '07-Feb-2023', 17, 48, 19, 440, 'in_progress', 65, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (293, 9, '21-Jan-2023', '07-Mar-2023', 33, 6, 42, 232, 'cancelled', 4281, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (294, 12, '05-Jan-2023', '07-Mar-2023', 3, 39, 46, 190, 'completed', 2987, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (295, 50, '29-Jan-2023', '17-Feb-2023', 44, 50, 14, 366, 'cancelled', 2625, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (296, 27, '03-Jan-2023', '25-Feb-2023', 1, 42, 70, 180, 'in_progress', 3250, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (297, 16, '12-Jan-2023', '19-Mar-2023', 44, 15, 12, 277, 'completed', 1669, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (298, 1, '10-Jan-2023', '04-Mar-2023', 18, 39, 6, 37, 'in_progress', 5557, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (299, 35, '03-Jan-2023', '20-Feb-2023', 2, 17, 57, 155, 'completed', 3926, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (300, 31, '12-Jan-2023', '13-Feb-2023', 34, 2, 12, 442, 'cancelled', 506, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (301, 48, '25-Jan-2023', '16-Feb-2023', 5, 35, 69, 13, 'completed', 2974, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (302, 16, '25-Jan-2023', '25-Mar-2023', 39, 42, 53, 214, 'in_progress', 2328, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (303, 29, '01-Jan-2023', '22-Feb-2023', 19, 16, 23, 172, 'confirmed', 5220, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (304, 29, '20-Jan-2023', '16-Feb-2023', 18, 2, 10, 39, 'in_progress', 1930, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (305, 10, '01-Jan-2023', '11-Mar-2023', 19, 26, 50, 293, 'confirmed', 1134, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (306, 43, '24-Jan-2023', '07-Feb-2023', 43, 47, 33, 260, 'cancelled', 8355, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (307, 16, '28-Jan-2023', '25-Mar-2023', 22, 11, 68, 276, 'completed', 9714, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (308, 7, '17-Jan-2023', '08-Mar-2023', 37, 26, 36, 372, 'in_progress', 8860, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (309, 1, '05-Jan-2023', '09-Feb-2023', 21, 26, 48, 119, 'confirmed', 9795, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (310, 32, '27-Jan-2023', '27-Feb-2023', 36, 18, 23, 165, 'cancelled', 4908, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (311, 15, '01-Jan-2023', '16-Feb-2023', 17, 39, 20, 67, 'cancelled', 7988, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (312, 29, '02-Jan-2023', '12-Mar-2023', 6, 7, 9, 91, 'in_progress', 5498, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (313, 35, '23-Jan-2023', '17-Mar-2023', 28, 11, 3, 373, 'confirmed', 6974, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (314, 49, '23-Jan-2023', '24-Mar-2023', 27, 11, 73, 324, 'cancelled', 2911, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (315, 45, '05-Jan-2023', '22-Feb-2023', 10, 40, 29, 294, 'confirmed', 4902, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (316, 43, '19-Jan-2023', '20-Feb-2023', 24, 46, 3, 127, 'completed', 4394, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (317, 49, '12-Jan-2023', '03-Mar-2023', 6, 15, 34, 64, 'completed', 7950, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (318, 39, '12-Jan-2023', '02-Feb-2023', 35, 50, 27, 303, 'confirmed', 8888, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (319, 40, '10-Jan-2023', '19-Mar-2023', 7, 39, 39, 111, 'confirmed', 7659, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (320, 24, '23-Jan-2023', '09-Feb-2023', 2, 10, 73, 392, 'cancelled', 3124, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (321, 1, '01-Jan-2023', '24-Mar-2023', 41, 46, 59, 43, 'completed', 6829, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (322, 42, '07-Jan-2023', '05-Mar-2023', 47, 18, 63, 234, 'in_progress', 6341, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (323, 44, '27-Jan-2023', '10-Mar-2023', 37, 44, 8, 196, 'cancelled', 8428, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (324, 39, '19-Jan-2023', '17-Feb-2023', 43, 3, 29, 383, 'confirmed', 9356, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (325, 44, '06-Jan-2023', '09-Feb-2023', 43, 21, 51, 396, 'completed', 7757, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (326, 8, '08-Jan-2023', '01-Feb-2023', 22, 18, 55, 264, 'in_progress', 3023, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (327, 34, '28-Jan-2023', '22-Feb-2023', 29, 45, 32, 427, 'confirmed', 1593, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (328, 3, '01-Jan-2023', '09-Feb-2023', 16, 15, 42, 428, 'cancelled', 3677, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (329, 27, '28-Jan-2023', '10-Mar-2023', 44, 3, 75, 37, 'cancelled', 5858, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (330, 9, '06-Jan-2023', '23-Mar-2023', 23, 2, 11, 218, 'cancelled', 3157, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (331, 30, '21-Jan-2023', '03-Feb-2023', 6, 37, 37, 247, 'completed', 4406, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (332, 17, '11-Jan-2023', '19-Mar-2023', 39, 18, 5, 373, 'in_progress', 8074, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (333, 34, '14-Jan-2023', '28-Mar-2023', 22, 9, 22, 112, 'cancelled', 6776, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (334, 17, '05-Jan-2023', '05-Feb-2023', 20, 22, 50, 30, 'confirmed', 5990, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (335, 46, '17-Jan-2023', '23-Mar-2023', 14, 25, 16, 128, 'cancelled', 8340, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (336, 30, '10-Jan-2023', '22-Feb-2023', 19, 15, 75, 117, 'confirmed', 6219, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (337, 40, '12-Jan-2023', '15-Mar-2023', 6, 29, 44, 408, 'completed', 4581, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (338, 6, '03-Jan-2023', '09-Feb-2023', 29, 48, 57, 150, 'in_progress', 5105, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (339, 39, '04-Jan-2023', '24-Mar-2023', 44, 34, 38, 357, 'cancelled', 1967, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (340, 22, '10-Jan-2023', '10-Feb-2023', 40, 12, 58, 266, 'in_progress', 7155, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (341, 6, '30-Jan-2023', '01-Mar-2023', 40, 24, 64, 322, 'completed', 1184, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (342, 7, '27-Jan-2023', '16-Feb-2023', 17, 18, 69, 447, 'confirmed', 2878, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (343, 14, '15-Jan-2023', '17-Mar-2023', 42, 3, 11, 11, 'completed', 4142, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (344, 43, '28-Jan-2023', '24-Mar-2023', 35, 2, 4, 427, 'completed', 1211, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (345, 26, '26-Jan-2023', '20-Feb-2023', 25, 35, 6, 2, 'in_progress', 1091, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (346, 17, '09-Jan-2023', '06-Feb-2023', 23, 35, 49, 386, 'completed', 7049, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (347, 44, '03-Jan-2023', '15-Feb-2023', 24, 29, 12, 88, 'completed', 9034, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (348, 9, '11-Jan-2023', '08-Feb-2023', 44, 39, 66, 235, 'in_progress', 7123, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (349, 4, '04-Jan-2023', '18-Feb-2023', 36, 14, 2, 326, 'cancelled', 2162, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (350, 2, '19-Jan-2023', '05-Feb-2023', 38, 33, 19, 428, 'confirmed', 1354, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (351, 4, '01-Jan-2023', '02-Mar-2023', 8, 27, 45, 141, 'cancelled', 5433, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (352, 38, '08-Jan-2023', '10-Mar-2023', 10, 1, 12, 340, 'completed', 4421, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (353, 9, '02-Jan-2023', '24-Mar-2023', 41, 48, 66, 355, 'completed', 7080, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (354, 47, '28-Jan-2023', '16-Feb-2023', 10, 10, 11, 321, 'in_progress', 1808, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (355, 38, '08-Jan-2023', '11-Feb-2023', 47, 21, 36, 5, 'confirmed', 8193, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (356, 7, '05-Jan-2023', '11-Feb-2023', 13, 5, 2, 401, 'completed', 5650, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (357, 12, '06-Jan-2023', '06-Feb-2023', 46, 29, 64, 349, 'confirmed', 4217, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (358, 44, '04-Jan-2023', '04-Feb-2023', 42, 43, 19, 250, 'in_progress', 3489, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (359, 41, '15-Jan-2023', '28-Mar-2023', 39, 26, 55, 362, 'cancelled', 7670, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (360, 48, '01-Jan-2023', '20-Feb-2023', 16, 44, 39, 430, 'cancelled', 7094, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (361, 1, '23-Jan-2023', '07-Mar-2023', 34, 39, 39, 274, 'in_progress', 3227, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (362, 49, '23-Jan-2023', '07-Mar-2023', 38, 31, 15, 90, 'cancelled', 3242, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (363, 10, '24-Jan-2023', '12-Mar-2023', 4, 44, 66, 8, 'cancelled', 1139, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (364, 43, '05-Jan-2023', '06-Feb-2023', 1, 39, 52, 32, 'cancelled', 5688, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (365, 40, '11-Jan-2023', '12-Feb-2023', 17, 47, 37, 163, 'confirmed', 5480, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (366, 12, '27-Jan-2023', '24-Mar-2023', 49, 9, 38, 25, 'completed', 8731, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (367, 32, '30-Jan-2023', '05-Mar-2023', 23, 35, 4, 246, 'cancelled', 4733, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (368, 49, '03-Jan-2023', '17-Feb-2023', 39, 23, 35, 54, 'cancelled', 5115, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (369, 41, '23-Jan-2023', '14-Mar-2023', 10, 19, 8, 120, 'completed', 4880, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (370, 27, '09-Jan-2023', '25-Feb-2023', 20, 2, 8, 317, 'confirmed', 7994, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (371, 17, '12-Jan-2023', '07-Mar-2023', 30, 13, 71, 201, 'confirmed', 9838, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (372, 13, '26-Jan-2023', '25-Mar-2023', 12, 12, 48, 216, 'cancelled', 5430, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (373, 1, '09-Jan-2023', '09-Feb-2023', 22, 36, 54, 339, 'cancelled', 6750, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (374, 32, '21-Jan-2023', '17-Feb-2023', 22, 40, 60, 71, 'in_progress', 2939, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (375, 2, '27-Jan-2023', '28-Feb-2023', 16, 47, 9, 24, 'confirmed', 9568, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (376, 38, '09-Jan-2023', '04-Mar-2023', 20, 39, 63, 130, 'in_progress', 8009, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (377, 35, '24-Jan-2023', '27-Mar-2023', 22, 2, 74, 436, 'confirmed', 5569, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (378, 3, '24-Jan-2023', '29-Mar-2023', 2, 47, 22, 7, 'completed', 6442, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (379, 14, '18-Jan-2023', '11-Mar-2023', 8, 7, 16, 442, 'completed', 1898, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (380, 42, '08-Jan-2023', '14-Mar-2023', 21, 25, 75, 290, 'completed', 4499, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (381, 3, '01-Jan-2023', '17-Mar-2023', 2, 4, 3, 360, 'confirmed', 9404, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (382, 35, '10-Jan-2023', '24-Mar-2023', 47, 3, 18, 45, 'completed', 2921, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (383, 7, '12-Jan-2023', '10-Feb-2023', 49, 30, 26, 275, 'cancelled', 5602, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (384, 11, '22-Jan-2023', '11-Mar-2023', 2, 37, 19, 196, 'in_progress', 3531, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (385, 11, '09-Jan-2023', '25-Feb-2023', 14, 42, 36, 36, 'confirmed', 6237, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (386, 11, '17-Jan-2023', '21-Feb-2023', 7, 14, 24, 198, 'in_progress', 7756, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (387, 7, '30-Jan-2023', '11-Mar-2023', 1, 20, 58, 78, 'completed', 5556, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (388, 35, '13-Jan-2023', '28-Feb-2023', 34, 34, 37, 181, 'confirmed', 4092, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (389, 9, '01-Jan-2023', '24-Feb-2023', 48, 37, 29, 357, 'cancelled', 7189, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (390, 23, '20-Jan-2023', '05-Feb-2023', 7, 45, 61, 104, 'completed', 6264, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (391, 29, '04-Jan-2023', '07-Feb-2023', 13, 25, 48, 110, 'in_progress', 6521, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (392, 29, '07-Jan-2023', '23-Feb-2023', 38, 44, 21, 252, 'confirmed', 1818, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (393, 32, '04-Jan-2023', '15-Mar-2023', 14, 37, 63, 64, 'confirmed', 2174, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (394, 9, '13-Jan-2023', '09-Mar-2023', 16, 23, 61, 343, 'cancelled', 4649, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (395, 12, '24-Jan-2023', '22-Feb-2023', 45, 46, 59, 327, 'cancelled', 5318, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (396, 45, '12-Jan-2023', '22-Mar-2023', 41, 3, 4, 357, 'confirmed', 580, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (397, 11, '21-Jan-2023', '25-Mar-2023', 32, 12, 70, 89, 'confirmed', 6049, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (398, 8, '28-Jan-2023', '26-Mar-2023', 14, 15, 24, 315, 'completed', 2944, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (399, 11, '04-Jan-2023', '14-Feb-2023', 42, 6, 70, 167, 'completed', 4794, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (400, 36, '15-Jan-2023', '25-Mar-2023', 46, 1, 72, 11, 'cancelled', 7218, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (401, 30, '27-Jan-2023', '20-Feb-2023', 44, 50, 10, 187, 'completed', 2894, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (402, 4, '27-Jan-2023', '19-Feb-2023', 5, 33, 50, 246, 'confirmed', 6499, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (403, 31, '30-Jan-2023', '12-Mar-2023', 31, 33, 34, 153, 'in_progress', 4011, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (404, 37, '28-Jan-2023', '22-Mar-2023', 39, 27, 14, 296, 'confirmed', 5718, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (405, 5, '17-Jan-2023', '28-Mar-2023', 8, 4, 18, 80, 'confirmed', 1982, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (406, 23, '29-Jan-2023', '06-Mar-2023', 35, 50, 25, 246, 'in_progress', 2146, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (407, 25, '21-Jan-2023', '15-Mar-2023', 20, 19, 3, 350, 'cancelled', 4565, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (408, 2, '27-Jan-2023', '02-Mar-2023', 24, 13, 40, 160, 'confirmed', 3155, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (409, 6, '26-Jan-2023', '21-Feb-2023', 42, 33, 70, 382, 'cancelled', 2343, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (410, 11, '26-Jan-2023', '27-Feb-2023', 36, 49, 43, 45, 'cancelled', 7887, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (411, 29, '17-Jan-2023', '28-Feb-2023', 25, 49, 3, 402, 'confirmed', 4322, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (412, 24, '18-Jan-2023', '11-Mar-2023', 46, 42, 59, 396, 'in_progress', 7775, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (413, 3, '24-Jan-2023', '07-Feb-2023', 48, 31, 28, 60, 'confirmed', 1163, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (414, 19, '03-Jan-2023', '03-Feb-2023', 33, 32, 26, 378, 'in_progress', 5237, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (415, 39, '05-Jan-2023', '10-Feb-2023', 3, 27, 69, 332, 'cancelled', 507, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (416, 13, '24-Jan-2023', '02-Mar-2023', 23, 23, 19, 270, 'completed', 142, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (417, 35, '05-Jan-2023', '11-Mar-2023', 43, 29, 30, 342, 'completed', 1375, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (418, 25, '17-Jan-2023', '11-Feb-2023', 40, 35, 18, 94, 'cancelled', 8179, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (419, 27, '13-Jan-2023', '27-Feb-2023', 14, 26, 43, 77, 'completed', 2626, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (420, 5, '27-Jan-2023', '27-Feb-2023', 44, 50, 51, 159, 'cancelled', 5560, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (421, 46, '04-Jan-2023', '23-Feb-2023', 47, 13, 62, 353, 'completed', 9749, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (422, 41, '09-Jan-2023', '20-Mar-2023', 8, 34, 23, 90, 'completed', 3764, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (423, 9, '28-Jan-2023', '09-Feb-2023', 49, 6, 58, 58, 'cancelled', 8379, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (424, 29, '16-Jan-2023', '26-Mar-2023', 43, 1, 3, 440, 'completed', 2125, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (425, 3, '21-Jan-2023', '13-Feb-2023', 42, 38, 9, 192, 'completed', 4836, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (426, 42, '01-Jan-2023', '22-Mar-2023', 28, 3, 16, 412, 'in_progress', 750, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (427, 34, '26-Jan-2023', '15-Feb-2023', 36, 40, 42, 430, 'completed', 4930, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (428, 1, '23-Jan-2023', '07-Mar-2023', 49, 2, 59, 298, 'cancelled', 4855, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (429, 22, '06-Jan-2023', '08-Feb-2023', 47, 44, 4, 374, 'completed', 488, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (430, 14, '05-Jan-2023', '09-Mar-2023', 25, 13, 61, 432, 'in_progress', 3492, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (431, 21, '27-Jan-2023', '23-Feb-2023', 27, 48, 42, 375, 'completed', 45, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (432, 17, '14-Jan-2023', '03-Mar-2023', 10, 43, 66, 273, 'cancelled', 4529, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (433, 47, '13-Jan-2023', '11-Mar-2023', 17, 37, 58, 144, 'cancelled', 2869, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (434, 43, '25-Jan-2023', '18-Feb-2023', 14, 23, 34, 149, 'in_progress', 4181, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (435, 29, '16-Jan-2023', '03-Mar-2023', 14, 35, 6, 140, 'in_progress', 9147, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (436, 46, '07-Jan-2023', '15-Mar-2023', 49, 37, 57, 28, 'confirmed', 9648, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (437, 12, '14-Jan-2023', '15-Feb-2023', 23, 34, 63, 181, 'cancelled', 6739, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (438, 19, '28-Jan-2023', '27-Feb-2023', 47, 5, 52, 14, 'confirmed', 4864, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (439, 17, '22-Jan-2023', '23-Mar-2023', 41, 11, 69, 83, 'in_progress', 7676, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (440, 11, '27-Jan-2023', '04-Mar-2023', 28, 2, 23, 399, 'confirmed', 3604, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (441, 31, '21-Jan-2023', '12-Feb-2023', 33, 46, 1, 435, 'cancelled', 8875, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (442, 12, '10-Jan-2023', '22-Mar-2023', 12, 15, 75, 328, 'in_progress', 2189, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (443, 43, '07-Jan-2023', '27-Mar-2023', 12, 18, 40, 212, 'completed', 1396, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (444, 16, '10-Jan-2023', '01-Feb-2023', 8, 30, 9, 390, 'completed', 7292, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (445, 39, '01-Jan-2023', '27-Feb-2023', 35, 1, 61, 408, 'completed', 1283, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (446, 14, '10-Jan-2023', '17-Feb-2023', 38, 49, 37, 256, 'cancelled', 5159, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (447, 23, '16-Jan-2023', '27-Feb-2023', 15, 40, 53, 100, 'completed', 6744, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (448, 12, '18-Jan-2023', '12-Mar-2023', 25, 37, 19, 373, 'in_progress', 1488, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (449, 37, '27-Jan-2023', '30-Mar-2023', 9, 5, 35, 421, 'in_progress', 9821, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (450, 21, '01-Jan-2023', '01-Mar-2023', 17, 33, 15, 385, 'cancelled', 149, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (451, 43, '29-Jan-2023', '03-Mar-2023', 22, 32, 4, 253, 'completed', 873, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (452, 35, '19-Jan-2023', '09-Feb-2023', 37, 10, 73, 202, 'cancelled', 1290, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (453, 2, '21-Jan-2023', '26-Mar-2023', 36, 24, 25, 38, 'completed', 618, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (454, 8, '22-Jan-2023', '14-Mar-2023', 28, 4, 12, 434, 'in_progress', 3775, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (455, 37, '02-Jan-2023', '22-Feb-2023', 10, 31, 58, 307, 'completed', 8789, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (456, 15, '26-Jan-2023', '23-Feb-2023', 47, 20, 27, 355, 'cancelled', 1971, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (457, 28, '18-Jan-2023', '10-Mar-2023', 30, 26, 9, 373, 'completed', 1989, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (458, 31, '26-Jan-2023', '18-Mar-2023', 18, 8, 67, 333, 'cancelled', 1941, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (459, 24, '09-Jan-2023', '21-Feb-2023', 10, 21, 7, 132, 'cancelled', 8335, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (460, 25, '29-Jan-2023', '04-Feb-2023', 49, 29, 64, 430, 'cancelled', 200, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (461, 27, '19-Jan-2023', '09-Mar-2023', 41, 25, 55, 307, 'in_progress', 5912, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (462, 46, '29-Jan-2023', '03-Feb-2023', 12, 9, 12, 364, 'cancelled', 7272, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (463, 24, '10-Jan-2023', '13-Feb-2023', 13, 7, 23, 4, 'confirmed', 6413, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (464, 5, '28-Jan-2023', '05-Feb-2023', 10, 28, 7, 284, 'confirmed', 6323, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (465, 2, '21-Jan-2023', '13-Feb-2023', 9, 12, 30, 224, 'in_progress', 1537, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (466, 1, '22-Jan-2023', '04-Feb-2023', 7, 31, 73, 113, 'completed', 7975, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (467, 50, '24-Jan-2023', '14-Feb-2023', 10, 8, 11, 167, 'cancelled', 9097, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (468, 12, '30-Jan-2023', '23-Feb-2023', 33, 26, 54, 393, 'in_progress', 4345, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (469, 20, '30-Jan-2023', '06-Mar-2023', 25, 32, 64, 175, 'confirmed', 5820, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (470, 6, '07-Jan-2023', '27-Mar-2023', 5, 47, 26, 132, 'confirmed', 4078, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (471, 47, '17-Jan-2023', '21-Feb-2023', 35, 34, 23, 447, 'in_progress', 34, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (472, 49, '22-Jan-2023', '06-Feb-2023', 48, 24, 64, 404, 'cancelled', 4724, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (473, 31, '24-Jan-2023', '07-Feb-2023', 38, 4, 35, 207, 'cancelled', 6738, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (474, 19, '30-Jan-2023', '27-Feb-2023', 3, 29, 32, 431, 'in_progress', 1053, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (475, 45, '24-Jan-2023', '25-Mar-2023', 4, 47, 60, 198, 'in_progress', 3553, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (476, 41, '15-Jan-2023', '02-Mar-2023', 25, 17, 15, 262, 'confirmed', 5233, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (477, 31, '04-Jan-2023', '02-Mar-2023', 37, 7, 44, 354, 'in_progress', 9582, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (478, 21, '14-Jan-2023', '12-Feb-2023', 39, 39, 71, 233, 'completed', 3792, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (479, 6, '29-Jan-2023', '26-Mar-2023', 46, 9, 21, 410, 'completed', 3871, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (480, 4, '07-Jan-2023', '04-Feb-2023', 43, 6, 57, 56, 'cancelled', 1179, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (481, 1, '14-Jan-2023', '28-Feb-2023', 15, 36, 29, 11, 'completed', 3076, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (482, 20, '10-Jan-2023', '27-Mar-2023', 43, 42, 24, 392, 'cancelled', 6479, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (483, 49, '15-Jan-2023', '04-Mar-2023', 1, 6, 43, 7, 'cancelled', 4918, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (484, 25, '05-Jan-2023', '06-Mar-2023', 38, 6, 45, 251, 'in_progress', 156, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (485, 5, '14-Jan-2023', '04-Mar-2023', 27, 41, 3, 182, 'completed', 5518, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (486, 9, '06-Jan-2023', '03-Mar-2023', 1, 32, 67, 322, 'cancelled', 3133, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (487, 5, '14-Jan-2023', '28-Feb-2023', 22, 40, 75, 423, 'cancelled', 2242, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (488, 8, '13-Jan-2023', '15-Feb-2023', 14, 32, 10, 351, 'cancelled', 96, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (489, 49, '30-Jan-2023', '03-Mar-2023', 33, 44, 61, 223, 'in_progress', 1962, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (490, 2, '30-Jan-2023', '08-Feb-2023', 18, 6, 73, 74, 'confirmed', 4867, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (491, 49, '11-Jan-2023', '16-Feb-2023', 16, 30, 23, 83, 'cancelled', 1078, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (492, 9, '18-Jan-2023', '30-Mar-2023', 34, 29, 38, 223, 'in_progress', 4711, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (493, 34, '13-Jan-2023', '16-Feb-2023', 25, 47, 42, 326, 'confirmed', 5496, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (494, 3, '29-Jan-2023', '25-Mar-2023', 5, 7, 18, 382, 'completed', 394, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (495, 32, '09-Jan-2023', '15-Feb-2023', 25, 32, 8, 282, 'cancelled', 5718, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (496, 11, '04-Jan-2023', '01-Mar-2023', 50, 34, 53, 11, 'confirmed', 9795, 'completed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (497, 44, '23-Jan-2023', '25-Mar-2023', 4, 12, 65, 44, 'confirmed', 8591, 'NA');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (498, 27, '11-Jan-2023', '09-Feb-2023', 45, 30, 72, 442, 'confirmed', 4602, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (499, 5, '14-Jan-2023', '09-Mar-2023', 24, 19, 75, 157, 'cancelled', 837, 'failed');
insert into orders (order_id, customer_id, pickup_date_time, drop_date_time, drop_location, pickup_location, vehicle_id, card_id, order_status, bill_amount, payment_status) values (500, 23, '08-Jan-2023', '20-Mar-2023', 24, 29, 6, 162, 'in_progress', 3247, 'NA');


--tracking
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (1, '63.6343,73.3383', 39, '13-Aug-2022', '04-Mar-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (2, '73.7303,33.8393', 49, '27-Jan-2022', '31-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (3, '73.6303,13.6333', 39, '21-Feb-2022', '06-Mar-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (4, '03.7383,93.9303', 98, '25-Nov-2021', '30-Dec-2021', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (5, '83.2353,23.5333', 74, '30-Sep-2021', '28-Jun-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (6, '93.8373,83.6333', 47, '20-Jan-2022', '08-Sep-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (7, '93.8353,83.5303', 71, '27-Dec-2022', '09-Jan-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (8, '63.5303,03.8353', 43, '28-Oct-2022', '29-Nov-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (9, '83.6383,63.7373', 81, '01-Sep-2022', '10-Jul-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (10, '73.5303,23.6303', 14, '04-Feb-2023', '03-Nov-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (11, '53.9383,93.5313', 13, '11-Apr-2022', '12-Feb-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (12, '53.7373,53.2313', 62, '10-Dec-2022', '09-Oct-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (13, '13.0373,53.9333', 25, '18-Jan-2022', '18-Feb-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (14, '53.9373,53.8343', 70, '01-Jun-2022', '14-Mar-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (15, '23.6363,53.7353', 57, '24-Jun-2022', '02-Jun-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (16, '13.4323,53.2343', 54, '29-Jan-2022', '26-Oct-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (17, '83.2363,33.9313', 1, '28-Jun-2022', '21-Feb-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (18, '53.6363,63.1343', 29, '17-Mar-2022', '15-Nov-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (19, '43.7363,43.0363', 80, '27-Jan-2022', '08-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (20, '93.1393,33.1383', 43, '28-Jul-2021', '17-Feb-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (21, '63.8383,83.5333', 15, '16-Oct-2022', '29-Dec-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (22, '93.0363,83.0333', 16, '16-Oct-2022', '28-Jun-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (23, '73.2323,33.6343', 20, '10-Sep-2021', '07-Jan-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (24, '63.5363,03.2313', 91, '29-Jun-2022', '23-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (25, '73.9393,23.4323', 2, '16-Oct-2022', '11-Sep-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (26, '83.8323,83.7303', 90, '05-Nov-2021', '09-Apr-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (27, '03.6333,33.9303', 12, '01-Apr-2022', '19-Nov-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (28, '63.4383,83.4333', 94, '04-Dec-2022', '17-Jan-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (29, '53.1373,73.9313', 51, '15-Jan-2023', '06-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (30, '63.9303,83.7383', 7, '26-Apr-2022', '02-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (31, '53.4383,03.6343', 100, '11-Sep-2021', '21-May-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (32, '53.4393,73.2373', 95, '11-Oct-2021', '24-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (33, '53.1323,83.7343', 98, '15-Aug-2022', '16-Dec-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (34, '43.3343,23.1313', 58, '13-Jun-2022', '10-Jun-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (35, '13.8313,53.7383', 92, '26-Nov-2022', '23-Aug-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (36, '33.4393,73.0353', 21, '10-Feb-2023', '04-Jun-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (37, '53.5373,83.1343', 26, '07-Nov-2021', '04-Mar-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (38, '53.4383,63.5333', 46, '11-Apr-2022', '17-Nov-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (39, '13.3303,13.7393', 17, '13-Mar-2022', '11-Mar-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (40, '53.3333,03.9333', 1, '01-Sep-2022', '11-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (41, '03.0353,63.6353', 16, '25-Jun-2022', '08-Sep-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (42, '53.4383,13.8323', 1, '24-Aug-2021', '02-Mar-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (43, '43.2323,63.7393', 63, '04-Jan-2022', '13-Feb-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (44, '83.8393,03.6303', 68, '13-Dec-2021', '21-Aug-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (45, '13.6333,03.4393', 17, '08-Feb-2022', '08-Jul-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (46, '63.6333,03.7313', 51, '17-Jan-2022', '22-Feb-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (47, '93.5383,83.2353', 60, '13-Feb-2023', '01-Oct-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (48, '93.4373,73.3363', 31, '23-Jan-2023', '03-Apr-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (49, '33.5323,03.0353', 76, '22-May-2022', '26-Sep-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (50, '03.5313,23.2393', 88, '12-Apr-2022', '26-Dec-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (51, '63.5353,03.6323', 87, '02-Sep-2022', '06-Feb-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (52, '23.1333,53.9313', 22, '08-Dec-2021', '25-Apr-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (53, '63.4323,73.9323', 54, '20-Feb-2023', '02-Jan-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (54, '53.7383,13.2333', 35, '16-Sep-2021', '02-Nov-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (55, '23.1303,83.1373', 79, '20-Jun-2022', '30-May-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (56, '73.9313,53.5393', 79, '19-Jul-2021', '05-Sep-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (57, '43.9313,93.5363', 28, '05-Sep-2021', '29-Mar-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (58, '73.4383,83.6353', 4, '06-Jan-2023', '25-Jul-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (59, '13.2303,23.0333', 25, '06-Mar-2022', '29-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (60, '33.3333,33.6383', 20, '15-Aug-2022', '27-Jan-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (61, '73.4323,53.8303', 95, '22-Nov-2022', '25-Jan-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (62, '83.5333,43.1333', 4, '12-Sep-2022', '16-Feb-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (63, '23.8313,63.3363', 28, '01-Apr-2022', '16-Mar-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (64, '83.8313,43.2333', 78, '01-Oct-2022', '02-Jan-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (65, '83.6313,53.7373', 98, '19-May-2022', '04-Aug-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (66, '63.5343,63.9333', 52, '26-Jan-2023', '28-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (67, '63.8323,53.6363', 4, '21-Jul-2021', '17-Dec-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (68, '03.7343,03.9363', 7, '01-May-2022', '11-Mar-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (69, '53.5343,03.6393', 31, '31-May-2022', '06-Aug-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (70, '23.9313,03.2373', 2, '28-Nov-2022', '23-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (71, '33.0363,43.9353', 8, '16-Sep-2021', '24-Apr-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (72, '13.7353,33.6393', 10, '07-Jan-2022', '23-Aug-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (73, '03.0313,53.2343', 32, '19-Jul-2021', '03-Aug-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (74, '93.2343,13.7393', 52, '27-Dec-2022', '05-Sep-2021', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (75, '13.4373,53.3333', 13, '05-Apr-2022', '26-Oct-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (76, '03.7353,53.6353', 30, '21-Mar-2023', '26-Aug-2021', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (77, '63.8353,23.3353', 81, '25-Feb-2023', '09-Dec-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (78, '03.9333,13.0383', 54, '20-Jan-2022', '21-Mar-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (79, '23.8363,33.7343', 20, '21-Jan-2023', '12-Oct-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (80, '83.5363,23.4383', 27, '07-Dec-2021', '15-Mar-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (81, '43.8343,23.6313', 83, '11-Sep-2022', '19-Jul-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (82, '43.4333,73.5393', 17, '30-Jul-2021', '11-Apr-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (83, '53.0323,13.8343', 88, '18-Dec-2022', '24-Feb-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (84, '53.4333,23.6383', 30, '26-Aug-2022', '26-Sep-2021', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (85, '73.3313,03.2313', 82, '25-Dec-2022', '08-Jan-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (86, '53.4323,23.0323', 74, '26-Feb-2022', '19-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (87, '63.3313,43.5343', 48, '03-Oct-2021', '06-Aug-2021', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (88, '33.1333,43.6333', 47, '02-Aug-2021', '22-Dec-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (89, '83.1393,83.1333', 75, '26-Jan-2022', '19-Jan-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (90, '53.3363,93.2383', 53, '28-Aug-2021', '22-Mar-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (91, '63.9323,63.9363', 21, '09-Jun-2022', '14-Feb-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (92, '03.1363,83.3303', 20, '26-Sep-2022', '12-Mar-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (93, '93.0353,13.3313', 55, '16-May-2022', '02-Jul-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (94, '53.7343,23.9393', 21, '24-Oct-2022', '16-Oct-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (95, '63.6333,43.1393', 17, '05-Dec-2021', '27-Jan-2023', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (96, '43.9363,83.5323', 85, '09-Feb-2022', '23-Sep-2022', 'in_progress');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (97, '83.1383,93.9323', 67, '29-Jul-2022', '17-Jan-2023', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (98, '33.7343,73.8343', 42, '08-Mar-2023', '07-Dec-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (99, '33.5323,73.0353', 39, '06-Aug-2021', '29-Mar-2022', 'completed');
insert into tracking (tracking_id, current_location, order_id, tracking_end_date_time, last_update_date_time, tracking_status) values (100, '43.2383,83.1333', 67, '13-Mar-2023', '25-Jul-2022', 'in_progress');


commit;