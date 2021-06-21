#!"C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe"

import os
import sys
import cgi
import cgitb; 
cgitb.enable(display=1, logdir="C:/tmp")
import cx_Oracle

sys.path.append('C:\\Users\\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\\Study\\Python_study\\Python_LIBPATH')



#os.environ['QUERY_STRING'] = 'theDate=2021-03-08&theTime=08:4&TASK_DATE=2021-03-08 08:24:00'
#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

cx_Oracle.init_oracle_client(lib_dir='C:/Users/shivdeep.modi/OneDrive - IHS Markit/Shivdeep/instantclient_19_9')

# Get data from fields
ftheDate    = form.getvalue('theDate')
ftheTime    = form.getvalue('theTime')

taskDate    =str(ftheDate)+" "+str(ftheTime)+":00"

#import mydb
import tasks
import mydb
import css




print ("Content-type:text/html\r\n\r\n")
print ("<html>")
print ("<head>")
print ("<title>TEST2</title>")
print ("</head>")

css.get_css()

print ("<body >"                                            )

print ("<p>Date got  :{}".format(ftheDate)+"</p>")
print ("<p>Time got  :{}".format(ftheTime)+"</p>")
print ("<p>Task Date :{}".format(taskDate)+"</p>")



try:
	with cx_Oracle.connect(
				mydb.username,
				mydb.password,
				mydb.dsn,
				encoding=mydb.encoding) as connection:
		with connection.cursor() as cursor:
			sqlm   = "insert into test_Date values(to_date(:v_taskDate,'YYYY-MM-DD HH24:MI:SS'))"
			cursor.execute(sqlm, [taskDate])
			connection.commit()
##			rows = cursor.fetchall()
##			if rows:
##				for row in rows:
##					#print(row)
##					print ("<tr>"
##						+"<td> {} </td>".format(row[0],10) 
##						+"<td> {} </td>".format(row[1],50) 
##						+"<td> {} </td>".format(row[2],100)
##						+"<td> {} </td>".format(row[3],20) 								
##						+"<td> {} </td>".format(row[4],20) 
##						+"<td> {} </td>".format(row[5],500)
##						+"</tr>"
##					);

	
except cx_Oracle.Error as error:
	print(error)

print ("</body>"                                        )
print ("</html>"                                        )
