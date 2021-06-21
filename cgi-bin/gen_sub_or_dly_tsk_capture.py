#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe
######
##!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
# Import modules for CGI handling 
import os
import sys
import cgi
import cgitb
import cx_Oracle

#cgitb.enable(display=0, logdir=None, context=5, format="html")
cgitb.enable(display=1, logdir="C:/tmp")
#import db_config	

#Add the user define python modules here. 'r' produces a raw string.
sys.path.append('C:\\Users\\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\\Study\\Python_study\\Python_LIBPATH')

# This is to debug
#os.environ['QUERY_STRING']  = 'TASK_TYPE=SUBTASK'

#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 
fTASK_TYPE   = form.getvalue('TASK_TYPE')

cx_Oracle.init_oracle_client(lib_dir='C:/Users/shivdeep.modi/OneDrive - IHS Markit/Shivdeep/instantclient_19_9')

import tasks
import mydb
#import css

print ("Content-type:text/html\r\n\r\n"						)
print()
print ("<html>"                                             )
print ("<head>"                                             )
print ("<title>Create "+str(fTASK_TYPE)+"</title>"        )
print ("</head>"                                            )

#css.get_css()

print("<STYLE type='text/css'>")

#css.get_css()
with open(r'C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\Projects\Work\SME\html\styles.css', 'r') as f:
	print(f.read())
print("</STYLE>")

print ("<body background='/images/7002182-free-nature-backgrounds-for-mac.jpg'>")
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
			cursor.callproc('pkg_cgi_effort.gen_sub_or_dly_tsk_capture',[fTASK_TYPE])
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

####


print("</div>")


print ("</body>")
print ("</html>")