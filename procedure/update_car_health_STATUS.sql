create or replace procedure sp_update_car_health_STATUS(
  pi_vehicle_id CAR_HEALTH.vehicle_id%type , 
  --pi_health_status CAR_HEALTH.health_status%type ,
  pi_store_id employees.store_id%type,
  pi_check_engine_oil CAR_HEALTH.check_engine_oil%type, 
  pi_check_tier_pressure CAR_HEALTH.check_tier_pressure%type, 
  pi_check_air_filter CAR_HEALTH.check_air_filter%type, 
  pi_employee_id CAR_HEALTH.employee_id%type
) as 
v_car_health_count number;
v_last_update_date_time CAR_HEALTH.last_update_date_time%type;
e_emp_update_fail exception;
begin
--  current timestamp
    select TO_CHAR(CURRENT_TIMESTAMP,'DD-MON-RR HH.MI.SSXFF PM') into v_last_update_date_time from dual;
    -- checks whether emp belongs to that store
    select count(*) into v_CAR_HEALTH_count from CAR_HEALTH where vehicle_id=pi_vehicle_id
    and pi_employee_id in (select e.employee_id from employees e 
    join store_location s on e.store_id = s.store_id 
    where s.store_id  = pi_store_id ) ;
    --if car exists
    if v_car_health_count = 0 then
        raise e_emp_update_fail;
    else
    --update if checks are proper
        update CAR_HEALTH set
            check_engine_oil = pi_check_engine_oil,
            check_tier_pressure = pi_check_tier_pressure,
            check_air_filter = pi_check_air_filter,
            employee_id = pi_employee_id,
            last_update_date_time = v_last_update_date_time
                where vehicle_id = pi_vehicle_id;
        IF pi_check_engine_oil = 1 OR pi_check_tier_pressure = 1 OR pi_check_air_filter = 1
            THEN
            update CAR_HEALTH set health_status = 'NOT_OKAY' where vehicle_id = pi_vehicle_id;
        ELSE
            update CAR_HEALTH set health_status = 'OKAY' where vehicle_id = pi_vehicle_id;
        END IF;
        dbms_output.put_line('car_health updated');
        COMMIT;
    end if;
exception 
    when e_emp_update_fail then
       dbms_output.put_line('vehicle doesnot exists or employee not authorised!');
    when others then
       dbms_output.put_line('something went wrong!');
end sp_update_car_health_STATUS;


--PURGE RECYCLEBIN;
--SET SERVEROUTPUT ON;
--begin
--sp_update_car_health_STATUS(93,8,0,0,0,85);
--end;