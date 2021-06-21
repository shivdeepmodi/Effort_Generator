#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python37\python.exe
import cgi, cgitb 
from os import environ

print ("Set-Cookie:UserID = XYZ;\r\n"									)
print ("Set-Cookie:Password = XYZ123;\r\n"                              )
print ("Set-Cookie:Expires = Tuesday, 31-Dec-2019 23:12:40 GMT;\r\n"    )
print ("Set-Cookie:Domain = www.timepass.com;\r\n"                      )
print ("Set-Cookie:Path = /perl;\n"                                     )
print ("Content-type:text/html\r\n\r\n"                                 )
#print ('<html>')
print('<br> Cookie Set</br>')
#print('</html>')

 <form action = "/cgi-bin/set_cookie.py" method = "post">
<input type = "submit" value = "Submit" />
if environ.has_key('HTTP_COOKIE'):
   for cookie in map(strip, split(environ['HTTP_COOKIE'], ';')):
      (key, value ) = split(cookie, '=');
      if key == "UserID":
         user_id = value

      if key == "Password":
         password = value

print ("User ID  = {0}".format( user_id  ))
print ("Password = {0}".format(password ))