#!C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python37\python.exe

import cgi, os
import cgitb; cgitb.enable()

form = cgi.FieldStorage()

# Get filename here.
fileitem = form['filename']

# Test if the file was uploaded
if fileitem.filename:
   # strip leading path from file name to avoid 
   # directory traversal attacks
   fn = os.path.basename(fileitem.filename)
   print(fn)
   #open('C:\Users\SHIVDE~1.MOD\AppData\Local\Temp\' + fn, 'wb').write(fileitem.file.read())

   message = 'The file "' + fn + '" was uploaded successfully'
   
else:
   message = 'No file was uploaded'

print ("Content-type:text/html\r\n\r\n"           )

print ("""
<html>
<body>
   <p>{0}</p>
</body>
</html>
""".format(message))