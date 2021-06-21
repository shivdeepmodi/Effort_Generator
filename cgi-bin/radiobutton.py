#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python37\python.exe
# Import modules for CGI handling 
import cgi, cgitb 

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
if form.getvalue('subject'):
   subject = form.getvalue('subject')
else:
   subject = "Not set"

print ("Content-type:text/html\r\n\r\n"                   )
print ("<html>"                                           )
print ("<head>"                                           )
print ("<title>Radio - Fourth CGI Program</title>"        )
print ("</head>"                                          )
print ("<body>"                                           )
print ("<h2> Selected Subject is {0}</h2>".format(subject))
print ("</body>"                                          )
print ("</html>"                                          )