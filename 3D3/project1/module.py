import hashlib

#
#	Basic blockchain implementation in python3
#

class Block:
	
	def __init__(self,index,prevhash,data):
		self.index = index
		self.prevhash = prevhash
		self.data = data
		self.nonce = 0 # to verify proof of work
		self.genhash()
		self.mine()

	def __repr__(self):
		return (str(self.index) +' ,'+ self.prevhash +' ,'+ self.data +' ,'+ self.currhash)

	def genhash(self):
		self.currhash = hashlib.sha256((str(self.index) + self.prevhash + self.data +str(self.nonce)).encode('utf-8')).hexdigest() # generate block hash

	def isMined(self):
		if self.currhash[:4] == '0000': # if first 4 bits of current block hash is 0000 mark as mined
			return True
		else:
			return False

	def mine(self):
		if self.isMined() == False:
			while self.isMined() == False:
				self.nonce += 1
				self.genhash()
				
class Blockchain:
	def __init__(self):
		self.chain = []
		self.gbl = Block(0,'null_hash','null_data')
		self.chain.append(self.gbl)
		print(self.chain)

	def addBlock(self,inp):
		data = inp
		block = Block(len(self.chain),self.chain[len(self.chain)-1].currhash,data)
		self.chain.append(block)

	def updateData(self,id,inp):
		self.chain[id].data = inp
		self.chain[id].genhash()
		self.chain[id].mine()

	def __repr__(self):
		out = ''
		for block in self.chain:
			out += "[( " + str(block) + " )]\n"
		return out

	"""

	Some additional functionality I learned
	and implemented in case of checking the
	chain if is broken in the server and re
	-pair if so has occurred.

	"""

	def isChainBroken(self):
		flag = False
		for i in range(1,len(self.chain)):
			if self.chain[i].prevhash != self.chain[i-1].currhash:
				print('Error: Blockchain is broken')
				flag = True
				break
		if flag == False:
			print('Blockchain is fine.')

	def repairChain(self):
		for i in range(1,len(self.chain)):
			if self.chain[i].prevhash != self.chain[i-1].currhash:
				self.chain[i].prevhash = self.chain[i-1].currhash
				self.chain[i].mine()
