import socket, sys, select

clientPort = 17420
clientAddr = ("127.0.0.10", clientPort)

surveyList = []

clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clientSocket.connect(clientAddr)

username = 'Doctor'
print(f'Hello Doctor! Please help your patients.')
username = username.encode('utf-8')

clientSocket.send(username)


while True:
	socketList = [sys.stdin, clientSocket]

	read_sockets,write_socket, error_socket = select.select(socketList,[],[])
	# store socket selection
	#read_sockets returns true for if condition below
	#else is triggered for other cases

	for socks in read_sockets:
		if socks == clientSocket:
			msg = socks.recv(1024)
			msg = msg.decode('utf-8')
			print(msg)
		else:
			msg = sys.stdin.readline()
			sys.stdout.write("You > ")
			sys.stdout.write(msg)
			msg = msg.encode('utf-8')
			clientSocket.send(msg)
			sys.stdout.flush()
clientSocket.close()
