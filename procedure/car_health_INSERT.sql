create or replace procedure sp_car_health_INSERT(
  --pi_car_health_id CAR_HEALTH.car_health_id%type , 
  pi_vehicle_id CAR_HEALTH.vehicle_id%type, 
  pi_last_service_date CAR_HEALTH.last_service_date%type , 
  pi_next_service_date CAR_HEALTH.next_service_date%type , 
  --pi_health_status CAR_HEALTH.health_status%type , 
  pi_renewal_date CAR_HEALTH.renewal_date%type, 
  --pi_insurance_type CAR_HEALTH.insurance_type%type , 
  pi_insurance_no CAR_HEALTH.insurance_no%type, 
  --pi_check_engine_oil CAR_HEALTH.check_engine_oil%type, 
  --pi_check_tier_pressure CAR_HEALTH.check_tier_pressure%type, 
  --pi_check_air_filter CAR_HEALTH.check_air_filter%type, 
  pi_employee_id CAR_HEALTH.employee_id%type
) as 
v_car_health_count number;
v_last_update_date_time CAR_HEALTH.last_update_date_time%type;
e_car_health_exists exception;
begin
    select TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI') into v_last_update_date_time from dual;
    select count(*) into v_CAR_HEALTH_count from CAR_HEALTH where insurance_no=pi_insurance_no;
    if v_car_health_count > 0 then
        raise e_car_health_exists;
    else
        insert into CAR_HEALTH(car_health_id,vehicle_id,last_service_date,next_service_date,renewal_date,insurance_no,employee_id,last_update_date_time) 
        values 
            (s_CAR_HEALTH_id.NEXTVAL,pi_vehicle_id,pi_last_service_date,pi_next_service_date,pi_renewal_date,pi_insurance_no,pi_employee_id,v_last_update_date_time);
        commit;
        dbms_output.put_line('car_health details added');        
    end if;
exception 
    when e_car_health_exists then
       dbms_output.put_line('car_health details already exists!');

end sp_car_health_INSERT;