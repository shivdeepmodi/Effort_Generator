#!C:/Program Files/Python39/python.exe
import os

print ("Content-type:text/html\r\n\r\n"						)
print ('<html>'                                             )
print ('<head>'                                             )
print ('<title>Hello World - First CGI Program</title>'      )
print ('</head>'                                            )
print ('<body>'                                             )
print ('<h2>Hello World! This is my first CGI program</h2>'  )

print ("<b>Environment<b><br>");
for param in os.environ.keys():
   print ("<b>{0}</b>: {1} <br>".format(param, os.environ[param]))
print ('</body>'                                            )
print ('</html>'                                            )

