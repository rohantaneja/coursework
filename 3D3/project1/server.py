import socket # low level implementation
import sys # for arguements retrieval from terminal
import threading # threading synchronous processes
import module # blockchain module
import json # encode json objects in block generation

chain_obj = module.Blockchain()
peerList = []

port = 5000
host = 127.0.0.1

client = set()

class transmission(threading.Thread):
	def __init__(self,port,host,data):
		super(transmission,self).__init__() # super constructor for self object call
		self.port = port
		self.host = host
		self.data = data
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

	def run(self):
		global port
		msg = self.data
		at = msg + ' $$ ' + str(port)
		self.sock.sendto(at.encode('utf-8'),(self.host,self.port))

class sv_conn(threading.Thread):
	def __init__(self):
		super(sv_conn,self).__init__() # super constructor for self object call
		global port
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.sock.bind(("", port))
		print("Waiting on port:", port)

	def run(self):
		global chain_obj
		chain_obj.addBlock('p2p_conn_established')
		while True:
			data, addr = self.sock.recvfrom(1024)
			print(data,addr)
			inf = data.decode('utf-8')
			data,rcv_port = inf.split(' $$ ')
			if data[:4] == '0110':
				wst,rpt,adrs = data.split('  ') # split bit + data i.e. wst=0000 rpt = actual data, adrs = client address
				new_client = (adrs,int(rpt))
				if client.__contains__(new_client) == False:
					client.add(new_client)
			elif data[:4] == '1001':
				new_client = (addr[0],rcv_port)
				if client.__contains__(new_client) == False:
					for x in client:
						thread = transmission(int(x[1]),x[0],'0110  ' + str(rcv_port) +'  '+new_client[0])
						thread.start()
						thread.join()
					for x in client:
						thread = transmission(int(new_client[1]),new_client[0],'0101  ' + str(x[1]) +'  '+x[0])
						thread.start()
						thread.join()
					dechain = {}
					for i in range(1,len(chain_obj.chain)):
						dechain[i] = chain_obj.chain[i].data
					dej = json.dumps(dechain) # encode to json object
					sdt = '0011  ' + dej
					tt = transmission(int(new_client[1]),new_client[0],sdt)
					tt.start()
					tt.join()
					client.add(new_client)
			elif data[:4] == '0000':
				wst,rpt = data.split('  ') # split bit + data i.e. wst=0000 rpt = actual data
				chain_obj.addBlock(rpt)
			#print(client)
			print(chain_obj)

thread1 = sv_conn()
thread1.start()
thread1.join()
