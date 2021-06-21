#!"C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe"
#####!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
# Import modules for CGI handling 
import os
import sys
import cgi
import cgitb; 
cgitb.enable(display=1, logdir="C:/tmp")
import cx_Oracle

#import db_config	

#Add the user define python modules here. 'r' produces a raw string.
sys.path.append('C:\\Users\\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\\Study\\Python_study\\Python_LIBPATH')

# This is to debug
#os.environ['QUERY_STRING']  = 'TASK_ID=9&TASK_NAME=TEST_TASK002&TASK_DESC=TEST_TASK002&TASK_COMMENT=TEST_TASK002&TASK_DATE=sysdate&ADD_SUBTASK=YES&TASK_NAME_SUB=TEST_TASK002&TASK_ASSIGNED=DEFAULT&PASSWD=quake2&submit=Submit'
#os.environ['QUERY_STRING'] = 'TASK_ID=1&TASK_NAME=TEST_TASK003&TASK_NAME_SUB=TEST_TASK004.01&TASK_DESC=TEST_TASK003 Description&TASK_DATE=sysdate&TEST_TASK003&TASK_COMMENT=TEST_TASK00&PASSWD=acb123'
#

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

cx_Oracle.init_oracle_client(lib_dir='C:/Users/shivdeep.modi/OneDrive - IHS Markit/Shivdeep/instantclient_19_9')

# Get data from fields
fTASK_ID      = form.getvalue('TASK_ID').strip()
fTASK_NAME    = form.getvalue('TASK_NAME').strip()
fTASK_DESC    = form.getvalue('TASK_DESC').strip()

fTASK_COMMENT = form.getvalue('TASK_COMMENT').strip()
fPASSWD       = form.getvalue('PASSWD').strip()
fADD_SUBTASK  = form.getvalue('ADD_SUBTASK').strip()
fTASK_ASSIGNED= form.getvalue('TASK_ASSIGNED').strip()
fTASK_NAME_SUB= form.getvalue('TASK_NAME_SUB').strip()
ftheDate    = form.getvalue('theDate').strip()
ftheTime    = form.getvalue('theTime').strip()

fTASK_DATE   =str(ftheDate)+" "+str(ftheTime)+":00"
#import mydb
import tasks
import mydb
import css

if fPASSWD == 'quake2':
		#print ("Date got :{}".format(fTASK_DATE))
		#print(fPASSWD);
		

		#sql = ('select * from sub where  work_task = :work_task and assigned = :assigned' )
		#Implement like condition.
		#sql = "select * from sub where  work_task like :work_task" + "||'%'"
		
		
		sqlm   = "select tl.description,tm.work_task, tm.work_task_desc, tm.start_date,tm.status,tm.comments from TASK_MAIN tm ,TASK_LIST tl where   tm.taskid = tl.taskid and tm.work_task = :v_TASK_NAME"
		sqlsub = "select tm.work_task, ts.work_task_sub,ts.assigned, ts.start_date,ts.status,ts.comments from TASK_MAIN tm ,TASK_SUBTASK ts where   tm.work_task = ts.work_task and tm.work_task = :v_TASK_NAME"
		sqldly = "select td.work_task, td.work_task_sub,td.assigned, td.start_date,td.status,td.comments from TASK_MAIN tm ,TASK_SUBTASK_DAILY td where   tm.work_task = td.work_task and tm.work_task = :v_TASK_NAME"
	
		
		#This also works
		#sql = """select * from sub where  work_task = :work_task"""
		
		


		print ("Content-type:text/html\r\n\r\n")
		print ("<html>")
		print ("<head>")
		print ("<title>CREATE TASK</title>")
		print ("</head>")
		
		css.get_css()
		
		print ("<body >"                                            )
		print ("<div>")
		print("<table>"                                             )
		print ("<tr><td class='bold1' colspan=2> {} </td></tr>".format('TASK ENTRY DETAILS',20));
		print ("<tr><td>TASK_ID      : </td><td> {} </td></tr>".format(fTASK_ID,10) );
		print ("<tr><td>TASK_NAME    : </td><td> {} </td></tr>".format(fTASK_NAME,50) );
		print ("<tr><td>TASK_NAME_SUB: </td><td> {} </td></tr>".format(fTASK_NAME_SUB,50) );
		print ("<tr><td>DESCRIPTION  : </td><td> {} </td></tr>".format(fTASK_DESC,100) );
		print ("<tr><td>START_DATE   : </td><td> {} </td></tr>".format(fTASK_DATE,20) )
		print ("<tr><td>COMMENTS     : </td><td> {} </td></tr>".format(fTASK_COMMENT,500) )
		print ("<tr><td>ADD_SUBTASK  : </td><td> {} </td></tr>".format(fADD_SUBTASK,3) )
		print ("<tr><td>TASK_ASSIGNED: </td><td> {} </td></tr>".format(fTASK_ASSIGNED,100) )
		
		print("</table>")
		print("</div>")
		##print ("</body>"                                        )
		##print ("</html>"                                        )
		#ssh tunnel is setup to connect to GIT56PD_LOV2_01
		#db = cx_Oracle.connect("smodi", "SRXOQIwMjbCzr2GAiTj8#", "localhost:9999/GIT56PD_LOV2_01.info.corp")
		#cursor = db.cursor()
		#Connect using tnsnames entry
		#db = cx_Oracle.connect("smodi", "SRXOQIwMjbCzr2GAiTj8#", "smodi_tunnel", encoding="UTF-8")
		
		#for row in cursor.execute(sql, [fTASK_NAME]):
		#            print(row)
		#        #cursor.close()
		# datetime.now()
		
		#insert data beings
		
		# Set Assigned for subtask/daily task.
		if fTASK_ASSIGNED == 'DEFAULT':
			vTASK_ASSIGNED = 'Shivdeep'
		else:
			vTASK_ASSIGNED = fTASK_ASSIGNED
			
		#Main Task
		tasks.add_main_task(fTASK_ID,fTASK_NAME,fTASK_DESC,fTASK_DATE,fTASK_COMMENT)
		
		#Sub Task
		if fADD_SUBTASK == 'YES':
				tasks.add_sub_task(fTASK_NAME,fTASK_NAME_SUB,vTASK_ASSIGNED,fTASK_DATE,fTASK_COMMENT)
		
		#Daily Task
		if fADD_SUBTASK == 'YES':
				tasks.add_daily_task(fTASK_NAME,fTASK_NAME_SUB,vTASK_ASSIGNED,fTASK_DATE,fTASK_COMMENT)
				
		#insert data ends
		
		#print the inserted data now
		
		##print main task begin
		print("<div>")
		print("<table>")
		
		print ("<tr>"
			+"<td class=bold1 colspan=6> {} </td>".format('MAIN TASK INFORMATION') 
			+ "</tr>"
			+"<tr>"
			+"<td> {} </td>".format('TASK TYPE',10) 
			+"<td> {} </td>".format('TASK NAME',50) 
			+"<td> {} </td>".format('TASK DESCRIPTION',100)
			+"<td> {} </td>".format('START DATE',20)
			+"<td> {} </td>".format('STATUS',20) 
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
					cursor.execute(sqlm, [fTASK_NAME])
					rows = cursor.fetchall()
					if rows:
						for row in rows:
							#print(row)
							print ("<tr>"
								+"<td> {} </td>".format(row[0],10) 
								+"<td> {} </td>".format(row[1],50) 
								+"<td> {} </td>".format(row[2],100)
								+"<td> {} </td>".format(row[3],20) 								
								+"<td> {} </td>".format(row[4],20) 
								+"<td> {} </td>".format(row[5],500)
								+"</tr>"
							);
		
			
		except cx_Oracle.Error as error:
			print(error)	
		
		print("</table>")
		print("</div>")
		#print main task end
		
		###########################################################
		#print sub task begin
		###########################################################
		print("<div>")
		print("<table >")
		
		print ("<tr>"
			+"<td class=bold1 colspan=6> {} </td>".format('SUB TASK INFORMATION') 
			+ "</tr>"
			+"<tr>"
			+"<td> {} </td>".format('TASK NAME',50) 
			+"<td> {} </td>".format('TASK NAME_SUB',50) 
			+"<td> {} </td>".format('ASSIGNED',100) 
			+"<td> {} </td>".format('START DATE',20) 
			+"<td> {} </td>".format('STATUS',20) 
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
					cursor.execute(sqlsub, [fTASK_NAME])
					rows = cursor.fetchall()
					if rows:
						for row in rows:
							#print(row)
							print ("<tr>"
								+"<td> {} </td>".format(row[0],50) 
								+"<td> {} </td>".format(row[1],50) 
								+"<td> {} </td>".format(row[2],100) 
								+"<td> {} </td>".format(row[3],20) 
								+"<td> {} </td>".format(row[4],20) 
								+"<td> {} </td>".format(row[5],500)
								+"</tr>"
							);
		
			
		except cx_Oracle.Error as error:
			print(error)	
		
		print("</table>")
		print("</div>")
        
		###########################################################
		#print sub task end
		###########################################################

		###########################################################
		#print Daily task begin
		###########################################################
		print("<div>")
		print("<table>")
		
		print ("<tr>"
			+"<td class=bold1 colspan=6> {} </td>".format('Daily TASK INFORMATION') 
			+ "</tr>"
			+"<tr>"
			+"<td> {} </td>".format('TASK NAME',50) 
			+"<td> {} </td>".format('TASK NAME_SUB',50) 
			+"<td> {} </td>".format('ASSIGNED',100) 
			+"<td> {} </td>".format('START DATE',20) 
			+"<td> {} </td>".format('STATUS',20) 
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
					cursor.execute(sqldly, [fTASK_NAME])
					rows = cursor.fetchall()
					if rows:
						for row in rows:
							#print(row)
							print ("<tr>"
								+"<td> {} </td>".format(row[0],50) 
								+"<td> {} </td>".format(row[1],50) 
								+"<td> {} </td>".format(row[2],100) 
								+"<td> {} </td>".format(row[3],20) 
								+"<td> {} </td>".format(row[4],20) 
								+"<td> {} </td>".format(row[5],500)
								+"</tr>"
							);
		
	
		except cx_Oracle.Error as error:
			print(error)	
		
		print("</table>"                                             )
		print("</div>")
		###########################################################
		#print Daily task end
		###########################################################
		
		#print('db.version:'+db.version)
		print ("</body>"                                        )
		print ("</html>"                                        )
else:
		print ("Content-type:text/html\r\n\r\n"                     )
		print ("<html>"                                             )
		print ("<head>"                                             )
		print ("<title>create_task</title>"                         )
		print ("</head>"                                            )
		print ("<STYLE type='text/css'>"                            )  
		print ("BODY {background: #AEF7DC;margin: 10px;}  "         )
		print ("</STYLE>"                                            )
		print ("<body >"                                            )
		print ("<p> Invalid Password </p>")
		print ("</body >"                                           )
		print ("</html>"                                            )
