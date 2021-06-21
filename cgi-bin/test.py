#!"C:\Users\shivdeep.modi\AppData\Local\Programs\Python\Python39\python.exe"
import os

print ("Content-type:text/html\r\n\r\n"						)
print ('<html>'                                             )
print ('<head>'                                             )
print ('<title>Hello World - First CGI Program</title>'      )
print ('</head>')

with open(r'C:\Users\shivdeep.modi\OneDrive - IHS Markit\Shivdeep\Projects\Work\SME\Effort_Generator\css.txt', 'r') as f:
	print(f.read())
	
print ('<body>')
print ('<div>')
print ('<p class=ht1>Hello World! This is my first CGI program</p>' )
print ('</div>')
print ('</body>'                                            )
print ('</html>'                                            )

