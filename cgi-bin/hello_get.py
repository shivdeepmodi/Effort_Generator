#!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
# Import modules for CGI handling 
import cgi
import cgitb; cgitb.enable()

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
first_name = form.getvalue('first_name')
last_name  = form.getvalue('last_name')

print ("Content-type:text/html\r\n\r\n"                 )
print ("<html>"                                         )
print ("<head>"                                         )
print ("<title>Hello - Second CGI Program</title>"      )
print ("</head>"                                        )
print ("<body>"                                         )
print ("<h2>Hello {0} {1}</h2>".format(first_name, last_name) )
print ("</body>"                                        )
print ("</html>"                                        )