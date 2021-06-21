#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe
###!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
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
#os.environ['QUERY_STRING'] = 'TASK_NAME=TEST_TASK003&TASK_NAME_SUB=TEST_TASK003.SUB&ADD_DAILYTASK=NO&TASK_COMMENT=TEST_TASK003+Comments&TASK_DATE=sysdate&TASK_ASSIGNED=DEFAULT&TASK_TYPE=SUBTASK&PASSWD=quake2&submit=Submit'
#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 
fTASK_TYPE   = form.getvalue('TASK_TYPE')
fTASK_NAME    = form.getvalue('TASK_NAME')
fPASSWD       = form.getvalue('PASSWD')
#fTASK_ASSIGNED= form.getvalue('TASK_ASSIGNED')
#fTASK_NAME_SUB= form.getvalue('TASK_NAME_SUB')
#fADD_DAILYTASK= form.getvalue('ADD_DAILYTASK')

cx_Oracle.init_oracle_client(lib_dir=r"C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\instantclient_19_9")

import tasks
import mydb
import css

print ("Content-type:text/html\r\n\r\n"                     )
print ("<html>"                                             )
print ("<head>"                                             )
print ("<title>Create "+str(fTASK_TYPE)+"</title>"        )
print ("</head>"                                            )

css.get_css()

print ("<body >")
print ("<p class=ht1>Create "+str(fTASK_TYPE)+"</p>")
print ("<div>")

if fPASSWD == 'quake2':
#### Generator table from pl/sql. form action is in the package.
	try:
		with cx_Oracle.connect(
					mydb.username,
					mydb.password,
					mydb.dsn,
					encoding=mydb.encoding) as connection:
			with connection.cursor() as cursor:
				cursor.callproc('dbms_output.enable', (None,))
				cursor.callproc('pkg_cgi_effort.capture_sub_or_dly_tsk_dtls',[fTASK_TYPE,fTASK_NAME])
				chararr = connection.gettype('SYS.DBMS_OUTPUT.CHARARR')
				lines = chararr.newobject()
				
				chunk_size = 100
				numlines = cursor.var(int)
				numlines.setvalue(0, chunk_size)
				
				while numlines.getvalue() == chunk_size:
					cursor.callproc('dbms_output.get_lines', (lines, numlines))
					for line in lines.aslist():
						if line:
							print(line)	
	except cx_Oracle.Error as error:
		print(error)	
	print("</div>")
	print ("</body>")
	print ("</html>")
else:
	print ("<html>"                                             )
	print ("<head>"                                             )
	print ("<title>CREATE SUB TASK</title>"                     )
	print ("</head>"                                            )
	print ("<body >"                                            )
	print("<div>")
	print ("<p> Invalid Password </p>"							)
	print("</div>")
	print ("</body >"                                           )
	print ("</html>"                                            )	