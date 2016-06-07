import pg8000
conn = pg8000.connect(host = 'localhost', user = 'postgres')
cursor = conn.cursor()
cursor.execute('select get_next_experiment()')
experimentId = cursor.fetchall()[0][0]
print('experimentId: ' + str(experimentId))
cursor.execute('select get_experiment_script(%s)', (experimentId,))
experimentScript =  cursor.fetchall()[0][0]
cursor.execute('select * from get_experiment_parameters(%s)', (experimentId,))
experimentParams = cursor.fetchall()

print(experimentParams)
for listElement in experimentParams:
	print(listElement)

#exec experimentScript

#	cursor.execute('select record_result(?,?,?)', experimentId, score, extraData)
#	cursor.commit()
