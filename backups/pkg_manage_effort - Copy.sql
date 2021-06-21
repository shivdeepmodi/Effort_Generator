create or replace package manage_efforts as
procedure add_main_task
(
p_taskid in TASK_MAIN.TASKID%type,
p_work_task in TASK_MAIN.work_task%type,
p_work_desc in TASK_MAIN.WORK_TASK_DESC%type,
--p_start_date in TASK_MAIN.START_DATE%type,
pt_start_date in varchar2,
p_comments in TASK_MAIN.COMMENTS%type
);

procedure add_sub_task
(
p_work_task in task_subtask.work_task%type,
p_work_task_sub in task_subtask.work_task_sub%type,
p_assigned in task_subtask.assigned%type,
p_START_DATE in task_subtask.START_DATE%type,
p_comments in task_subtask.comments%type
);

procedure add_daily_effort
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_start_date in task_subtask_daily.start_date%type,
p_comments in task_subtask_daily.comments%type
);
end manage_efforts;
/

create or replace package body manage_efforts as

procedure add_main_task
(
p_taskid in TASK_MAIN.TASKID%type,
p_work_task in TASK_MAIN.work_task%type,
p_work_desc in TASK_MAIN.WORK_TASK_DESC%type,
--p_start_date in TASK_MAIN.start_date%type,
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
 if (pt_start_date = 'sysdate') then
  p_start_date:=sysdate;
 else
  p_start_date:=to_date(pt_start_date);
 end if;
 
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
 insert into TASK_MAIN (TASKID,WORK_TASK ,WORK_TASK_DESC,start_date ,complete_date ,STATUS ,COMMENTS) values (p_taskid,p_work_task,p_work_desc,p_start_date,null,'InProgress',p_comments);
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
p_start_date in task_subtask.start_date%type,
p_comments in task_subtask.comments%type
)
as
row_ct number;
task_status task_subtask.status%type;
task_assigned task_subtask.assigned%type;
err_code number;
err_msg varchar2(500);
main_task_does_not_exist exception;
main_task_closed exception;
sub_task_already_assigned exception;
begin
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
 dbms_output.put_line('===============================================================================================================================');
 dbms_output.put_line('Following Sub-Task is captured');
 dbms_output.put_line('Task             :'||p_work_task);
 dbms_output.put_line('Task-SUB         :'||p_work_task_sub);
 dbms_output.put_line('Comments         :'||p_comments);
 dbms_output.put_line('Assigned To      :'||p_assigned);
 dbms_output.put_line('Date             :'||p_start_date);
 dbms_output.put_line('===============================================================================================================================');
 insert into task_subtask (WORK_TASK ,WORK_TASK_SUB,ASSIGNED,start_date ,complete_date, TASK_CLOSE_DATE,STATUS ,COMMENTS) values (p_work_task,p_work_task_sub,p_assigned,p_start_date,NULL,NULL,'InProgress',p_comments);
commit;
exception
 when main_task_does_not_exist then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('SUB Task '||p_work_task||' cannot be assigned as the main task does not exist.');
  dbms_output.put_line('==============================================================================================================================='); 
 when main_task_closed then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('SUB Task '||p_work_task||' cannot be assigned as the main task is closed');
  dbms_output.put_line('===============================================================================================================================');
 when sub_task_already_assigned then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('SUB Task '||p_work_task||' with SUB'||p_work_task_sub|| ' is not captured. '||'It is already assigned to '||task_assigned||' and is in '||task_status||' state.');  
  dbms_output.put_line('===============================================================================================================================');  
 when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
  dbms_output.put_line('===============================================================================================================================');

end;

procedure add_daily_effort
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_start_date in task_subtask_daily.start_date%type,
p_comments in task_subtask_daily.comments%type
)
as
row_ct number;
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
 dbms_output.put_line('===============================================================================================================================');
 dbms_output.put_line('Following daily task is captured');
 dbms_output.put_line('Task     :'||p_work_task);
 dbms_output.put_line('Task SUB :'||p_work_task_sub);
 dbms_output.put_line('Assigned :'||p_assigned);
 dbms_output.put_line('Date     :'||p_start_date);
 dbms_output.put_line('===============================================================================================================================');
 insert into task_subtask_daily (WORK_TASK,WORK_TASK_SUB,ASSIGNED,start_date,complete_date,TASK_CLOSE_DATE,STATUS,COMMENTS  ) values (p_work_task,p_work_task_sub,p_assigned,p_start_date,null,null,'InProgress',p_comments);
commit;
exception
 when main_task_does_not_exist then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the main task does not exist.');
  dbms_output.put_line('==============================================================================================================================='); 
 when  main_task_closed then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the main task does is closed.');
  dbms_output.put_line('==============================================================================================================================='); 
 when sub_task_does_not_exist then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the SUB task does not exist.');
  dbms_output.put_line('==============================================================================================================================='); 
 when sub_task_closed then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' cannot be assigned as the SUB task is closed.');
  dbms_output.put_line('==============================================================================================================================='); 
 when old_task_open then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' SUB '||p_work_task_sub||' cannot be assigned as the daily task is open for '|| was_started);
  dbms_output.put_line('Close '||p_work_task||' SUB '||p_work_task_sub||' started on '|| was_started||' to log new efforts.');
  dbms_output.put_line('==============================================================================================================================='); 
 when today_task_open then
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Daily Task '||p_work_task||' SUB '||p_work_task_sub||' cannot be assigned as todays task is open for '|| was_started);
  dbms_output.put_line('Close '||p_work_task||' SUB '||p_work_task_sub||' started on '|| was_started||' to log new efforts.');
  dbms_output.put_line('==============================================================================================================================='); 
 when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('===============================================================================================================================');
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
  dbms_output.put_line('===============================================================================================================================');
end;

end manage_efforts;
/