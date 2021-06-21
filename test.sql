declare
i_test varchar2(10);
err1 exception;
err_code number;
err_msg varchar2(500);
begin
select dummy into i_test from dual connect by level <=2;
exception
 when others then
 err_code := SQLCODE;
 err_msg := SUBSTR(SQLERRM, 1, 200);
 dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end;
/