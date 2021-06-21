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
#os.environ['QUERY_STRING']  = 'TASK_ID=9&TASK_NAME=TEST_TASK004&TASK_DESC=TEST_TASK004&TASK_COMMENT=TEST_TASK004&TASK_DATE=30-Jan-2021+09%3A51%3A00&ADD_SUBTASK=YES&TASK_ASSIGNED=NetOPs&PASSWD=quake2&submit=Submit'
#os.environ['QUERY_STRING'] = 'TASK_ID=1&TASK_NAME=TEST_TASK003&TASK_DESC=TEST_TASK003 Description&TASK_DATE=sysdate&TEST_TASK003&TASK_COMMENT=TEST_TASK00&PASSWD=acb123'
#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
fTASK_NAME    = form.getvalue('TASK_NAME')
ftheDate    = form.getvalue('theDate')
ftheTime    = form.getvalue('theTime')

fCLOSE_DATE   =str(ftheDate)+" "+str(ftheTime)+":00"
fPASSWD       = form.getvalue('PASSWD')
fTASK_ASSIGNED= form.getvalue('TASK_ASSIGNED')
fTASK_NAME_SUB= form.getvalue('TASK_NAME_SUB')


#sqldly = "select td.work_task, td.work_task_sub,td.assigned, td.start_date,td.status,td.comments from TASK_MAIN tm ,TASK_SUBTASK_DAILY td where tm.work_task = td.work_task and tm.work_task = :v_TASK_NAME and td.work_task_sub = :v_TASK_NAME_SUB and td.assigned = :v_TASK_ASSIGNED and td.complete_date = :v_CLOSE_DATE"
sqldly = "select ts.work_task, ts.work_task_sub,ts.assigned, ts.start_date,ts.complete_date,ts.TASK_CLOSE_DATE,ts.status,ts.comments from TASK_MAIN tm ,TASK_SUBTASK ts where tm.work_task = ts.work_task and ts.work_task = :v_TASK_NAME and ts.work_task_sub = :v_TASK_NAME_SUB and ts.assigned = :v_TASK_ASSIGNED order by ts.complete_date desc"

cx_Oracle.init_oracle_client(lib_dir=r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\instantclient_19_9")

import tasks
import mydb

print ("Content-type:text/html\r\n\r\n")
print ("<html>")
print ("<head>")
print ("<title>Close SUBTASK2</title>")
print ("</head>")

print ("<STYLE type='text/css'>")
print ("BODY {background: #c0dceb;margin: 10px;}")
print ("table { ")
print ("font-family: arial, sans-serif;")
print ("border-collapse: collapse;")
print ("width: 75%;")
print ("}           " )
print ("            " )
print ("td, th {    " )
print ("border: 1px solid black;       " )
print ("text-align: left;              " )
print ("padding: 8px;                  " )
print ("}                              " )
print ("                               " )
print ("tr:nth-child(even) {           " )
print ("background-color: #dddddd;     " )
print ("}		                       " )
                  
print("td.bold1 {        ")
print("font-weight:bold  ")
print("}                 ")

print("p.ht1 {                ")
print(" line-height: 1.8;     ")
print(" padding-right: 50px;  ")
print("}                      ")
				  
print("div {							")
print("background-color: lightblue;     ")
print("padding-top: 10px;               ")
print("padding-right: 30px;             ")
print("padding-bottom: 10px;            ")
print("}		                        ")

print("label.ht1 {				")
print(" line-height: 1.8;       ")
print(" display: inline-block;  ")
print(" width: 200px;           ")
print("}                        ")

print("</STYLE>")
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
				cursor.callproc('pkg_cgi_effort.close_sub_task',[fTASK_NAME,fTASK_NAME_SUB,fTASK_ASSIGNED,fCLOSE_DATE])
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
	print("<table>")

	print ("<tr>"
		+"<td class=bold1 colspan=8> {} </td>".format('SUB TASK CLOSED DETAILS') 
		+ "</tr>"
		+"<tr>"
		+"<td> {} </td>".format('TASK NAME',50) 
		+"<td> {} </td>".format('TASK NAME_SUB',50) 
		+"<td> {} </td>".format('ASSIGNED',100) 
		+"<td> {} </td>".format('START_DATE',50)
		+"<td> {} </td>".format('CLOSED_DATE',50) 
		+"<td> {} </td>".format('TASK_CLOSE_DATE',40) 
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
							+"<td> {} </td>".format(row[3],50)
							+"<td> {} </td>".format(row[4],50) 								
							+"<td> {} </td>".format(row[5],40) 
							+"<td> {} </td>".format(row[6],20) 
							+"<td> {} </td>".format(row[7],500)
							+"</tr>"
						);
	
		
	except cx_Oracle.Error as error:
		print(error)	
	
	print("</table>")
	print("</div>")
	
	#try to print the closed task end

		
########	
else:

		print ("<html>"                                             )
		print ("<head>"                                             )
		print ("<title>Close SUBTASK2</title>"                         )
		print ("</head>"                                            )
		print ("<STYLE type='text/css'>"                            )  
		print ("BODY {background: #AEF7DC;margin: 10px;}  "         )
		print ("</STYLE>"                                            )
		print ("<body >"                                            )
		print ("<p> Invalid Password </p>")

print ("</body>")
print ("</html>")