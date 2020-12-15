import socket, sys, select

clientPort = 17420
clientAddr = "127.0.0.3" #localhost.2

surveyList = []

clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
clientSocket.connect((clientAddr, clientPort))

username = input("Enter your name: ") # anything other than doctor

print("Hello ",username,"! Welcome to COVID-19 Handler.")
username = username.encode('utf-8')
clientSocket.send(username)


def clientSurvey():
	print("Answer the following survey for your symptoms [severity level - 0: low to 5: extreme]")
	scale = input("1. Fever Severity (0-5): ")
	surveyList.append(int(scale))

	scale = input("2. Cough Severity (0-5): ")
	surveyList.append(int(scale))

	scale = input("3. Breathing Severity (0-5): ")
	surveyList.append(int(scale))
	#print(surveyList)

	# return avg of surveyList
	return sum(surveyList)/len(surveyList)


prompt=""
while (prompt!="Y" and prompt!="N"):
  prompt = input("Do you want to take symptoms survey? (Y/N)").upper()

if prompt=='Y':
	symptoms = clientSurvey()

	if (int(symptoms) >= 3.33):
		print("You are a high risk client. Let's get in touch with doctor.\n")
		print("Please wait till doctor connects...\n\n")
		while True:
			socketList = [sys.stdin, clientSocket]
			#print (socketList)
			read_sockets, write_socket, error_socket = select.select(socketList,[],[])
			# store socket selection
			#read_sockets returns true for if condition below
			#else is triggered for other cases

			# receive message from server
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

	else:
		print("Low Risk Patient!")
		print("Please consider taking precautions. Thanks")

else:
	clientSocket.close()
	sys.exit(1)
