#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe
#!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe

# Import modules for CGI handling 
import os
import sys
import cgi
import cgitb; cgitb.enable()
import cx_Oracle

#import db_config	

#Add the user define python modules here. 'r' produces a raw string.
sys.path.append(r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\Study\Python_study\Python_LIBPATH")

# This is to debug
#os.environ['QUERY_STRING'] = 'TASK_NAME=TEST_TASK001&TASK_NAME_SUB=TEST_TASK001.SUB&TASK_ASSIGNED=Shivdeep&CLOSE_DATE=sysdate&PASSWD=quake2&submit=Submit';
#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
fTASK_NAME    = form.getvalue('TASK_NAME')
fCLOSE_DATE   = form.getvalue('CLOSE_DATE')
fPASSWD       = form.getvalue('PASSWD')
fTASK_ASSIGNED= form.getvalue('TASK_ASSIGNED')
fTASK_NAME_SUB= form.getvalue('TASK_NAME_SUB')
ftheDate    = form.getvalue('theDate')
ftheTime    = form.getvalue('theTime')

fCLOSE_DATE   =str(ftheDate)+" "+str(ftheTime)+":00"


#print ('fTASK_NAME     '+fTASK_NAME    );
#print ('fCLOSE_DATE    '+fCLOSE_DATE   );
#print ('fPASSWD        '+fPASSWD       );
#print ('fTASK_ASSIGNED '+fTASK_ASSIGNED);
#print ('fTASK_NAME_SUB '+str(fTASK_NAME_SUB));


#sqldly = "select td.work_task, td.work_task_sub,td.assigned, td.start_date,td.status,td.comments from TASK_MAIN tm ,TASK_SUBTASK_DAILY td where tm.work_task = td.work_task and tm.work_task = :v_TASK_NAME and td.work_task_sub = :v_TASK_NAME_SUB and td.assigned = :v_TASK_ASSIGNED and td.complete_date = :v_CLOSE_DATE"
sqldly = "select td.work_task, td.work_task_sub,td.assigned, td.start_date,td.complete_date,td.task_close_date,td.status,td.comments from TASK_MAIN tm ,TASK_SUBTASK_DAILY td where tm.work_task = td.work_task and tm.work_task = :v_TASK_NAME and td.work_task_sub = :v_TASK_NAME_SUB and td.assigned = :v_TASK_ASSIGNED order by td.complete_date desc"

cx_Oracle.init_oracle_client(lib_dir=r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\instantclient_19_9")

import tasks
import mydb
import css


print ("Content-type:text/html\r\n\r\n")
print ("<html>")
print ("<head>")
print ("<title>Close Daily Task2</title>")
print ("</head>")

# get css after head
css.get_css()

print ("<body >")
#### Generator table from pl/sql. form action is in the package.
if fPASSWD == 'quake2':
	try:
		with cx_Oracle.connect(
					mydb.username,
					mydb.password,
					mydb.dsn,
					encoding=mydb.encoding) as connection:
			with connection.cursor() as cursor:
				cursor.callproc('dbms_output.enable', (None,))
				cursor.callproc('pkg_cgi_effort.close_daily_task',[fTASK_NAME,fTASK_NAME_SUB,fTASK_ASSIGNED,fCLOSE_DATE])
				chararr = connection.gettype('SYS.DBMS_OUTPUT.CHARARR')
				lines = chararr.newobject()
				
				chunk_size = 1000
				numlines = cursor.var(int)
				numlines.setvalue(0, chunk_size)
				
				while numlines.getvalue() == chunk_size:
					cursor.callproc('dbms_output.get_lines', (lines, numlines))
					for line in lines.aslist():
						if line:
							print(line)	
	except cx_Oracle.Error as error:
		print(error)	

	#try to print the closed task begin
	print("<div>")
	print("<p class=ht1>Daily Task closed Details(If any)</p>");
	print("<table>")

	print ("<tr>"
		+"<td> {} </td>".format('TASK NAME',50) 
		+"<td> {} </td>".format('TASK NAME_SUB',50) 
		+"<td> {} </td>".format('ASSIGNED',100) 
		+"<td> {} </td>".format('START_DATE',20)
		+"<td> {} </td>".format('COMPLETE_DATE',20) 
		+"<td> {} </td>".format('TASK_CLOSE_DATE',20) 
		+"<td> {} </td>".format('TASK STATUS',20)
		+"<td> {} </td>".format('COMMENTS',500)
		+"</tr>"
	);
	
	
	try:
		with cx_Oracle.connect(
					mydb.username,
					mydb.password,
					mydb.dsn,
					encoding=mydb.encoding) as connection:
			with connection.cursor() as cursor:
				#Get Inserted data
				cursor.execute(sqldly, [fTASK_NAME,fTASK_NAME_SUB,fTASK_ASSIGNED])
				rows = cursor.fetchall()
				if rows:
					for row in rows:
						#print(row)
						print ("<tr>"
							+"<td> {} </td>".format(row[0],50) 
							+"<td> {} </td>".format(row[1],50) 
							+"<td> {} </td>".format(row[2],100)
							+"<td> {} </td>".format(row[3],25)
							+"<td> {} </td>".format(row[4],25) 								
							+"<td> {} </td>".format(row[5],25) 
							+"<td> {} </td>".format(row[6],25)
							+"<td> {} </td>".format(row[7],500)
							+"</tr>"
						);
	
		
	except cx_Oracle.Error as error:
		print(error)	
	
	print("</table>")
	print("</div>")
	print ("</body>")
	print ("</html>")	

else:
	print ("<html>"                                             )
	print ("<head>"                                             )
	print ("<title>Close Daily Task</title>"                         )
	print ("</head>"                                            )
	print ("<STYLE type='text/css'>"                            )  
	print ("BODY {background: #AEF7DC;margin: 10px;}  "         )
	print ("</STYLE>"                                            )
	print ("<body >"                                            )
	print ("<p> Invalid Password </p>")
	print ("</body>")
	print ("</html>")