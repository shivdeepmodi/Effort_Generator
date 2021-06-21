#!C:\Users\shivdeep.modi\AppData\Local\Microsoft\WindowsApps\python.exe
# Import modules for CGI handling 
import cgi, cgitb 

# Create instance of FieldStorage 
form = cgi.FieldStorage() 

# Get data from fields
if form.getvalue('textcontent'):
   text_content = form.getvalue('textcontent')
else:
   text_content = "Not entered"

print ("Content-type:text/html\r\n\r\n"                      )
print ("<html>"                                              )
print ("<head>"                                             )
print ("<title>Text Area - Fifth CGI Program</title>"        )
print ("</head>"                                             )
print ("<body>"                                              )
print ("<h2> Entered Text Content is {0}</h2>".format(text_content ))
print ("</body>"                                             )