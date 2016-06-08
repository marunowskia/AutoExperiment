import pg8000
import nbody

conn = pg8000.connect(host = 'localhost', user = 'postgres')
cursor = conn.cursor()


while True:
	cursor.execute('select get_next_experiment()')
	experimentId = cursor.fetchall()[0][0]
	print('experimentId: ' + str(experimentId))
	cursor.execute('select get_experiment_script(%s)', (experimentId,))
	experimentScript =  cursor.fetchall()[0][0]
	cursor.execute('select * from get_experiment_parameters(%s)', (experimentId,))
	experimentParams = cursor.fetchall()

	parameterData = {}

#	print(experimentParams)

	for listElement in experimentParams:
		parameterData[listElement[0]] = listElement[1]

	# show that our dictionary is populated well
#	for k in parameterData:
#		print(k + ": " + str(parameterData[k]))

	# nbody specific
	
		
#	print(experimentId)
	cursor.execute('select record_experiment_result(%s,%s,%s)', (experimentId, nbody.main(parameterData), ''))
	conn.commit()
