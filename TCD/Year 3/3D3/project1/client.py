import socket # low level implementation
import sys # for arguements retrieval from terminal
import threading # threading synchronous processes
import module # blockchain module
import json # encode json objects in block generation

chain_obj = module.Blockchain()
peerList = []

port = 5000 + int(sys.argv[2])
host = sys.argv[1]

client = {(sys.argv[1],'5000')} # store (host:port) in a dictionary

# Create thread objects

class transmission(threading.Thread):
	def __init__(self,port,host,data):
		super(transmission,self).__init__()
		self.port = port
		self.host = host
		self.data = data
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # use UDP for unconditional - no connection transmission. keeping peer active always when script running

	def run(self):
		global port
		msg = self.data
		at = msg + ' $$ ' + str(port)
		self.sock.sendto(at.encode('utf-8'),(self.host,self.port)) # (data, address)

class transmission_validate(threading.Thread):
	def __init__(self):
		super(transmission_validate,self).__init__() # super constructor for self object call
		global port
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.sock.bind(("", port))
		#print("Waiting on port:", port)

	def run(self):
		global chain_obj
		while True:
			data, addr = self.sock.recvfrom(1024)
			print(data,addr)
			inf = data.decode('utf-8')
			data,rcv_port = inf.split(' $$ ')
			# check first 4 bits - handle for each condition - for sufficing proof of work nonce

			if data[:4] == '0110':
				wst,rpt,adrs = data.split('  ') # split bit + data i.e. wst=0000 rpt = rcv port, adrs = client address
				new_client = (adrs,int(rpt))
				if client.__contains__(new_client) == False:
					client.add(new_client)

			elif data[:4] == '0101':
				wst,rpt,rhst = data.split('  ') # split bit + data i.e. wst=0000 rpt = rcv port, adrs = client address
				new_client = (rhst,int(rpt))
				if client.__contains__(new_client) == False:
					client.add(new_client)

			elif data[:4] == '0011':
				wst,newchain = data.split('  ') # split bit + chain i.e. newchain
				dechain = json.loads(newchain)
				for a in dechain:
					chain_obj.addBlock(dechain[a])
				print(chain_obj)

			elif data[:4] == '1001':
				new_client = (addr[0],rcv_port)
				if client.__contains__(new_client) == False: # check if incoming client exists
					for x in client:
						thread = transmission(int(x[1]),x[0],'0110  ' + str(rcv_port)+'  '+new_client[0]) # port, host, data
						thread.start()
						thread.join()
					client.add(new_client)
			elif data[:4] == '0000': # for mined and valid block
				wst,rpt = data.split('  ') # split bit + data i.e. wst=0000 rpt = actual data
				chain_obj.addBlock(rpt)
			#print(client)
			#print(chain_obj)

class data_transmission(threading.Thread):
	def __init__(self):
		super(data_transmission,self).__init__() # super constructor for self object call
	def run(self):
		data  = "null_data"
		global port
		global chain_obj
		for new_client in client:
			host = new_client[0]
			pt = int(new_client[1])
			sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
			msg = data
			at = '1001  ' + msg + ' $$ ' + str(port)
			sock.sendto(at.encode('utf-8'),(host,pt))
		while True:
			data = input("Enter data for the block: ")
			chain_obj.addBlock(data)
			for new_client in client:
				host = new_client[0]
				pt = int(new_client[1])
				sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
				msg = data
				at = '0000  ' + msg + ' $$ ' + str(port)
				sock.sendto(at.encode('utf-8'),(host,pt))


thread1 = transmission_validate()
thread2 = data_transmission()
thread1.start()
thread2.start()
thread1.join()
thread2.join()
