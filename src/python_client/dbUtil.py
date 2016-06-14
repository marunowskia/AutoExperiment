import pg8000
import sys
class DbUtil:
	def __init__(self, _host, _user, _pass):
		self.conn = pg8000.connect(host = _host, user = _user, password = _pass)
		self.cursor = self.conn.cursor()

	def getNextExperiment(self):
		self.cursor.execute('select get_next_experiment()')
		self.conn.commit()

		result = self.cursor.fetchall()
		if len(result) == 1 and len(result[0]) == 1:
			return result[0][0]
		return None

	def getExperimentScript(self, experimentId):
		self.cursor.execute('select get_experiment_script(%s)', (experimentId,))
		result = self.cursor.fetchall()
		if len(result) == 1 and len(result[0]) == 1:
			return result[0][0]
		return None


	def getExperimentParams(self, experimentId):
		self.cursor.execute('select * from get_experiment_parameters(%s)', (experimentId,))
		experimentParams = self.cursor.fetchall()
		parameterData = {}
		for listElement in experimentParams:
			parameterData[listElement[0]] = listElement[1]
		return parameterData

	def recordExperimentResult(self, experimentId, score, detail):
		self.cursor.execute('select record_experiment_result(%s, %s, %s)', (experimentId, score, detail))
		self.conn.commit()

def getDefaultDatabase():
	return DbUtil('localhost', 'postgres', None)
