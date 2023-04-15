create or replace procedure sp_customer_onboarding (
pi_first_name CUSTOMERS.FIRST_NAME%type,
pi_last_name CUSTOMERS.LAST_NAME%type,
pi_email_id CUSTOMERS.EMAIL_ID%type,
pi_phone_no CUSTOMERS.PHONE_NO%type,
pi_LICENSE_NO CUSTOMERS.LICENSE_NO%type,
pi_user_status CUSTOMERS.USER_STATUS%type,
pi_date_of_birth CUSTOMERS.DATE_OF_BIRTH%type,
pi_gender CUSTOMERS.GENDER%type,
pi_address_line_1 CUSTOMERS.ADDRESS_LINE_1%type,
pi_address_line_2 CUSTOMERS.ADDRESS_LINE_2%type,
pi_city CUSTOMERS.CITY%type,
pi_state CUSTOMERS.STATE%type,
pi_country CUSTOMERS.COUNTRY%type,
pi_zip_code CUSTOMERS.ZIP_CODE%type
) as v_customer_count number;
e_customer_exists EXCEPTION;
    BEGIN
        select count(*) into v_customer_count from customers where LICENSE_NO = pi_LICENSE_NO or phone_no = pi_phone_no or email_id = pi_email_id;
    IF pi_phone_no not  BETWEEN 1111111111 AND 9999999999  THEN
        DBMS_OUTPUT.PUT_LINE('------------Please enter a correct Phone Number------------');
    ELSIF pi_email_id not like ('%@%.%') THEN
        DBMS_OUTPUT.PUT_LINE('------------Please enter a correct Email ID------------');
    ELSIF trunc(months_between(sysdate,pi_date_of_birth) / 12)<18 THEN
        DBMS_OUTPUT.PUT_LINE('------------Customers Below Age of 18 are not allowed to register------------');
    ELSIF v_customer_count > 0 THEN
        RAISE e_customer_exists;
    ELSE
        insert into customers values (s_customer_id.nextval,pi_first_name,pi_last_name,pi_email_id,pi_phone_no,pi_LICENSE_NO,pi_user_status,pi_date_of_birth,pi_gender,pi_address_line_1,pi_address_line_2,pi_city,pi_state,pi_country,pi_zip_code);
		dbms_output.put_line('User created');        
    END IF;
commit;

EXCEPTION
    WHEN e_customer_exists THEN
        DBMS_OUTPUT.PUT_LINE('------------Customer already exists------------');

end sp_customer_onboarding;


--PURGE RECYCLEBIN;
--SET SERVEROUTPUT ON;
--begin
--    sp_customer_onboarding('LAURA','MAXIN','MAXIN_L@HOTMAIL.com',7232231333,'321111D'
--    ,'active','09-09-2004','female','29 warren st','','Boston','Massachusetts','United States'
--    ,02119);
--end;