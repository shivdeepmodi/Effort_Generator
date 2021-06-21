#!"C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe"

import cx_Oracle
import sys
import os
import cgitb
cgitb.enable(display=1, logdir="C:/tmp")
try:
		cx_Oracle.init_oracle_client(lib_dir=r'C:/Users/shivdeep.modi/OneDrive - IHS Markit/Shivdeep/instantclient_19_9')
		print ("Content-type:text/html\r\n\r\n"						)
		print()
		print ("<html>"                                             )
		print ("<head>"                                             )
		print ("<title>Create </title>"        )
		print ("</head>"    )
		print ("<body>"     )	 
		print ("<p> dbtest2</p>"     )	 
		print ("</body>"     )	 
		print ("</html>"                                             )

				
except Exception as err:
    print("Whoops!")
    print(err);
    sys.exit(1);