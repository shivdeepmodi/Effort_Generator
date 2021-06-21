#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe

# Import modules for CGI handling 
import os
import sys
import cgi
import cgitb;
cgitb.enable(display=1, logdir="C:/tmp")
import cx_Oracle
#import db_config	

#Add the user define python modules here. 'r' produces a raw string.
#sys.path.append(r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\Study\Python_study\Python_LIBPATH")
cx_Oracle.init_oracle_client(lib_dir=r'C:/Users/shivdeep.modi/OneDrive - IHS Markit/Shivdeep/instantclient_19_9')
sys.path.append('C:\\Users\\shivdeep.modi\\OneDrive - IHS Markit\\Shivdeep\\Study\\Python_study\\Python_LIBPATH')
import mydb

os.environ['QUERY_STRING'] = 'TASK_ID=1&TASK_NAME=TEST_TASK00&TASK_DESC=TEST_TASK003 Description&TASK_DATE=30-JAN-2021 07:21:00&TEST_TASK003&TASK_COMMENT=TEST_TASK00'

sqlm = "select tl.description,tm.work_task, tm.work_task_desc, tm.start_date,tm.status,tm.comments from TASK_MAIN tm ,TASK_LIST tl where  rownum=1"
form = cgi.FieldStorage() 
# Get data from fields
#TASK_ID      = form.getvalue('TASK_ID')
#fTASK_NAME    = form.getvalue('TASK_NAME')
#fTASK_DESC    = form.getvalue('TASK_DESC')
#fTASK_DATE    = form.getvalue('TASK_DATE')
#fTASK_COMMENT = form.getvalue('TASK_COMMENT')

#mydb.test_function()
print ("Content-type:text/html\r\n\r\n"						)
print()
print ("<html>"                                             )
print ("<head>"                                             )
print ("<title>Create </title>"        )
print ("</head>"    )
print ("<body>"     )
print ("<table>"    )

#try:
#	with cx_Oracle.connect(
#				mydb.username,
#				mydb.password,
#				mydb.dsn,
#				encoding=mydb.encoding) as connection:
#		with connection.cursor() as cursor:
#			#Get Inserted data
#			cursor.execute(sqlm)
#			rows = cursor.fetchall()
#			if rows:
#				for row in rows:
#					#print(row)
#					print ("<tr><td>TASK TYPE     : </td><td> {} </td></tr>".format(row[0],10) );
#					print ("<tr><td>TASK_NAME   : </td><td> {} </td></tr>".format(row[1],50) );
#					print ("<tr><td>TASK DESCRIPTION : </td><td> {} </td></tr>".format(row[2],100) );
#					print ("<tr><td>START_DATE  : </td><td> {} </td></tr>".format(row[3],20) );
#					print ("<tr><td>COMMENTS    : </td><td> {} </td></tr>".format(row[4],500) );
#
##select tl.description,tm.work_task, tm.work_task_desc, tm.start_date,tm.status,tm.comments from TASK_MAIN tm ,TASK_LIST tl where   tm.task_id = tl.task_id and tm.task_name = :v_TASK_NAME
#		
#except cx_Oracle.Error as error:
#	print(error)
	
print ("</table>"   )
print ("</body>"    )
print ("</html>"    )