PURGE RECYCLEBIN;

SET SERVEROUTPUT ON;

--kill sessions for database admin
BEGIN
    FOR s IN (SELECT sid, serial# FROM v$session WHERE username = 'HUB_ADMIN') LOOP
        DBMS_OUTPUT.PUT_LINE('Killing session: ' || s.sid || ',' || s.serial#);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    END LOOP;
END;
/
-- Kill sessions for managers
BEGIN
    FOR s IN (SELECT sid, serial# FROM v$session WHERE username = 'HUB_MANAGERS') LOOP
        DBMS_OUTPUT.PUT_LINE('Killing session: ' || s.sid || ',' || s.serial#);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    END LOOP;
END;
/
-- Kill sessions for employees
BEGIN
    FOR s IN (SELECT sid, serial# FROM v$session WHERE username = 'HUB_EMPLOYEES') LOOP
        DBMS_OUTPUT.PUT_LINE('Killing session: ' || s.sid || ',' || s.serial#);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    END LOOP;
END;
/
-- Kill sessions for customers
BEGIN
    FOR s IN (SELECT sid, serial# FROM v$session WHERE username = 'HUB_CUSTOMERS') LOOP
        DBMS_OUTPUT.PUT_LINE('Killing session: ' || s.sid || ',' || s.serial#);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    END LOOP;
END;
/


-- Drop the user if already exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER hub_admin CASCADE';
EXCEPTION
    WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN
    RAISE;
    END IF;
END;
/
-- Drop the user if already exists
BEGIN 
    EXECUTE IMMEDIATE 'DROP USER hub_managers CASCADE';
    EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/
-- Drop the user if already exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER hub_employees CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/
-- Drop the user if already exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER hub_customers CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/


-- Create a new user named 'hub_admin' and set a password
CREATE USER hub_admin IDENTIFIED BY hubAdmin23#bas;
-- Create Manager role
CREATE USER hub_managers IDENTIFIED BY hubManagers23#bas;
-- Create Employee role
CREATE USER hub_employees IDENTIFIED BY hubEmployees23#bas;
-- Create Customer role
CREATE USER hub_customers IDENTIFIED BY hubCustomers23#bas;


-- Grant the user the ability to connect to the database
GRANT CONNECT TO hub_admin;
GRANT CONNECT TO hub_managers;
GRANT CONNECT TO hub_employees;
GRANT CONNECT TO hub_customers;


-- Grant the user the ability to create sessions, tables, and sequences
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO hub_admin;
GRANT CREATE SESSION TO hub_managers;
GRANT CREATE SESSION TO hub_employees;
GRANT CREATE SESSION TO hub_customers;

-- Grant the user the ability to drop any table and sequence
GRANT DROP ANY TABLE, DROP ANY SEQUENCE TO hub_admin;

BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'hub_admin') LOOP
    EXECUTE IMMEDIATE 'GRANT ALL PRIVILEGES ON hub_admin.' || t.table_name || ' TO hub_admin';
    END LOOP;
END;
/

-- Grant the user unlimited tablespace quota
GRANT UNLIMITED TABLESPACE TO hub_admin;
GRANT UNLIMITED TABLESPACE TO hub_managers;
GRANT UNLIMITED TABLESPACE TO hub_employees;

-- grant user to create view
GRANT CREATE VIEW TO hub_admin;

--GRANT PERMISION TO TABLES
GRANT CREATE,UPDATE,DELETE,SELECT TO HUB_ADMIN;

--Grant view permission to user admin
GRANT CREATE,SELECT ON car_availability TO HUB_ADMIN;
GRANT CREATE,SELECT ON user_preference TO HUB_ADMIN;
GRANT CREATE,SELECT ON store_employees TO HUB_ADMIN;
GRANT CREATE,SELECT ON customer_order_history TO HUB_ADMIN;
GRANT CREATE,SELECT ON tracking_view TO HUB_ADMIN;
GRANT CREATE,SELECT ON delayed_orders TO HUB_ADMIN;

--Grant view permission to user MANAGERS
GRANT SELECT ON car_availability TO hub_managers;
GRANT SELECT ON user_preference TO hub_managers;
GRANT SELECT ON store_employees TO hub_managers;
GRANT SELECT ON customer_order_history TO hub_managers;
GRANT SELECT ON tracking_view TO hub_managers;
GRANT SELECT ON delayed_orders TO hub_managers;
GRANT SELECT TO hub_managers;

--Grant view permission to user EMPLOYEES
GRANT SELECT ON car_availability TO hub_employees;
GRANT SELECT ON delayed_orders TO hub_employees;

--Grant view permission to user CUSTOMERS
GRANT SELECT ON car_availability TO hub_customers;
GRANT SELECT ON customer_order_history TO hub_customers;

commit;