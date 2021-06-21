create or replace package manage_efforts as
procedure add_main_task
(
p_taskid in TASK_MAIN.TASKID%type,
p_work_task in TASK_MAIN.work_task%type,
p_work_desc in TASK_MAIN.WORK_TASK_DESC%type,
pt_start_date in varchar2,
p_comments in TASK_MAIN.COMMENTS%type
);

procedure add_sub_task
(
p_work_task in task_subtask.work_task%type,
p_work_task_sub in task_subtask.work_task_sub%type,
p_assigned in task_subtask.assigned%type,
pt_start_date in varchar2,
p_comments in task_subtask.comments%type
);

procedure add_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_start_date in varchar2,
p_comments in task_subtask_daily.comments%type
);

procedure close_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_close_date in varchar2
);

procedure close_sub_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_close_date in varchar2
);

procedure close_main_task
(
p_work_task in task_main.work_task%type,
pt_close_date in varchar2
);
end manage_efforts;
/

create or replace package body manage_efforts as

procedure add_main_task
(
p_taskid in TASK_MAIN.TASKID%type,
p_work_task in TASK_MAIN.work_task%type,
p_work_desc in TASK_MAIN.WORK_TASK_DESC%type,
pt_start_date in varchar2,
p_comments in TASK_MAIN.COMMENTS%type
)
as
p_start_date date;
row_ct number;
task_status TASK_MAIN.status%type;
main_task_already_exists exception;
err_code number;
err_msg varchar2(500);
begin

  p_start_date:=to_date(trim(pt_start_date),'YYYY-MM-DD HH24:MI:SS');
 
 select count(*) into row_ct from TASK_MAIN where work_task = p_work_task;
 
 if ( row_ct = 1) then
  select status into task_status from TASK_MAIN where work_task = p_work_task;
  raise main_task_already_exists;
 end if;
 
 --dbms_output.put_line('===============================================================================================================================');
 --dbms_output.put_line('Following Task is captured');
 --dbms_output.put_line('Task             :'||p_work_task);
 --dbms_output.put_line('Task Description :'||p_work_desc);
 --dbms_output.put_line('Date             :'||p_start_date);
 --dbms_output.put_line('===============================================================================================================================');
 insert into TASK_MAIN (TASKID,WORK_TASK ,WORK_TASK_DESC,start_date ,complete_date ,STATUS ,COMMENTS) 
 values (trim(p_taskid),trim(p_work_task),trim(p_work_desc),p_start_date,null,'InProgress',trim(p_comments));
 commit;
exception
 when main_task_already_exists then
  --dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Main Task '||p_work_task|| ' is not captured. '||'It is in '||task_status||' state.');
  --dbms_output.put_line('===============================================================================================================================');
 when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  --dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
  --dbms_output.put_line('===============================================================================================================================');
end;

procedure add_sub_task
(
p_work_task in task_subtask.work_task%type,
p_work_task_sub in task_subtask.work_task_sub%type,
p_assigned in task_subtask.assigned%type,
pt_start_date in varchar2,
p_comments in task_subtask.comments%type
)
as
row_ct number;
p_start_date date;
task_status task_subtask.status%type;
task_assigned task_subtask.assigned%type;
err_code number;
err_msg varchar2(500);
main_task_does_not_exist exception;
main_task_closed exception;
sub_task_already_assigned exception;
begin

  p_start_date:=to_date(trim(pt_start_date),'YYYY-MM-DD HH24:MI:SS');

 --Check if main task exists.
 select count(*) into row_ct from TASK_MAIN where WORK_TASK = p_work_task;
  if (row_ct = 0) then
  raise main_task_does_not_exist;
 end if;
 --Check if main task is closed.
 select count(*) into row_ct from TASK_MAIN where WORK_TASK = p_work_task and status = 'Completed';
 if (row_ct = 1) then
  raise main_task_closed;
 end if;
 --Check if subtask is already assigned
 select count(*) into row_ct from task_subtask where WORK_TASK = p_work_task and WORK_TASK_SUB =p_work_task_sub and ASSIGNED = p_assigned;
 if (row_ct = 1) then
 select status,assigned into task_status,task_assigned from task_subtask where work_task = p_work_task and work_task_sub=p_work_task_sub and assigned = p_assigned;
  raise sub_task_already_assigned;
 end if;
 --All checks okay. Insert the row.
 --dbms_output.put_line('===============================================================================================================================');
 --dbms_output.put_line('Following Sub-Task is captured');
 --dbms_output.put_line('Task             :'||p_work_task);
 --dbms_output.put_line('Task-SUB         :'||p_work_task_sub);
 --dbms_output.put_line('Comments         :'||p_comments);
 --dbms_output.put_line('Assigned To      :'||p_assigned);
 --dbms_output.put_line('Date             :'||p_start_date);
 --dbms_output.put_line('===============================================================================================================================');
 insert into task_subtask (WORK_TASK ,WORK_TASK_SUB,ASSIGNED,start_date ,complete_date, TASK_CLOSE_DATE,STATUS ,COMMENTS) 
     values (trim(p_work_task),trim(p_work_task_sub),trim(p_assigned),p_start_date,NULL,NULL,'InProgress',trim(p_comments));
commit;
exception
 when main_task_does_not_exist then
  dbms_output.put_line('SUB Task '||p_work_task||' cannot be assigned as the main task does not exist.');
 when main_task_closed then
  dbms_output.put_line('SUB Task '||p_work_task||' cannot be assigned as the main task is closed');
 when sub_task_already_assigned then
  dbms_output.put_line('SUB Task '||p_work_task||' with SUB'||p_work_task_sub|| ' is not captured. '||'It is already assigned to '||task_assigned||' and is in '||task_status||' state.');  
 when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end;

procedure add_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_start_date in varchar2,
p_comments in task_subtask_daily.comments%type
)
as
row_ct number;
p_start_date date;
was_started date;
main_task_does_not_exist exception;
main_task_closed exception;
sub_task_does_not_exist exception;
sub_task_closed exception;
old_task_open exception;    -- Open Task Old
today_task_open exception;   -- Open Task Today
err_code number;
err_msg varchar2(500);
begin
  p_start_date:=to_date(trim(pt_start_date),'YYYY-MM-DD HH24:MI:SS');
 
 --Check if main task exists.
 select count(*) into row_ct from TASK_MAIN where WORK_TASK = p_work_task;
  if (row_ct = 0) then
  raise main_task_does_not_exist;
 end if;
 
 --Check if main task is closed
 select count(*) into row_ct from TASK_MAIN where WORK_TASK = p_work_task and status = 'Completed';
 if (row_ct = 1) then
  raise main_task_closed;
 end if;
 
 --Check if sub task does not exist.
 select count(*) into row_ct from task_subtask where WORK_TASK = p_work_task and work_task_sub=p_work_task_sub and assigned = p_assigned;
  if (row_ct = 0) then
  raise sub_task_does_not_exist;
 end if;
 --Check if sub task is closed
 select count(*) into row_ct from task_subtask where WORK_TASK = p_work_task and work_task_sub=p_work_task_sub and assigned = p_assigned and status = 'Completed';
 if (row_ct = 1) then
  raise sub_task_closed;
 end if; 
 
 --Check if old task are open.
 select count(*) into row_ct
  from task_subtask_daily subt
 where subt.work_task = p_work_task
   and subt.assigned = p_assigned
   and subt.work_task_sub = p_work_task_sub
   and trunc(subt.start_date) < trunc(sysdate)
   and subt.status = 'InProgress';
 if(row_ct >= 1 ) then
  select start_date into was_started
  from task_subtask_daily subt
 where subt.work_task = p_work_task
   and subt.work_task_sub = p_work_task_sub
   and subt.assigned = p_assigned
   and trunc(subt.start_date) < trunc(sysdate)
   and subt.status = 'InProgress';  
  raise old_task_open;
 end if;
 
 --Check if task is already open, which effectively means work is already in progress for TODAY
 select count(*) into row_ct
  from task_subtask_daily subt
 where subt.work_task = p_work_task
   and subt.work_task_sub = p_work_task_sub
   and subt.assigned = p_assigned
   and trunc(subt.start_date) = trunc(sysdate)
   and subt.status = 'InProgress';
 if(row_ct = 1 ) then
  select start_date into was_started
  from task_subtask_daily subt
 where subt.work_task = p_work_task
   and subt.work_task_sub = p_work_task_sub
   and subt.assigned = p_assigned
   and trunc(subt.start_date) = trunc(sysdate)
   and subt.status = 'InProgress';  
  raise today_task_open;
 end if ;
 -- The assumption here is either today's task does not exist or is closed. If it is closed, we have to track our new efforts.
 -- dbms_output.put_line('===============================================================================================================================');
 -- dbms_output.put_line('Following daily task is captured');
 -- dbms_output.put_line('Task     :'||p_work_task);
 -- dbms_output.put_line('Task SUB :'||p_work_task_sub);
 -- dbms_output.put_line('Assigned :'||p_assigned);
 -- dbms_output.put_line('Date     :'||p_start_date);
 -- dbms_output.put_line('===============================================================================================================================');
 insert into task_subtask_daily (WORK_TASK,WORK_TASK_SUB,ASSIGNED,start_date,complete_date,TASK_CLOSE_DATE,STATUS,COMMENTS  ) 
 values (trim(p_work_task),trim(p_work_task_sub),trim(p_assigned),p_start_date,null,null,'InProgress',trim(p_comments));
commit;
exception
 when main_task_does_not_exist then
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the main task does not exist.');

 when  main_task_closed then
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the main task is closed.');

 when sub_task_does_not_exist then
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the SUB task does not exist.');

 when sub_task_closed then
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the SUB task is closed.');

 when old_task_open then
  dbms_output.put_line('Daily Task '||p_work_task||' SUB '||p_work_task_sub||' cannot be assigned as the daily task is open for '|| was_started);
  dbms_output.put_line('Close '||p_work_task||' SUB '||p_work_task_sub||' started on '|| was_started||' to log new efforts.');

 when today_task_open then
  dbms_output.put_line('Daily Task '||p_work_task||' SUB '||p_work_task_sub||' cannot be assigned as todays task is open for '|| was_started);
  dbms_output.put_line('Close '||p_work_task||' SUB '||p_work_task_sub||' started on '|| was_started||' to log new efforts.');

 when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end;

procedure close_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_close_date in varchar2
)
as
  row_ct number;
  err_code number;
  err_msg varchar2(500);
  p_close_date date;
  main_task_does_not_exist exception;
  main_task_already_closed exception;
  sub_task_exception exception;
  daily_task_exception exception;
  daily_task_serious_exception exception;
  
  TYPE type_table_daily IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_daily type_table_daily;
  TYPE type_table_sub IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_sub type_table_sub;
  TYPE type_table_main IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_main type_table_main;

begin
 EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  p_close_date:=to_date(pt_close_date,'YYYY-MM-DD HH24:MI:SS');

  select * bulk collect into row_type_table_main from task_main where work_task = p_work_task;
  if ( row_type_table_main.count = 0 ) then 
    raise main_task_does_not_exist;
  else
	row_ct:=row_type_table_main.count;
	if (row_type_table_main(row_ct).STATUS = 'Completed' ) then
		raise main_task_already_closed;
	end if;
	
	select * bulk collect into row_type_table_sub from TASK_SUBTASK where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	if (row_type_table_sub.count = 0 ) then
		raise sub_task_exception;
	end if;

	select * bulk collect into row_type_table_daily from TASK_SUBTASK_DAILY where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	if (row_type_table_daily.count = 0 ) then
		raise daily_task_exception;
	end if;
    
	select * bulk collect into row_type_table_daily from TASK_SUBTASK_DAILY where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	if (row_type_table_daily.count > 1 ) then
		raise daily_task_serious_exception;
	end if;
  
	update TASK_SUBTASK_DAILY set status = 'Completed',COMPLETE_DATE=p_close_date, TASK_CLOSE_DATE=sysdate 
	 where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	commit;
  end if;

  --select count(*) into row_ct from task_subtask where work_task = p_work_task and work_task_sub and assigned = p_assigned and status = 'InProgress';
  --select count(*) into row_ct from task_subtask_daily where work_task = p_work_task and work_task_sub and assigned = p_assigned and status = 'InProgress';
exception
  when main_task_does_not_exist then
    dbms_output.put_line('Daily Task : Main Task '||p_work_task||' does not exist.');
  when main_task_already_closed then
    dbms_output.put_line('Daily Task : Main Task '||p_work_task||' already closed.');
  when sub_task_exception then
	dbms_output.put_line('Daily Task(sub_task_exception) :'||p_work_task||'.'||p_work_task_sub||' assigned to '||p_assigned||' cannot be closed. Check State, validitity of SUB Task.');
  when daily_task_exception then
	dbms_output.put_line('Daily Task(daily_task_exception) :'||p_work_task||'.'||p_work_task_sub||' assigned to '||p_assigned||' cannot be closed. Check State, validitity of DAILY Task.');
  when daily_task_serious_exception then
	dbms_output.put_line('Serious EXCEPTION: Daily Task :'||p_work_task||'.'||p_work_task_sub||' assigned to '||p_assigned||' has more then one daily tasks open. Review of data required.');

	
	
  when others then
    err_code := SQLCODE;
    err_msg := SUBSTR(SQLERRM, 1, 200);
    dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);

end;

procedure close_sub_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
pt_close_date in varchar2
)
as
  row_ct number;
  err_code number;
  err_msg varchar2(500);
  p_close_date date;
  main_task_does_not_exist exception;
  main_task_already_closed exception;
  sub_task_exception exception;
  daily_task_open exception;
  
  TYPE type_table_daily IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_daily type_table_daily;
  TYPE type_table_sub IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_sub type_table_sub;
  TYPE type_table_main IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_main type_table_main;

begin
 EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  
  p_close_date:=to_date(pt_close_date,'YYYY-MM-DD HH24:MI:SS');
 
  select * bulk collect into row_type_table_main from task_main where work_task = p_work_task;
  -- Check task does not exist
  if ( row_type_table_main.count = 0 ) then 
    raise main_task_does_not_exist;
  else
	row_ct:=row_type_table_main.count;
	if (row_type_table_main(row_ct).STATUS = 'Completed' ) then
		raise main_task_already_closed;
	end if;
	
	select * bulk collect into row_type_table_sub from TASK_SUBTASK where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	if (row_type_table_sub.count = 0 ) then
		raise sub_task_exception;
	end if;

	select * bulk collect into row_type_table_daily from TASK_SUBTASK_DAILY where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	if (row_type_table_daily.count > 0 ) then
		raise daily_task_open;
	end if;
    

	update TASK_SUBTASK set status = 'Completed',COMPLETE_DATE=p_close_date, TASK_CLOSE_DATE=sysdate 
	 where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status='InProgress';
	commit;
  end if;

exception
  when main_task_does_not_exist then
    dbms_output.put_line('Daily Task : Main Task '||p_work_task||' does not exist.');
  when main_task_already_closed then
    dbms_output.put_line('Daily Task : Main Task '||p_work_task||' already closed.');
	
  when sub_task_exception then
	dbms_output.put_line('Daily Task :'||p_work_task||'.'||p_work_task_sub||' assigned to '||p_assigned||' cannot be closed. Check State, validitity of SUB Task.');
	
  when daily_task_open then
	dbms_output.put_line('SUB Task :'||p_work_task||'.'||p_work_task_sub||' assigned to '||p_assigned||' cannot be closed. Corresponding DAILY Task is open.');
	
  when others then
    err_code := SQLCODE;
    err_msg := SUBSTR(SQLERRM, 1, 200);
    dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);

end;

procedure close_main_task
(
p_work_task in task_main.work_task%type,
pt_close_date in varchar2
)
as
  row_ct number;
  err_code number;
  err_msg varchar2(500);
  p_close_date date;
  main_task_does_not_exist exception;
  main_task_already_closed exception;
  sub_task_exception exception;
  daily_task_open exception;
  
  TYPE type_table_daily IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_daily type_table_daily;
  TYPE type_table_sub IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_sub type_table_sub;
  TYPE type_table_main IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table_main type_table_main;
  
begin
   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  
  p_close_date:=to_date(pt_close_date,'YYYY-MM-DD HH24:MI:SS');
 
  select * bulk collect into row_type_table_main from task_main where work_task = p_work_task;
  -- Check task does not exist
  if ( row_type_table_main.count = 0 ) then 
    raise main_task_does_not_exist;
  else
	row_ct:=row_type_table_main.count;
	if (row_type_table_main(row_ct).STATUS = 'Completed' ) then
		raise main_task_already_closed;
	end if;

	select * bulk collect into row_type_table_daily from TASK_SUBTASK_DAILY where work_task = p_work_task and status='InProgress';
	if (row_type_table_daily.count > 0 ) then
		raise daily_task_open;
	end if;

	select * bulk collect into row_type_table_sub from TASK_SUBTASK where work_task = p_work_task and status='InProgress';
	if (row_type_table_sub.count > 0 ) then
		raise sub_task_exception;
	end if;

	dbms_output.put_line('Main Task : Before closing main task');
	update TASK_MAIN set status = 'Completed',COMPLETE_DATE=p_close_date, TASK_CLOSE_DATE=sysdate 
	 where work_task = p_work_task and status='InProgress';
	commit;
  end if;

exception
  when main_task_does_not_exist then
    dbms_output.put_line('Main Task '||p_work_task||' does not exist.');
  when main_task_already_closed then
    dbms_output.put_line('Main Task '||p_work_task||' already closed.');

  when daily_task_open then
	dbms_output.put_line('Main Task :'||p_work_task||' Cannot be closed. One of the DAILY Task is open.');
  
  when sub_task_exception then
	dbms_output.put_line('Main Task :'||p_work_task||' Cannot be closed. One of the SUB Task is open.');
		
  when others then
    err_code := SQLCODE;
    err_msg := SUBSTR(SQLERRM, 1, 200);
    dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);

end close_main_task;




end manage_efforts;
/