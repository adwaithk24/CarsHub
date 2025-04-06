create or replace procedure sp_store_onboarding(
    pi_address_line_1 store_location.address_line_1%type,
    pi_address_line_2 store_location.address_line_2%type,
    pi_city store_location.city%type,
    pi_state store_location.state%type,
    pi_country store_location.country%type,
    pi_zip_code store_location.zip_code%type,
    pi_store_name store_location.store_name%type,
    pi_store_location store_location.store_location%type
)as 
    v_store_count number(1);
    e_store_exists exception;
begin
    select count(*) into v_store_count from store_location where store_name = pi_store_name;
    if v_store_count > 0 THEN
        RAISE e_store_exists;
    else
        insert into store_location values(s_store_id.nextval,pi_address_line_1,pi_address_line_2,pi_city,pi_state,pi_country,pi_zip_code,pi_store_name,pi_store_location);
        dbms_output.put_line('----------------------------Store Location Added----------------------------');
    end if;
    commit;

EXCEPTION
    WHEN e_store_exists THEN
        DBMS_OUTPUT.PUT_LINE('----------------------------Store Already Exists----------------------------');
end sp_store_onboarding;