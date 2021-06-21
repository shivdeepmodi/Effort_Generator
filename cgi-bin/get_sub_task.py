#!C:\Program Files\Python39\python.exe
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

fTASK_NAME    = form.getvalue('TASK_NAME')

cx_Oracle.init_oracle_client(lib_dir=r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\instantclient_19_9")

import tasks
import mydb
import css

print ("Content-type:text/html\r\n\r\n")
print ("<html>")
print ("<head>")
print ("<title>Create SUBTask</title>")
print ("</head>")

# get css after head
css.get_css()
print ("<body >")
print ("<div>")

#### Generator table from pl/sql. form action is in the package.
try:
	with cx_Oracle.connect(
				mydb.username,
				mydb.password,
				mydb.dsn,
				encoding=mydb.encoding) as connection:
		with connection.cursor() as cursor:
			cursor.callproc('dbms_output.enable', (None,))
			cursor.callproc('pkg_cgi_effort.capture_sub_or_dly_tsk_dtls',[fTASK_NAME])
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

####


print("</div>")


print ("</body>")
print ("</html>")