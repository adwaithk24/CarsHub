create or replace procedure sp_employee_onboarding(
    pi_first_name employees.first_name%type,
    pi_last_name employees.last_name%type,
    pi_ssn_no employees.ssn_no%type,
    pi_designation employees.designation%type,
    pi_phone_no employees.phone_no%type,
    pi_email_id employees.email_id%type,
    pi_store_id employees.store_id%type,
    pi_address_line_1 employees.address_line_1%type,
    pi_address_line_2 employees.address_line_2%type,
    pi_city employees.city%type,
    pi_state employees.state%type,
    pi_country employees.country%type,
    pi_zip_code employees.zip_code%type,
    pi_salary employees.salary%type,
    pi_date_of_joining employees.date_of_joining%type
)as 
    v_employee_count number(1); 
    v_manager_id number;
    v_manager_count number(1);
    v_emp_store number;
    v_store_exists number(1);
    e_employee_exists exception;
    e_designation_not_exists exception;
    e_manager_exists exception;
    e_store_does_not_exist exception;
begin
    select count(*) into v_employee_count from employees where ssn_no = pi_ssn_no; -- Counter for checking the unique dataset for employees table based on unique SSN Number
    select count(*) into v_manager_count from employees where store_id = pi_store_id and lower(designation) = 'manager'; -- Counter for checking there is no 2 managers assigned to the same store
    select count(*) into v_store_exists from store_location where store_id = pi_store_id; -- Counter for checking there is no data entered in employees table for non existent store
    if v_store_exists = 0 then
        raise e_store_does_not_exist;
    else if v_employee_count > 0 then
        RAISE e_employee_exists;

    else if lower(pi_designation) = 'manager' and v_manager_count = 0 then
        insert into employees values(s_employees_id.nextval,pi_first_name,pi_last_name,pi_ssn_no,pi_designation,pi_phone_no,pi_email_id,pi_store_id,pi_address_line_1,pi_address_line_2,pi_city,pi_state,pi_country,pi_zip_code,1,pi_salary,pi_date_of_joining);

    else if lower(pi_designation) = 'manager' and v_manager_count > 0 then
        raise e_manager_exists;

    else if lower(pi_designation) = 'employee' then
        select employee_id into v_manager_id from employees where store_id=pi_store_id and lower(designation) = 'manager';
        insert into employees values(s_employees_id.nextval,pi_first_name,pi_last_name,pi_ssn_no,pi_designation,pi_phone_no,pi_email_id,pi_store_id,pi_address_line_1,pi_address_line_2,pi_city,pi_state,pi_country,pi_zip_code,v_manager_id,pi_salary,pi_date_of_joining);
        dbms_output.put_line('----------------------------Employee created----------------------------');

    else
        RAISE e_designation_not_exists;
        --DBMS_OUTPUT.PUT_LINE('--------------------------Designation does not exists--------------------------');

    end if;
    end if;
    end if;
    end if;
    end if;
    commit;

EXCEPTION
    WHEN e_store_does_not_exist THEN
        DBMS_OUTPUT.PUT_LINE('-----------------------------Store does not exists-----------------------------');
    WHEN e_employee_exists THEN
        DBMS_OUTPUT.PUT_LINE('----------------------------Employee already exists----------------------------');
    WHEN e_designation_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('--------------------------Designation does not exists--------------------------');
    WHEN e_manager_exists THEN
        DBMS_OUTPUT.PUT_LINE('----------------------Manager already exists for the store---------------------');
end sp_employee_onboarding;
