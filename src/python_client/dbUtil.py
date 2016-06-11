import pg8000
import sys
class DbUtil:
	def __init__(self, _host, _user, _pass):
		self.conn = pg8000.connect(host = _host, user = _user, password = _pass)
		self.cursor = self.conn.cursor()

	def getNextExperiment(self):
#		try:
		self.cursor.execute('select get_next_experiment()')
		return self.cursor.fetchall()[0][0]
#		except:
#			print("Unexpected error:", sys.exc_info()[0])
#			return None

	def getExperimentScript(self, experimentId):
#		try:
		self.cursor.execute('select get_experiment_script(%s)', (experimentId,))
		return self.cursor.fetchall()[0][0]
#		except:
#			print("Unexpected error:", sys.exc_info()[0])
#			return None

	def getExperimentParams(self, experimentId):
#		try:
		self.cursor.execute('select * from get_experiment_parameters(%s)', (experimentId,))
		experimentParams = self.cursor.fetchall()
		parameterData = {}
		for listElement in experimentParams:
			parameterData[listElement[0]] = listElement[1]
		return parameterData
#		except:
#			print("Unexpected error:", sys.exc_info()[0])
#			return None

	def recordExperimentResult(self, experimentId, score, detail):
		self.cursor.execute('select record_experiment_result(%s, %s, %s)', (experimentId, score, detail))
		self.conn.commit()

def getDefaultDatabase():
	return DbUtil('localhost', 'postgres', None)
