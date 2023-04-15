create or replace procedure sp_insert_card_details (
pi_customer_id card_details.customer_id%type,
pi_card_no card_details.card_no%type,
pi_card_name card_details.card_name%type
) as v_card_count number;
v_customer_id number(1);
e_card_exists EXCEPTION;
    BEGIN
        select count(*) into v_customer_id from customers where pi_customer_id=customers.customer_id;
        select count(*) into v_card_count from card_details where card_no = pi_card_no and customer_id=pi_customer_id;
    IF v_customer_id = 0 THEN
        DBMS_OUTPUT.PUT_LINE('----------Please enter a valid Customer ID----------');
    ELSIF v_card_count > 0 THEN
        RAISE e_card_exists;
    ELSE
        insert into card_details values (s_card_id.nextval,pi_customer_id,pi_card_no,pi_card_name);
		dbms_output.put_line('----------Card details saved----------');        
    END IF;
    COMMIT;


EXCEPTION
    WHEN e_card_exists THEN
        DBMS_OUTPUT.PUT_LINE('----------Card already exists, Please try with a different card number----------');

end sp_insert_card_details;