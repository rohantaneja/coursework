import socket, sys
from threading import Thread

socketList = []
doctor_flag = 0
procList = []

def getUsername(clientSocket):
	try:
		clientUsername = clientSocket.recv(64)
		clientUsername = clientUsername.decode('utf-8')
		return clientUsername

	except:
		return False

def deleteUser(clientSocket):
	# remove the client connection when it closes at runtime
    if clientSocket in socketList:
        print(socketList)
        socketList.remove(clientSocket)

def broadcastToOtherClients(msg, clientSocket):
	for clients in socketList:
		if clients!=clientSocket:
			try:
				msg = msg.encode('utf-8')
				clients.send(msg)
			except:
				clients.close()
				deleteUser(clients)
				# if the link is broken, we remove the client

def clientHndlr(clientSocket, clientAddr):

	global doctor_flag

	username = getUsername(clientSocket)

	if username == 'Doctor':
		doctor_flag = doctor_flag + 1

	print("User connected to the server: ",username)

	while True:
		try:
			if doctor_flag > 0:
				msg = clientSocket.recv(1024)
				msg = msg.decode('utf-8')
				if msg:
					bcMsg = ("< " + username + " > " + msg)
					broadcastToOtherClients(bcMsg, clientSocket)
					#print (bcMsg)
					# Calls broadcast function to send message to all

				else:
					deleteUser(clientSocket)
		except:
			continue

#def svSocketInit():
try:
	svSocket = socket.socket(socket.AF_INET,socket.SOCK_STREAM) # create socket
	svSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) # broadcast opts
	svPort = 17420	                                # select port to work on - will move to argv
	svSocket.bind(('', svPort))						# bind socket on assigned sv
	svSocket.listen(5)								# instantiate sv to listen request

# socket_expection_handler()
except socket.error:
	print("Failed to set up the socket, exiting program.")
	sys.exit(2)

# init main()
print(" ")
print("---------------------------------------------------------------------")
print("||                                    	                           ||")
print("||			  ---COVID-19---			   ||")
print("||   		   --- DOCTOR-PATIENT SERVER ---    		   ||")
print("||   		   --- PROJECT BY - GROUP 13 ---    		   ||")
print("||                                    	                           ||")
print("||                                    	                           ||")
print("|| - - - - - - - - - - -  < WORKING NOTES >  - - - - - - - - - - - ||")
print("||                                    	                           ||")
print("||   	1. Client.py connects to server   			   ||")
print("||   	2. Client.py fills up the survey   		    	   ||")
print("||   	3. If client is high risk, it queues up the connection 	   ||")
print("||		(waits for doctor to arrive) 			   ||")
print("||                                    	                           ||")
print("||   	4. Doctor connects to server, interacts with client 	   ||")
print("||                                    	                           ||")
print("||		< Check README.md for Instructions >		   ||")
print("||                                    	                           ||")
print("---------------------------------------------------------------------")
print(" ")
print ('Hospital Server - receiving on port %i.' % svPort)
while True:
	# works until ctrl-c is trigger on runtime
	try:
		clientSocket, clientAddr = svSocket.accept()

		socketList.append(clientSocket)

		proc = Thread(target=clientHndlr, args=[clientSocket, clientAddr])

		proc.start()
		procList.append(proc)

	except KeyboardInterrupt:
		clientSocket.close()
		svSocket.close()
		print (" \nClosing the server.")
		sys.exit(1)
