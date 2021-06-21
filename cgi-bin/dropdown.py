#!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
import cgi, cgitb 

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
if form.getvalue('dropdown'):
   subject = form.getvalue('dropdown')
else:
   subject = "Not entered"

print ("Content-type:text/html\r\n\r\n"                  )
print ("<html>"                                          )
print ("<head>"                                          )
print ("<title>Dropdown Box - Sixth CGI Program</title>" )
print ("</head>"                                         )
print ("<body>"                                          )
print ("<h2> Selected Subject is {0}</h2>".format(subject))
print ("</body>"                                         )
print ("</html>"                                         )