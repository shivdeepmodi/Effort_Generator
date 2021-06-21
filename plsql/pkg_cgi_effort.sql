create or replace package pkg_cgi_effort as
procedure gen_sub_or_dly_tsk_capture(p_task_type varchar2);
procedure capture_sub_or_dly_tsk_dtls(p_task_type varchar2,p_work_task in task_subtask.work_task%type);

procedure get_mt_in_progress_quick_close;
procedure quick_close_all_tasks
(
p_work_task in task_main.work_task%type,
tp_close_date in varchar2
);


procedure get_open_sub_task;

procedure get_open_daily_task;
procedure close_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_close_date in varchar2
);


procedure close_sub_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_close_date in varchar2
);

procedure get_open_main_task;
procedure close_main_task
(
p_work_task in task_subtask_daily.work_task%type,
p_close_date in varchar2
);


end;
/


create or replace package body pkg_cgi_effort as
procedure gen_sub_or_dly_tsk_capture(p_task_type varchar2)
as
	TYPE type_main_table IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
	row_main_type_table type_main_table;
	
	row_ct number;
	submit_action varchar2(100);
	unknown_task exception;
begin
if (p_task_type = 'SUBTASK') then
	dbms_output.put_line('<p class=ht1> Create SUB Task </p>');
	submit_action:='/cgi-bin/call_create_sub_or_daily_task.py';
elsif (p_task_type = 'DAILYTASK') then
	dbms_output.put_line('<p class=ht1> Create DAILY Task </p>');
	submit_action:='/cgi-bin/call_create_sub_or_daily_task.py';
else
	raise unknown_task;
end if;

select * bulk collect into row_main_type_table from task_main where status = 'InProgress';

IF ( row_main_type_table.count > 0) THEN

	dbms_output.put_line('<form action="'||submit_action||'" method="post" target="_blank">');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Task Name:</label>');	
	dbms_output.put_line('<select id="TASK_NAME" name="TASK_NAME" onchange="myFunction()" >');
	for ii in 1 .. row_main_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_main_type_table(ii).work_task||'>'||row_main_type_table(ii).work_task||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	dbms_output.put_line('<select id="dTASK_DESCRIPTION" name="dTASK_DESCRIPTION" disabled >');
	for ii in 1 .. row_main_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_main_type_table(ii).work_task_desc||'>'||row_main_type_table(ii).work_task_desc||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	dbms_output.put_line('</div>');
	dbms_output.put_line('<input  maxlength="50" size="50" name="TASK_TYPE" value='||p_task_type||' type="hidden">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');	
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<input name="submit" type="submit">');
		
	dbms_output.put_line('</div>');
	dbms_output.put_line('</form>');

	dbms_output.put_line('<script type = "text/JavaScript">');
	dbms_output.put_line('function myFunction() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	dbms_output.put_line('var z=y[x].index;');
	dbms_output.put_line('var oText=y[x].text;');
	--dbms_output.put_line('<!--alert(oText);-->');
	--dbms_output.put_line('<!--alert("Index: " + y[x].index + " is " + y[x].text);-->');
	--dbms_output.put_line('<!--alert("selectedIndex:"+z);-->');
	
	dbms_output.put_line('document.getElementById("dTASK_DESCRIPTION").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_TYPE").selectedIndex=z;');
	
	
	dbms_output.put_line('}');

	dbms_output.put_line('function validateForm() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	
	dbms_output.put_line('var w=y[x].text;');
	
	
	dbms_output.put_line('if (w == "") {');
	dbms_output.put_line('	alert("Task must be selected");');
	dbms_output.put_line('	return false;');
	dbms_output.put_line('}');
	dbms_output.put_line('}');
	dbms_output.put_line('</script>');
else
	dbms_output.put_line('<div>');
	dbms_output.put_line('No Main Task Open. No work to do');
	dbms_output.put_line('</div>');

end if;
exception
	when unknown_task then
		dbms_output.put_line('<div>');
		dbms_output.put_line('Unknown TASK Request');
		dbms_output.put_line('</div>');
end gen_sub_or_dly_tsk_capture;

procedure capture_sub_or_dly_tsk_dtls(p_task_type varchar2,p_work_task in task_subtask.work_task%type) as
    row_ct NUMBER;
	ii number;
	form_action varchar2(60);
	invalid_task_request exception;
	err_code number;
	err_msg varchar2(500);
	TYPE type_table_sub IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
	row_type_table_sub type_table_sub;	
	row_type_table_sub_any type_table_sub;	
	TYPE type_table_sub_daily IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
	row_type_table_sub_daily type_table_sub_daily;	
	row_type_table_sub_daily_any type_table_sub_daily;	
	sub_task_does_not_exist exception;
	daily_tasks_open exception;
BEGIN
if (p_task_type = 'SUBTASK' ) then
	form_action:='/cgi-bin/create_sub_or_daily_task.py';
elsif (p_task_type = 'DAILYTASK' ) then
	form_action:='/cgi-bin/create_sub_or_daily_task.py';
else
	raise invalid_task_request;
end if;

select * bulk collect into row_type_table_sub from task_subtask where work_task=p_work_task and status='InProgress';
select * bulk collect into row_type_table_sub_any from task_subtask where work_task=p_work_task;
select * bulk collect into row_type_table_sub_daily_any from task_subtask_daily where work_task=p_work_task;


if (p_work_task = 'SUBTASK' ) then
	if (row_type_table_sub.COUNT > 0) then
		dbms_output.put_line('The SUB Task '||p_work_task||' already exists');
		dbms_output.put_line('<table>');
		dbms_output.put_line('<tr><td>'||'TASK_NAME'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'CREATED'||'</td><td>'||'COMPLETED'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
		for ii in (select * from task_subtask st WHERE st.work_task = p_work_task)
		loop
			dbms_output.put_line('<tr><td>'||ii.work_task||'</td><td>'||ii.work_task_sub||'</td><td>'||ii.ASSIGNED||'</td><td>'||ii.start_date||'</td><td>'||ii.complete_date||'</td><td>'||ii.status||'</td><td>'||ii.comments||'</td></tr>');
		end loop;
		dbms_output.put_line('</table>');	
	elsif (row_type_table_sub.COUNT=0) then
		dbms_output.put_line('<div>');
		dbms_output.put_line('SUBTASK '||p_work_task||' does not exist');
		dbms_output.put_line('</div>');
	end if;	
elsif(p_work_task = 'DAILYTASK' ) then
	select * bulk collect into row_type_table_sub_daily from task_subtask_daily where work_task=p_work_task and status='InProgress';
	if (row_type_table_sub_daily.count > 0) then
		raise daily_tasks_open;
	end if;
	if (row_type_table_sub.COUNT=0) then
		raise sub_task_does_not_exist;
	end if;
end if;
	


	dbms_output.put_line('<form action="'||form_action||'" method="post">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Task Name:</label>');
	dbms_output.put_line('<input  maxlength="50" size="50" name="d_TASK_NAME" value="'||p_work_task||'"'||' disabled>');
	dbms_output.put_line('<input  maxlength="50" size="50" name="TASK_NAME" value='||p_work_task||' type="hidden">');
	dbms_output.put_line('</div>');

	if (p_task_type = 'SUBTASK' ) then	
			if (row_type_table_sub_any.count > 0) then
			
			dbms_output.put_line('<table>');
			dbms_output.put_line('<tr><td colspan=7>'||'Existing SUB Tasks for '||p_work_task||'</td></tr>');
			dbms_output.put_line('<tr><td>'||'TASK_NAME'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'CREATED'||'</td><td>'||'COMPLETED'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
			for ii in 1 .. row_type_table_sub_any.count
			loop
				dbms_output.put_line('<tr><td>'||row_type_table_sub_any(ii).work_task||'</td><td>'||row_type_table_sub_any(ii).work_task_sub||'</td><td>'||row_type_table_sub_any(ii).ASSIGNED||'</td><td>'||row_type_table_sub_any(ii).start_date||'</td><td>'||row_type_table_sub_any(ii).complete_date||'</td><td>'||row_type_table_sub_any(ii).status||'</td><td>'||row_type_table_sub_any(ii).comments||'</td></tr>');
			end loop;
			dbms_output.put_line('</table>');		
		end if;
	elsif (p_task_type = 'DAILYTASK' ) then
			if (row_type_table_sub_daily_any.count > 0) then
			
			dbms_output.put_line('<table>');
			dbms_output.put_line('<tr><td colspan=7>'||'Existing DAILY Tasks for '||p_work_task||'</td></tr>');
			dbms_output.put_line('<tr><td>'||'TASK_NAME'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'CREATED'||'</td><td>'||'COMPLETED'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
			for ii in 1 .. row_type_table_sub_daily_any.count
			loop
				dbms_output.put_line('<tr><td>'||row_type_table_sub_daily_any(ii).work_task||'</td><td>'||row_type_table_sub_daily_any(ii).work_task_sub||'</td><td>'||row_type_table_sub_daily_any(ii).ASSIGNED||'</td><td>'||row_type_table_sub_daily_any(ii).start_date||'</td><td>'||row_type_table_sub_daily_any(ii).complete_date||'</td><td>'||row_type_table_sub_daily_any(ii).status||'</td><td>'||row_type_table_sub_daily_any(ii).comments||'</td></tr>');
			end loop;
			dbms_output.put_line('</table>');		
		end if;
	
	end if;

	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">WORK_TASK_SUB</label>');
	dbms_output.put_line('<input  maxlength="50" size="50" name="TASK_NAME_SUB">');
	dbms_output.put_line('</div>');	
		
	if (p_task_type = 'SUBTASK' ) then	
		dbms_output.put_line('<div>');
		dbms_output.put_line('<label class="ht1"> Enter Daily task Details? </label>');
		dbms_output.put_line('<label > Yes </label>');
		dbms_output.put_line('<input type="radio"  name="ADD_DAILYTASK" value="YES" checked>');
		dbms_output.put_line('<label > No </label>');
		dbms_output.put_line('<input type="radio"  name="ADD_DAILYTASK" value="NO" >');
		dbms_output.put_line('</div>');
		
	elsif (p_task_type = 'DAILYTASK' ) then
		dbms_output.put_line('<input  maxlength="3" size="3" name="ADD_DAILYTASK" value="YES" type="hidden">');
	end if;
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Task Comments:</label>');
	dbms_output.put_line('<input  maxlength="500" size="50" name="TASK_COMMENT">');
	dbms_output.put_line('</div>  ');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Task Date:</label>');
	dbms_output.put_line('<input type="date" id="theDate" name="theDate">');
	dbms_output.put_line('<input type="time" id="theTime" name="theTime"  min="00:00" max="23:59" required> ');

	dbms_output.put_line('</div>');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Assigned:</label>');
	dbms_output.put_line('<input  maxlength="100" size="50" name="TASK_ASSIGNED" value="DEFAULT">');
	dbms_output.put_line('</div>  ');
	
	
	dbms_output.put_line('<input  maxlength="50" size="50" name="TASK_TYPE" value='||p_task_type||' type="hidden">');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');
	
	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="submit" type="submit">');
	dbms_output.put_line('</p>');
	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="Reset" value="Reset" type="reset">');
	dbms_output.put_line('<p>');
	
	dbms_output.put_line('</form>');	
  
	dbms_output.put_line('<script>');	
	dbms_output.put_line('Date.prototype.dateToInput = function(){');
	dbms_output.put_line('	return this.getFullYear() + "-" + ("0" + (this.getMonth() + 1)).substr(-2,2) + "-" + ("0" + this.getDate()).substr(-2,2);');
	dbms_output.put_line('}');
	dbms_output.put_line('Date.prototype.timeToInput = function(){');
	dbms_output.put_line('	return  ("0" + (this.getHours())).substr(-2,2) + ":" + ("0" + this.getMinutes()).substr(-2,2);');
	dbms_output.put_line('}');

	dbms_output.put_line('var date = new Date();');
	dbms_output.put_line('document.getElementById("theDate").value = date.dateToInput();');
	dbms_output.put_line('document.getElementById("theTime").value = date.timeToInput();	');  
	dbms_output.put_line('</script>');		
exception
	when invalid_task_request then
		dbms_output.put_line('<div>');
		dbms_output.put_line('<p class=ht1>Invalid Request: capture_sub_or_dly_tsk_dtls</p>');
		dbms_output.put_line('</div>');
	when daily_tasks_open then
		dbms_output.put_line('<div>');
		dbms_output.put_line('Daily tasks open for subtask:'||p_work_task||' Daily task creation will not happen.');
		dbms_output.put_line('</div>');
	when sub_task_does_not_exist then
		dbms_output.put_line('<div>');
		dbms_output.put_line('SUBTASK '||p_work_task||' does not exist or is closed. Daily task creation will not happen.');
		dbms_output.put_line('</div>');
	when others then
		err_code := SQLCODE;
		err_msg := SUBSTR(SQLERRM, 1, 200);
		dbms_output.put_line('<div>');
		dbms_output.put_line('<p class=ht1>');
		dbms_output.put_line('Exception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
		dbms_output.put_line('</p>');
		dbms_output.put_line('</div>');
END capture_sub_or_dly_tsk_dtls;

--Get Task information for quick close of task and creates a form to submit for quick close.
procedure get_mt_in_progress_quick_close as
	type mt_rec is record(
	TASKID           TASK_MAIN.TASKID%TYPE,
	WORK_TASK        TASK_MAIN.WORK_TASK%TYPE,
	WORK_TASK_DESC   TASK_MAIN.WORK_TASK_DESC%TYPE,
	COMMENTS         TASK_MAIN.COMMENTS%TYPE,
	TASK_TYPE        TASK_LIST.TASK_TYPE%TYPE,
	DESCRIPTION      TASK_LIST.DESCRIPTION%TYPE
	);
	TYPE type_table IS TABLE OF mt_rec INDEX BY BINARY_INTEGER;
	row_type_table type_table;
begin
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
	select tm.taskid, tm.work_task,tm.work_task_desc,tm.comments,tl.task_type,tl.description
	bulk collect into row_type_table 
	from TASK_MAIN TM, TASK_LIST TL where TM.status = 'InProgress' and TM.TASKID=TL.TASKID order by TM.work_task;
	
IF ( row_type_table.COUNT > 0) THEN
    dbms_output.put_line('<form action="/cgi-bin/quick_close_all_task.py" method="post" onsubmit="return validateForm()" target="_blank">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Task Name to Quick Close</label>');

	dbms_output.put_line('<select id="TASK_NAME" name="TASK_NAME" onchange="myFunction()" >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task||'>'||row_type_table(ii).work_task||'</option>');
	end loop;
	dbms_output.put_line('</select>');

	dbms_output.put_line('<select id="dTASK_DESCRIPTION" name="dTASK_DESCRIPTION" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_desc||'>'||row_type_table(ii).work_task_desc||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('<select id="TASK_DESCRIPTION" name="TASK_DESCRIPTION" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_desc||'>'||row_type_table(ii).work_task_desc||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('<div>');	
    
	dbms_output.put_line('<label class="ht1" >Task Type</label>');	

	dbms_output.put_line('<select id="dDESCRIPTION" name="dDESCRIPTION" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).DESCRIPTION||'>'||row_type_table(ii).DESCRIPTION||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
		
	dbms_output.put_line('</div>');	
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Close Date:</label>');
	dbms_output.put_line('<input type="date" id="theDate" name="theDate">');
	dbms_output.put_line('<input type="time" id="theTime" name="theTime"  min="00:00" max="23:59" required> ');

	dbms_output.put_line('</div>');

	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');

	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="submit" type="submit">');
	dbms_output.put_line('</p>');
	
	dbms_output.put_line('</div>');
	dbms_output.put_line('</form>');

	dbms_output.put_line('<script type = "text/JavaScript">');
	dbms_output.put_line('function myFunction() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	dbms_output.put_line('var z=y[x].index;');
	dbms_output.put_line('var oText=y[x].text;');
	--dbms_output.put_line('<!--alert(oText);-->');
	--dbms_output.put_line('<!--alert("Index: " + y[x].index + " is " + y[x].text);-->');
	--dbms_output.put_line('<!--alert("selectedIndex:"+z);-->');
	
	dbms_output.put_line('document.getElementById("dTASK_DESCRIPTION").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_DESCRIPTION").selectedIndex=z;');
	
	dbms_output.put_line('document.getElementById("dDESCRIPTION").selectedIndex=z;');
	
	dbms_output.put_line('}');

	dbms_output.put_line('function validateForm() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	
	dbms_output.put_line('var w=y[x].text;');
	
	
	dbms_output.put_line('if (w == "") {');
	dbms_output.put_line('	alert("Task must be selected");');
	dbms_output.put_line('	return false;');
	dbms_output.put_line('}');
	dbms_output.put_line('}');

	dbms_output.put_line('Date.prototype.dateToInput = function(){');
	dbms_output.put_line('	return this.getFullYear() + "-" + ("0" + (this.getMonth() + 1)).substr(-2,2) + "-" + ("0" + this.getDate()).substr(-2,2);');
	dbms_output.put_line('}');
	dbms_output.put_line('Date.prototype.timeToInput = function(){');
	dbms_output.put_line('	return  ("0" + (this.getHours())).substr(-2,2) + ":" + ("0" + this.getMinutes()).substr(-2,2);');
	dbms_output.put_line('}');

	dbms_output.put_line('var date = new Date();');
	dbms_output.put_line('document.getElementById("theDate").value = date.dateToInput();');
	dbms_output.put_line('document.getElementById("theTime").value = date.timeToInput();	');	
	
	dbms_output.put_line('</script>');

end if;
end get_mt_in_progress_quick_close;

-- This actually quick closes
procedure quick_close_all_tasks
(
p_work_task in task_main.work_task%type,
tp_close_date in varchar2
) as
p_close_date date;
begin
	
	p_close_date:=to_date(trim(tp_close_date),'YYYY-MM-DD HH24:MI:SS');

    --formulate the table. The html header/footer is in the cgi script.
	
	EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';

	dbms_output.put_line('<div>');
    dbms_output.put_line('<H1 >Task Details Before Closing '||p_work_task||'</H1>');
	dbms_output.put_line('</div>');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_DESC'||'</td><td>'||'START_DATE' ||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from task_main st WHERE st.work_task = p_work_task and status='InProgress')
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_DESC||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
	--------------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from TASK_SUBTASK WHERE work_task = p_work_task and status='InProgress' order by work_task,work_task_sub,start_date)
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_SUB||'</td><td>'||ii.ASSIGNED||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
    --------------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from TASK_SUBTASK_DAILY WHERE work_task = p_work_task and status='InProgress' order by work_task,work_task_sub,start_date)
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_SUB||'</td><td>'||ii.ASSIGNED||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
	
	update TASK_SUBTASK_DAILY set status = 'Completed', COMPLETE_DATE = p_close_date, TASK_CLOSE_DATE = p_close_date where work_task = p_work_task and status = 'InProgress';
	update TASK_SUBTASK       set status = 'Completed', COMPLETE_DATE = p_close_date, TASK_CLOSE_DATE = p_close_date where work_task = p_work_task and status = 'InProgress';
	update TASK_MAIN          set status = 'Completed', COMPLETE_DATE = p_close_date, TASK_CLOSE_DATE = p_close_date where work_task = p_work_task and status = 'InProgress';
	commit; 
	
	dbms_output.put_line('<div>');
    dbms_output.put_line('<H1 >Task Details AFTER Closing '||p_work_task||'</H1>');
	dbms_output.put_line('</div>');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_DESC'||'</td><td>'||'START_DATE' ||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from task_main st WHERE st.work_task = p_work_task)
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_DESC||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
	--------------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from TASK_SUBTASK WHERE work_task = p_work_task order by task_close_date desc,work_task_sub,assigned)
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_SUB||'</td><td>'||ii.ASSIGNED||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
    --------------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
    for ii in (select * from TASK_SUBTASK_DAILY WHERE work_task = p_work_task order by task_close_date desc,work_task_sub,assigned)
    loop
        dbms_output.put_line('<tr><td>'||ii.WORK_TASK||'</td><td>'||ii.WORK_TASK_SUB||'</td><td>'||ii.ASSIGNED||'</td><td>'||ii.START_DATE||'</td><td>'||ii.COMPLETE_DATE||'</td><td>'||ii.TASK_CLOSE_DATE||'</td><td>'||ii.STATUS||'</td><td>'||ii.COMMENTS||'</td></tr>');
    end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('</div>');
	
	
	
end quick_close_all_tasks;

--Get Task information daily open tasks and creates a form to submit for quick close.
procedure get_open_daily_task as
	TYPE type_table IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
	row_type_table type_table;
begin

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
	select * bulk collect into row_type_table from TASK_SUBTASK_DAILY where status = 'InProgress' order by work_task,work_task_sub;
IF ( row_type_table.COUNT > 0) THEN
    dbms_output.put_line('<form action="/cgi-bin/close_daily_task.py" method="post" onsubmit="return validateForm()" target="_blank">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Daily Task to Close</label>');

	dbms_output.put_line('<select id="TASK_NAME" name="TASK_NAME" onchange="myFunction()" >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task||'>'||row_type_table(ii).work_task||'</option>');
	end loop;
	dbms_output.put_line('</select>');
	---------------------------------------------
	dbms_output.put_line('<select id="dTASK_NAME_SUB" name="dTASK_NAME_SUB" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

	dbms_output.put_line('<select id="TASK_NAME_SUB" name="TASK_NAME_SUB" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
		
	dbms_output.put_line('<select id="COMMENTS" name="COMMENTS" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).comments||'>'||row_type_table(ii).comments||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	-----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Daily Task Assigned to: </label>');	
	dbms_output.put_line('<select id="dTASK_ASSIGNED" name="dTASK_ASSIGNED" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).assigned||'>'||row_type_table(ii).assigned||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

    dbms_output.put_line('<select id="TASK_ASSIGNED" name="TASK_ASSIGNED" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).assigned||'>'||row_type_table(ii).assigned||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('</div>');
	-----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Task Start Date: </label>');	

    dbms_output.put_line('<select id="TASK_START_DATE" name="TASK_START_DATE" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).START_DATE||'>'||row_type_table(ii).START_DATE||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('</div>');
	
    -----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Close Date:</label>');
	
	dbms_output.put_line('<input type="date" id="theDate" name="theDate">');
    dbms_output.put_line('<input type="time" id="theTime" name="theTime"  min="00:00" max="23:59" required> ');
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');

	
	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="submit" type="submit">');
	dbms_output.put_line('</p>');
	
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('</form>');

	dbms_output.put_line('<script type = "text/JavaScript">');
	dbms_output.put_line('function myFunction() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	dbms_output.put_line('var z=y[x].index;');
	dbms_output.put_line('var oText=y[x].text;');
	--dbms_output.put_line('<!--alert(oText);-->');
	--dbms_output.put_line('<!--alert("Index: " + y[x].index + " is " + y[x].text);-->');
	--dbms_output.put_line('<!--alert("selectedIndex:"+z);-->');
	
	dbms_output.put_line('document.getElementById("dTASK_NAME_SUB").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_NAME_SUB").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("dTASK_ASSIGNED").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_ASSIGNED").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_START_DATE").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("COMMENTS").selectedIndex=z;');
	
	dbms_output.put_line('}');

	dbms_output.put_line('function validateForm() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	
	dbms_output.put_line('var w=y[x].text;');
	
	
	dbms_output.put_line('if (w == "") {');
	dbms_output.put_line('	alert("Task must be selected");');
	dbms_output.put_line('	return false;');
	dbms_output.put_line('}');
	dbms_output.put_line('}');

	dbms_output.put_line('Date.prototype.dateToInput = function(){');
	dbms_output.put_line('	return this.getFullYear() + "-" + ("0" + (this.getMonth() + 1)).substr(-2,2) + "-" + ("0" + this.getDate()).substr(-2,2);');
	dbms_output.put_line('}');
	dbms_output.put_line('Date.prototype.timeToInput = function(){');
	dbms_output.put_line('	return  ("0" + (this.getHours())).substr(-2,2) + ":" + ("0" + this.getMinutes()).substr(-2,2);');
	dbms_output.put_line('}');

	dbms_output.put_line('var date = new Date();');
	dbms_output.put_line('document.getElementById("theDate").value = date.dateToInput();');
	dbms_output.put_line('document.getElementById("theTime").value = date.timeToInput();	');
	
	
	
	dbms_output.put_line('</script>');
ELSE
    dbms_output.put_line('<div>');  
	dbms_output.put_line('<p>No Open Daily Tasks</p>');
	dbms_output.put_line('</div>');  
	
end if;
end get_open_daily_task;

procedure close_daily_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_close_date in varchar2
)
as
  TYPE type_table IS TABLE OF TASK_SUBTASK_DAILY%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table type_table;
  daily_task_already_closed exception;
  err_code number;
  err_msg varchar2(500);
begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  
  select * bulk collect into row_type_table from TASK_SUBTASK_DAILY where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status = 'InProgress' order by work_task,work_task_sub;
  IF ( row_type_table.COUNT > 0) THEN
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<tr><td>'||row_type_table(ii).WORK_TASK||'</td><td>'||row_type_table(ii).WORK_TASK_SUB||'</td><td>'||row_type_table(ii).ASSIGNED||'</td><td>'||row_type_table(ii).START_DATE||'</td><td>'||row_type_table(ii).COMPLETE_DATE||'</td><td>'||row_type_table(ii).TASK_CLOSE_DATE||'</td><td>'||row_type_table(ii).STATUS||'</td><td>'||row_type_table(ii).COMMENTS||'</td></tr>');
	end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('<div>');
  manage_efforts.close_daily_task(p_work_task,p_work_task_sub,p_assigned,p_close_date);	
  ELSE
  dbms_output.put_line('<div>');
  dbms_output.put_line('<p class=ht1> Daily Task Not Closed. It might be already closed. Check State of requested daily Task: '||'</p>');

  dbms_output.put_line('<p class=ht1> WORK_TASK:'||p_work_task||'</p>');
  dbms_output.put_line('<p class=ht1> WORK_TASK_SUB'||p_work_task_sub||'</p>');
  dbms_output.put_line('<p class=ht1> ASSIGNED:'||p_assigned||'</p>');

  dbms_output.put_line('</div>');
  END IF;
  
exception
  when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end close_daily_task;
----------------------
procedure get_open_sub_task as
	TYPE type_table IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
	row_type_table type_table;
begin

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
	select * bulk collect into row_type_table from TASK_SUBTASK where status = 'InProgress' order by work_task,work_task_sub;
IF ( row_type_table.COUNT > 0) THEN
    dbms_output.put_line('<form action="/cgi-bin/close_sub_task.py" method="post" onsubmit="return validateForm()" target="_blank">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Choose SUB Task Name to  Close</label>');

	dbms_output.put_line('<select id="TASK_NAME" name="TASK_NAME" onchange="myFunction()" >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task||'>'||row_type_table(ii).work_task||'</option>');
	end loop;
	dbms_output.put_line('</select>');
	
	dbms_output.put_line('<select id="dTASK_NAME_SUB" name="dTASK_NAME_SUB" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

	dbms_output.put_line('<select id="TASK_NAME_SUB" name="TASK_NAME_SUB" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	
	dbms_output.put_line('<select id="dWORK_TASK_DESC" name="dWORK_TASK_DESC" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

	dbms_output.put_line('<select id="WORK_TASK_DESC" name="WORK_TASK_DESC" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task_sub||'>'||row_type_table(ii).work_task_sub||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('<select id="COMMENTS" name="COMMENTS" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).comments||'>'||row_type_table(ii).comments||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	-----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Daily Task Assigned to: </label>');	
	dbms_output.put_line('<select id="dTASK_ASSIGNED" name="dTASK_ASSIGNED" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).assigned||'>'||row_type_table(ii).assigned||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

    dbms_output.put_line('<select id="TASK_ASSIGNED" name="TASK_ASSIGNED" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).assigned||'>'||row_type_table(ii).assigned||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('</div>');
    -----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Close Date:</label>');
	dbms_output.put_line('<input type="date" id="theDate" name="theDate">');
    dbms_output.put_line('<input type="time" id="theTime" name="theTime"  min="00:00" max="23:59" required> ');
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');

	
	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="submit" type="submit">');
	dbms_output.put_line('</p>');
	
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('</form>');

	dbms_output.put_line('<script type = "text/JavaScript">');
	dbms_output.put_line('function myFunction() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	dbms_output.put_line('var z=y[x].index;');
	dbms_output.put_line('var oText=y[x].text;');
	--dbms_output.put_line('<!--alert(oText);-->');
	--dbms_output.put_line('<!--alert("Index: " + y[x].index + " is " + y[x].text);-->');
	--dbms_output.put_line('<!--alert("selectedIndex:"+z);-->');
	
	dbms_output.put_line('document.getElementById("dWORK_TASK_DESC").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("WORK_TASK_DESC").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("dTASK_ASSIGNED").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_ASSIGNED").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("dTASK_NAME_SUB").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("TASK_NAME_SUB").selectedIndex=z;');	
	dbms_output.put_line('document.getElementById("COMMENTS").selectedIndex=z;');
	
	dbms_output.put_line('}');

	dbms_output.put_line('function validateForm() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	
	dbms_output.put_line('var w=y[x].text;');
	
	
	dbms_output.put_line('if (w == "") {');
	dbms_output.put_line('	alert("Task must be selected");');
	dbms_output.put_line('	return false;');
	dbms_output.put_line('}');
	dbms_output.put_line('}');
	
	dbms_output.put_line('Date.prototype.dateToInput = function(){');
	dbms_output.put_line('	return this.getFullYear() + "-" + ("0" + (this.getMonth() + 1)).substr(-2,2) + "-" + ("0" + this.getDate()).substr(-2,2);');
	dbms_output.put_line('}');
	dbms_output.put_line('Date.prototype.timeToInput = function(){');
	dbms_output.put_line('	return  ("0" + (this.getHours())).substr(-2,2) + ":" + ("0" + this.getMinutes()).substr(-2,2);');
	dbms_output.put_line('}');

	dbms_output.put_line('var date = new Date();');
	dbms_output.put_line('document.getElementById("theDate").value = date.dateToInput();');
	dbms_output.put_line('document.getElementById("theTime").value = date.timeToInput();	');
		
	
	dbms_output.put_line('</script>');
ELSE
    dbms_output.put_line('<div>');  
	dbms_output.put_line('<p>No Open SUB Tasks</p>');
	dbms_output.put_line('</div>');  
	
end if;
end get_open_sub_task;

----------------------

procedure close_sub_task
(
p_work_task in task_subtask_daily.work_task%type,
p_work_task_sub in task_subtask_daily.work_task_sub%type,
p_assigned in task_subtask_daily.assigned%type,
p_close_date in varchar2
)
as
  TYPE type_table IS TABLE OF TASK_SUBTASK%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table type_table;
  daily_task_already_closed exception;
  err_code number;
  err_msg varchar2(500);
begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  
  select * bulk collect into row_type_table from TASK_SUBTASK where work_task = p_work_task and work_task_sub = p_work_task_sub and assigned = p_assigned and status = 'InProgress' order by work_task,work_task_sub;
  IF ( row_type_table.COUNT > 0) THEN
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'WORK_TASK_SUB'||'</td><td>'||'ASSIGNED'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<tr><td>'||row_type_table(ii).WORK_TASK||'</td><td>'||row_type_table(ii).WORK_TASK_SUB||'</td><td>'||row_type_table(ii).ASSIGNED||'</td><td>'||row_type_table(ii).START_DATE||'</td><td>'||row_type_table(ii).COMPLETE_DATE||'</td><td>'||row_type_table(ii).TASK_CLOSE_DATE||'</td><td>'||row_type_table(ii).STATUS||'</td><td>'||row_type_table(ii).COMMENTS||'</td></tr>');
	end loop;
	dbms_output.put_line('</table>');
	dbms_output.put_line('<div>');
	manage_efforts.close_sub_task(p_work_task,p_work_task_sub,p_assigned,p_close_date);
  ELSE
  dbms_output.put_line('<div>');
  dbms_output.put_line('SUB Task :'||p_work_task||'.'||p_work_task_sub||' Not Closed. It might be already closed. Check State. ');
  dbms_output.put_line('</div>');
  END IF;
  
exception
  when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end close_sub_task;
----------------------

procedure get_open_main_task as
	TYPE type_table IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
	row_type_table type_table;
begin

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
	select * bulk collect into row_type_table from TASK_MAIN where status = 'InProgress' order by work_task;
IF ( row_type_table.COUNT > 0) THEN
    dbms_output.put_line('<form action="/cgi-bin/close_main_task.py" method="post" onsubmit="return validateForm()" target="_blank">');
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1" >Choose MAIN Task Name to  Close</label>');

	dbms_output.put_line('<select id="TASK_NAME" name="TASK_NAME" onchange="myFunction()" >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).work_task||'>'||row_type_table(ii).work_task||'</option>');
	end loop;
	dbms_output.put_line('</select>');
	
	dbms_output.put_line('<select id="dWORK_TASK_DESC" name="dWORK_TASK_DESC" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).WORK_TASK_DESC||'>'||row_type_table(ii).WORK_TASK_DESC||'</option>');
	end loop;
	dbms_output.put_line('</select>');	

	dbms_output.put_line('<select id="WORK_TASK_DESC" name="WORK_TASK_DESC" hidden >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).WORK_TASK_DESC||'>'||row_type_table(ii).WORK_TASK_DESC||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
	dbms_output.put_line('<select id="COMMENTS" name="COMMENTS" disabled >');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<option value='||row_type_table(ii).comments||'>'||row_type_table(ii).comments||'</option>');
	end loop;
	dbms_output.put_line('</select>');	
	
    -----------------------------------------
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Enter Close Date:</label>');
	dbms_output.put_line('<input type="date" id="theDate" name="theDate">');
    dbms_output.put_line('<input type="time" id="theTime" name="theTime"  min="00:00" max="23:59" required> ');
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('<div>');
	dbms_output.put_line('<label class="ht1">Password:</label>');
	dbms_output.put_line('<input type="password" name="PASSWD" id="PASSWD">');
	dbms_output.put_line('</div>  ');

	
	dbms_output.put_line('<p >');
	dbms_output.put_line('<input name="submit" type="submit">');
	dbms_output.put_line('</p>');
	
	dbms_output.put_line('</div>');
	
	dbms_output.put_line('</form>');

	dbms_output.put_line('<script type = "text/JavaScript">');
	dbms_output.put_line('function myFunction() {');
	dbms_output.put_line('var x = document.getElementById("TASK_NAME").selectedIndex;');
	dbms_output.put_line('var y = document.getElementById("TASK_NAME").options;');
	
	dbms_output.put_line('var z=y[x].index;');
	dbms_output.put_line('var oText=y[x].text;');
	--dbms_output.put_line('<!--alert(oText);-->');
	--dbms_output.put_line('<!--alert("Index: " + y[x].index + " is " + y[x].text);-->');
	--dbms_output.put_line('<!--alert("selectedIndex:"+z);-->');
	
	dbms_output.put_line('document.getElementById("dWORK_TASK_DESC").selectedIndex=z;');
	dbms_output.put_line('document.getElementById("WORK_TASK_DESC").selectedIndex=z;');
	
	dbms_output.put_line('document.getElementById("COMMENTS").selectedIndex=z;');
	
	dbms_output.put_line('}');

	dbms_output.put_line('Date.prototype.dateToInput = function(){');
	dbms_output.put_line('	return this.getFullYear() + "-" + ("0" + (this.getMonth() + 1)).substr(-2,2) + "-" + ("0" + this.getDate()).substr(-2,2);');
	dbms_output.put_line('}');
	dbms_output.put_line('Date.prototype.timeToInput = function(){');
	dbms_output.put_line('	return  ("0" + (this.getHours())).substr(-2,2) + ":" + ("0" + this.getMinutes()).substr(-2,2);');
	dbms_output.put_line('}');

	dbms_output.put_line('var date = new Date();');
	dbms_output.put_line('document.getElementById("theDate").value = date.dateToInput();');
	dbms_output.put_line('document.getElementById("theTime").value = date.timeToInput();	');


	dbms_output.put_line('</script>');
ELSE
    dbms_output.put_line('<div>');  
	dbms_output.put_line('<p>No Open MAIN Tasks</p>');
	dbms_output.put_line('</div>');  
	
end if;
end get_open_main_task;

procedure close_main_task
(
p_work_task in task_subtask_daily.work_task%type,
p_close_date in varchar2
)
as
  TYPE type_table IS TABLE OF TASK_MAIN%ROWTYPE INDEX BY BINARY_INTEGER;
  row_type_table type_table;
  
  err_code number;
  err_msg varchar2(500);
begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS''';
  
  select * bulk collect into row_type_table from TASK_MAIN where work_task = p_work_task and status = 'InProgress' order by work_task;
  IF ( row_type_table.COUNT > 0) THEN
	dbms_output.put_line('<div>');
	dbms_output.put_line('<table>');
	dbms_output.put_line('<tr><td>'||'WORK_TASK'||'</td><td>'||'START_DATE'||'</td><td>'||'COMPLETE_DATE'||'</td><td>'||'TASK_CLOSE_DATE'||'</td><td>'||'STATUS'||'</td><td>'||'COMMENTS'||'</td></tr>');
	for ii in 1 .. row_type_table.COUNT
	loop
		dbms_output.put_line('<tr><td>'||row_type_table(ii).WORK_TASK||'</td><td>'||row_type_table(ii).START_DATE||'</td><td>'||row_type_table(ii).COMPLETE_DATE||'</td><td>'||row_type_table(ii).TASK_CLOSE_DATE||'</td><td>'||row_type_table(ii).STATUS||'</td><td>'||row_type_table(ii).COMMENTS||'</td></tr>');
	end loop;
	dbms_output.put_line('</table>');
	--dbms_output.put_line('About to close main task'||p_work_task);
	dbms_output.put_line('<div>');
	manage_efforts.close_main_task(p_work_task,p_close_date);
  ELSE
  dbms_output.put_line('<div>');
  dbms_output.put_line('MAIN Task :'||p_work_task||' Not Closed. It might be already closed. Check State. ');
  dbms_output.put_line('</div>');
  END IF;
  
exception
  when others then
  err_code := SQLCODE;
  err_msg := SUBSTR(SQLERRM, 1, 200);
  dbms_output.put_line('Exeception Raised. Err_Code: '||err_code||'. Err_msg:'||err_msg);
end close_main_task;


END pkg_cgi_effort;
/
